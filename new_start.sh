#!/bin/bash
set -e

echo "Environment variables:"
env | grep -v PASSWORD | grep -v password | sort

# Set environment variables with defaults
export url=${url:-http://localhost:2368}
export NODE_ENV=${NODE_ENV:-production}

echo "Database connection parameters:"
echo "Host: ${database__connection__host}"
echo "Port: ${database__connection__port:-5432}"
echo "User: ${database__connection__user}"
echo "Database: ${database__connection__database}"
echo "URL: ${url}"

# Create Ghost content directories if they don't exist
mkdir -p "$GHOST_CONTENT/data"
mkdir -p "$GHOST_CONTENT/images"
mkdir -p "$GHOST_CONTENT/themes"
mkdir -p "$GHOST_CONTENT/logs"
mkdir -p "$GHOST_CONTENT/adapters/storage"
mkdir -p "$GHOST_CONTENT/settings"

# Copy the default theme
if [ -d "$GHOST_INSTALL/content/themes/casper" ]; then
  echo "Copying default Casper theme..."
  cp -r "$GHOST_INSTALL/content/themes/casper" "$GHOST_CONTENT/themes/"
fi

# Create a Ghost configuration file with SSL settings for PostgreSQL
echo "Creating Ghost configuration..."
cat > "$GHOST_CONTENT/config.production.json" << EOL
{
  "url": "${url}",
  "server": {
    "port": 2368,
    "host": "0.0.0.0"
  },
  "database": {
    "client": "postgres",
    "connection": {
      "host": "${database__connection__host}",
      "port": ${database__connection__port:-5432},
      "user": "${database__connection__user}",
      "password": "${database__connection__password}",
      "database": "${database__connection__database}",
      "ssl": {
        "rejectUnauthorized": false
      }
    },
    "debug": false
  },
  "logging": {
    "level": "info",
    "transports": ["stdout"]
  },
  "paths": {
    "contentPath": "${GHOST_CONTENT}"
  },
  "adapters": {
    "storage": {
      "active": "LocalFileStorage"
    }
  },
  "mail": {
    "transport": "Direct"
  }
}
EOL

# Also create config in the standard location
cp "$GHOST_CONTENT/config.production.json" "$GHOST_INSTALL/config.production.json"

# Display configuration (hide password)
echo "Ghost configuration (passwords hidden):"
cat "$GHOST_CONTENT/config.production.json" | grep -v password | grep -v PASSWORD

# Install pg module for PostgreSQL support
echo "Installing pg module for PostgreSQL support..."
cd "$GHOST_INSTALL"
npm install --no-save pg@8.7.1 knex@0.95.15 sqlite3

# Create a knexfile.js for direct database access
cat > "$GHOST_INSTALL/knexfile.js" << EOL
module.exports = {
  client: 'pg',
  connection: {
    host: '${database__connection__host}',
    port: ${database__connection__port:-5432},
    user: '${database__connection__user}',
    password: '${database__connection__password}',
    database: '${database__connection__database}',
    ssl: { rejectUnauthorized: false }
  },
  debug: false
};
EOL

# Test PostgreSQL connection
echo "Testing PostgreSQL connection..."
echo "Attempting to connect to PostgreSQL at ${database__connection__host}:${database__connection__port:-5432}..."

# Use pg_isready to check if PostgreSQL is accepting connections
export PGPASSWORD="${database__connection__password}" 
pg_isready -h "${database__connection__host}" -p "${database__connection__port:-5432}" -U "${database__connection__user}" || {
  echo "PostgreSQL connection failed"
  echo "Waiting 5 seconds and trying again..."
  sleep 5
  pg_isready -h "${database__connection__host}" -p "${database__connection__port:-5432}" -U "${database__connection__user}" || {
    echo "PostgreSQL connection failed again, but continuing anyway"
  }
}

# Create a script to initialize the database tables
cat > "$GHOST_INSTALL/setup_db.js" << EOL
const knex = require('knex')(require('./knexfile.js'));

async function setupDatabase() {
  try {
    console.log('Starting database setup...');
    
    // Create or reset migrations_lock table
    try {
      console.log('Setting up migrations_lock table...');
      await knex.schema.dropTableIfExists('migrations_lock');
      await knex.schema.createTable('migrations_lock', table => {
        table.string('lock_key').primary();
        table.boolean('locked').defaultTo(false);
      });
      await knex('migrations_lock').insert({ lock_key: '1', locked: false });
      console.log('migrations_lock table created successfully');
    } catch (err) {
      console.error('Error with migrations_lock table:', err.message);
    }
    
    // Create migrations table
    try {
      console.log('Setting up migrations table...');
      await knex.schema.dropTableIfExists('migrations');
      await knex.schema.createTable('migrations', table => {
        table.increments('id').primary();
        table.string('name');
        table.string('version');
      });
      console.log('migrations table created successfully');
    } catch (err) {
      console.error('Error with migrations table:', err.message);
    }
    
    // Create the settings table if it doesn't exist
    try {
      const hasSettingsTable = await knex.schema.hasTable('settings');
      if (!hasSettingsTable) {
        console.log('Creating settings table...');
        await knex.schema.createTable('settings', table => {
          table.string('key').primary();
          table.text('value');
          table.string('type');
          table.string('group');
        });
        
        // Insert minimal required settings
        await knex('settings').insert([
          { key: 'active_theme', value: 'casper', type: 'string', group: 'theme' },
          { key: 'is_private', value: 'false', type: 'boolean', group: 'private' },
          { key: 'title', value: 'Ghost Blog', type: 'string', group: 'blog' },
          { key: 'description', value: 'Just a blogging platform', type: 'string', group: 'blog' }
        ]);
        console.log('settings table created successfully');
      }
    } catch (err) {
      console.error('Error with settings table:', err.message);
    }
    
    console.log('Database setup complete');
  } catch (error) {
    console.error('Error setting up database:', error);
  } finally {
    await knex.destroy();
  }
}

setupDatabase();
EOL

# Run the database setup script
echo "Setting up database tables..."
node "$GHOST_INSTALL/setup_db.js"

# Create a flag file to skip migrations
touch "$GHOST_CONTENT/.skip-migrations"

# Set environment variables to help bypass migrations
export NODE_TLS_REJECT_UNAUTHORIZED=0
export ghost_skip_migrations=true
export ghost_NODE_VERSION_CHECK=false

# Start Ghost
echo "Starting Ghost..."
cd "$GHOST_INSTALL"
node current/index.js
