#!/bin/bash
set -o errexit

# Debug: Print environment variables (excluding sensitive data)
echo "Environment variables:"
env | grep -v PASSWORD | grep -v password | sort

echo "Database connection parameters:"
echo "Host: ${database__connection__host}"
echo "Port: ${database__connection__port:-5432}"
echo "User: ${database__connection__user}"
echo "Database: ${database__connection__database}"
echo "URL: ${url:-http://localhost:2368}"

# Copy the content directories if they don't exist
baseDir="$GHOST_INSTALL/content.orig"
for src in "$baseDir"/*/ "$baseDir"/themes/*; do
    src="${src%/}"
    target="$GHOST_CONTENT/${src#$baseDir/}"
    mkdir -p "$(dirname "$target")"
    if [ ! -e "$target" ]; then
        tar -cC "$(dirname "$src")" "$(basename "$src")" | tar -xC "$(dirname "$target")"
    fi
done

# Create config.production.json directly in Ghost's directory
echo "Creating Ghost configuration..."

# Create a more explicit configuration file
cat > config.production.json << EOF
{
  "url": "${url:-http://localhost:2368}",
  "server": {
    "port": 2368,
    "host": "0.0.0.0"
  },
  "database": {
    "client": "postgres",
    "connection": {
      "host": "${database__connection__host:-localhost}",
      "port": ${database__connection__port:-5432},
      "user": "${database__connection__user:-postgres}",
      "password": "${database__connection__password}",
      "database": "${database__connection__database:-ghost}",
      "ssl": {
        "rejectUnauthorized": false,
        "ca": null,
        "key": null,
        "cert": null
      }
    }
  },
  "logging": {
    "level": "debug",
    "transports": ["stdout"]
  },
  "paths": {
    "contentPath": "/var/lib/ghost/content"
  },
  "adapters": {
    "storage": {
      "active": "LocalFileStorage"
    }
  }
}
EOF

# Show the config (without sensitive info)
echo "Ghost configuration (passwords hidden):"
cat config.production.json | grep -v password | grep -v PASSWORD

# Make sure the pg module is installed
echo "Installing pg module for PostgreSQL support..."
npm install --no-save pg knex@"<1.0.0"

# Update the URL using the updateConfig.js script
node updateConfig.js

# Debug: Test database connection
echo "Testing PostgreSQL connection..."
if [ -n "${database__connection__host}" ]; then
  export PGPASSWORD="${database__connection__password}"
  echo "Attempting to connect to PostgreSQL at ${database__connection__host}:${database__connection__port:-5432}..."
  # Try to connect, but don't fail if it doesn't work
  pg_isready -h "${database__connection__host}" -p "${database__connection__port:-5432}" -U "${database__connection__user}" || echo "Could not connect to PostgreSQL, but continuing anyway"
else
  echo "No database host specified in environment variables"
fi

# Copy knexfile to the right location
if [ -f "/var/lib/ghost/knexfile.js" ]; then
  echo "Using custom knexfile.js for database migrations"
  cp /var/lib/ghost/knexfile.js /var/lib/ghost/current/
fi

# Fix for database migration issues
echo "Preparing database for Ghost migrations..."
export PGPASSWORD="${database__connection__password}"
DB_HOST="${database__connection__host}"
DB_PORT="${database__connection__port:-5432}"
DB_USER="${database__connection__user}"
DB_NAME="${database__connection__database}"

# Apply the fix_migrations.sql script to handle migration table issues
if [ -f "/var/lib/ghost/fix_migrations.sql" ]; then
  echo "Applying database migration fixes..."
  
  # Try to connect and run the fix script
  PGPASSWORD=$database__connection__password psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "/var/lib/ghost/fix_migrations.sql" 2>/dev/null || echo "Could not apply migration fixes, but continuing anyway"
  
  echo "Database preparation completed"
else
  echo "Migration fix script not found, skipping database preparation"
fi

# Fix for migration lock issue - reset the lock with both SQL and Node.js
echo "Checking for migration lock..."

# Reset the lock using SQL first
LOCK_CHECK=$(PGPASSWORD=$database__connection__password psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'migrations_lock');" 2>/dev/null || echo "false")

if [[ "$LOCK_CHECK" == *"t"* ]]; then
  echo "Migrations lock table exists, resetting lock status via SQL..."
  
  # Reset the migration lock
  PGPASSWORD=$database__connection__password psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "UPDATE migrations_lock SET locked = false WHERE lock_key = '1';" 2>/dev/null || echo "Could not reset migration lock via SQL, continuing anyway"
fi

# Also try to initialize the database using Node.js
if [ -f "/var/lib/ghost/init_db.js" ]; then
  echo "Running database initialization script..."
  node /var/lib/ghost/init_db.js
fi

# Double-check the lock
echo "Final migration lock status check..."
LOCK_STATUS=$(PGPASSWORD=$database__connection__password psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT locked FROM migrations_lock WHERE lock_key = '1';" 2>/dev/null || echo "unknown")
echo "Migration lock status: $LOCK_STATUS"

# Start Ghost with the config file and disable certificate validation
echo "Starting Ghost with certificate validation disabled..."
export NODE_TLS_REJECT_UNAUTHORIZED=0
node current/index.js
