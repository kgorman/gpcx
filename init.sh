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

# Make sure config file is accessible
echo "Checking config file..."
cat /var/lib/ghost/config.production.json | grep -v password | grep -v PASSWORD

# Set the NODE_ENV to production
export NODE_ENV=production

# Start Ghost with the config file
echo "Starting Ghost on 0.0.0.0:2368..."
cd /var/lib/ghost
exec node current/index.js
