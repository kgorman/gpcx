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

# Start Ghost with the config file and disable certificate validation
echo "Starting Ghost..."
export NODE_TLS_REJECT_UNAUTHORIZED=0
node current/index.js
