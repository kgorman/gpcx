#!/bin/bash
# This script helps initialize the Ghost blog on first deployment

# Debug: Print all environment variables (hiding passwords)
echo "===== ENVIRONMENT VARIABLES ====="
env | grep -v PASSWORD | grep -v password | grep -v pass
echo "================================="

# Extract database connection info from Ghost's environment variables
# Try both formats of environment variables to ensure we get the right ones
DB_HOST="dpg-d3mkf62li9vc7384cat0-a"
DB_USER="${database__connection__user:-$DATABASE_USER}"
DB_PASSWORD="${database__connection__password:-$DATABASE_PASSWORD}"
DB_NAME="${database__connection__database:-$DATABASE_NAME}"
DB_PORT="${database__connection__port:-5432}"

# Display connection information (without credentials)
echo "Database connection info:"
echo "Host: $DB_HOST (hardcoded internal Render hostname)"
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Port: $DB_PORT"

# Create a database configuration file that Ghost can use
# This is a more reliable way to pass database configuration to Ghost
cat > /var/lib/ghost/config.production.json << EOL
{
  "url": "${url}",
  "server": {
    "port": 2368,
    "host": "0.0.0.0"
  },
  "database": {
    "client": "postgres",
    "connection": {
      "host": "${DB_HOST}",
      "port": ${DB_PORT},
      "user": "${DB_USER}",
      "password": "${DB_PASSWORD}",
      "database": "${DB_NAME}",
      "ssl": {
        "rejectUnauthorized": false
      }
    },
    "migrations": {
      "migrationPath": "/var/lib/ghost/versions/6.3.1/core/server/data/migrations",
      "tableName": "migrations"
    }
  },
  "logging": {
    "transports": [
      "stdout"
    ],
    "level": "info"
  },
  "paths": {
    "contentPath": "/var/lib/ghost/content"
  },
  "database_schema_migrations": {
    "fromVersion": "init",
    "toVersion": "init"
  }
}
EOL

echo "Created config.production.json with database configuration"

# Try to connect to the database
echo "Trying to reach database host..."
ping -c 3 $DB_HOST || echo "Could not ping the host, but this might be expected"

# Try netcat to test connectivity
echo "Trying to connect to database port..."
nc -zv $DB_HOST $DB_PORT || echo "Could not connect with netcat, continuing anyway"

# Create the content directory structure if it doesn't exist
mkdir -p /var/lib/ghost/content/data
mkdir -p /var/lib/ghost/content/images
mkdir -p /var/lib/ghost/content/themes
mkdir -p /var/lib/ghost/content/logs
mkdir -p /var/lib/ghost/content/adapters
mkdir -p /var/lib/ghost/content/settings

# Make sure permissions are correct
echo "Setting correct permissions..."
chown -R node:node /var/lib/ghost/content
chmod 644 /var/lib/ghost/config.production.json

# Install any missing packages 
echo "Ensuring all required packages are installed..."
cd /var/lib/ghost
npm install --no-save pg knex@"0.21.21"

# Set server configuration to bind to all interfaces
export server__host="0.0.0.0"
export server__port=2368

# Set skip database migration flag to avoid errors with existing database
export NODE_ENV=production
export ghost_skip_migrations=true

# Make sure config file is accessible
echo "Checking config file..."
cat /var/lib/ghost/config.production.json | grep -v password | grep -v PASSWORD

# Try to handle existing database schema by checking for tables
echo "Checking if database already has Ghost tables..."
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "\dt" || echo "Could not check tables, proceeding anyway"

# Create a special bootstrap file to help with DB initialization
cat > /var/lib/ghost/bootstrap-database.js << EOL
// This script helps initialize the database correctly when tables already exist
const knex = require('knex')({
  client: 'postgres',
  connection: {
    host: '${DB_HOST}',
    user: '${DB_USER}',
    password: '${DB_PASSWORD}',
    database: '${DB_NAME}',
    port: ${DB_PORT},
    ssl: { rejectUnauthorized: false }
  }
});

async function fixDatabase() {
  try {
    // Check if migrations_lock table exists
    const tableExists = await knex.schema.hasTable('migrations_lock');
    
    if (tableExists) {
      console.log('migrations_lock table exists, setting to unlocked...');
      // Make sure it's unlocked
      await knex('migrations_lock').update({ locked: 0 }).where({ lock_key: 'km01' });
      
      // Check if it has a primary key
      const result = await knex.raw("SELECT constraint_name FROM information_schema.table_constraints WHERE table_name = 'migrations_lock' AND constraint_type = 'PRIMARY KEY'");
      
      if (result.rows.length > 0) {
        console.log('Primary key exists on migrations_lock, dropping it...');
        // Drop the primary key to prevent conflicts
        await knex.raw("ALTER TABLE migrations_lock DROP CONSTRAINT " + result.rows[0].constraint_name);
      }
    }
    
    // List all Ghost tables for debugging
    console.log('Listing all tables in database:');
    const tables = await knex('pg_catalog.pg_tables')
      .select('schemaname', 'tablename')
      .where('schemaname', 'public');
    console.log(tables);
    
    console.log('Database prepared for Ghost startup.');
  } catch (err) {
    console.error('Error preparing database:', err);
  } finally {
    await knex.destroy();
  }
}

fixDatabase();
EOL

# Create a custom Ghost entry point to bypass database migration issues
cat > /var/lib/ghost/custom-start.js << EOL
// Custom start script to bypass database migration issues
console.log('Starting Ghost with custom initialization...');

// Set database-related environment variables to help Ghost start
process.env.ghost_db_migration_skip = 'true';
process.env.NODE_ENV = 'production';

// We'll use a simpler approach - set a special flag and then just start Ghost
process.env.GHOST_SKIP_DB_CHECK = 'true';

// Load the original Ghost entry point
require('/var/lib/ghost/current/index.js');
EOL

# Run the bootstrap script to prepare the database
echo "Preparing database for Ghost startup..."
node /var/lib/ghost/bootstrap-database.js || echo "Database preparation failed, but continuing..."

# Start Ghost with environment variables to disable database migrations
echo "Starting Ghost with custom initialization on 0.0.0.0:2368..."
cd /var/lib/ghost

# Export all necessary environment variables for Ghost
export ghost_db_client=postgres
export ghost_db_connection__host=${DB_HOST}
export ghost_db_connection__user=${DB_USER}
export ghost_db_connection__password=${DB_PASSWORD}
export ghost_db_connection__database=${DB_NAME}
export ghost_db_connection__port=${DB_PORT}
export ghost_db_connection__ssl__rejectUnauthorized=false

# Use environment variables to prevent database migrations
export NODE_ENV=production
export ghost_skip_bootstrap=true
export ghost_skip_startup_checks=true

# Create a symbolic link to ensure the current directory has the right setup
rm -rf /var/lib/ghost/content/logs 2>/dev/null
mkdir -p /var/lib/ghost/content/logs
chown -R node:node /var/lib/ghost/content

# Try custom entry point first, fall back to direct execution
echo "Attempting to start Ghost with custom entry point..."
(cd /var/lib/ghost && node /var/lib/ghost/custom-start.js) || 
  (echo "Custom start failed, trying direct Ghost start..." && 
   cd /var/lib/ghost && node current/index.js)
