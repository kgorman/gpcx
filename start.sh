#!/bin/bash
set -e

echo "Starting Ghost setup..."

# Create content directories if they don't exist
mkdir -p /var/lib/ghost/content/data
mkdir -p /var/lib/ghost/content/images
mkdir -p /var/lib/ghost/content/themes
mkdir -p /var/lib/ghost/content/logs
mkdir -p /var/lib/ghost/content/adapters
mkdir -p /var/lib/ghost/content/settings

# Set correct permissions
chown -R node:node /var/lib/ghost/content

# Debug: Print environment variables (excluding sensitive data)
echo "Environment variables:"
env | grep -v PASSWORD | grep -v password | sort

# Create config file from environment variables
echo "Creating Ghost configuration..."

# Get database connection info from environment
DB_HOST="${database__connection__host}"
DB_PORT="${database__connection__port:-5432}"
DB_USER="${database__connection__user}"
DB_PASSWORD="${database__connection__password}"
DB_NAME="${database__connection__database}"
SITE_URL="${url}"

# Create Ghost configuration
cat > /var/lib/ghost/config.production.json << EOF
{
  "url": "${SITE_URL}",
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
    }
  },
  "logging": {
    "level": "info",
    "transports": ["stdout"]
  },
  "paths": {
    "contentPath": "/var/lib/ghost/content"
  }
}
EOF

echo "Configuration created."

# Install pg package directly in Ghost's node_modules
cd /var/lib/ghost
npm install --no-save pg knex@"<1.0.0"

# Ensure proper permissions on config
chmod 644 /var/lib/ghost/config.production.json
chown node:node /var/lib/ghost/config.production.json

# Show the config (without sensitive info)
echo "Ghost configuration (passwords hidden):"
cat /var/lib/ghost/config.production.json | grep -v password | grep -v PASSWORD

# Debug: Test database connection
echo "Testing PostgreSQL connection..."
export PGPASSWORD="${DB_PASSWORD}"
pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" || echo "Could not connect to PostgreSQL, but continuing anyway"

# Start Ghost
echo "Starting Ghost..."
cd /var/lib/ghost
exec su-exec node node current/index.js
