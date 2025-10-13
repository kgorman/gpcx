#!/bin/bash
# This script helps initialize the Ghost blog on first deployment

# Debug: Print all environment variables (hiding passwords)
echo "===== ENVIRONMENT VARIABLES ====="
env | grep -v PASSWORD | grep -v password
echo "================================="

# Extract database connection info from Ghost's environment variables
# Try both formats of environment variables to ensure we get the right ones
DB_HOST="${database__connection__host:-$DATABASE_HOST}"
DB_USER="${database__connection__user:-$DATABASE_USER}"
DB_PASSWORD="${database__connection__password:-$DATABASE_PASSWORD}"
DB_NAME="${database__connection__database:-$DATABASE_NAME}"

# Display connection information (without credentials)
echo "Database connection info:"
echo "Host: $DB_HOST"
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Port: ${database__connection__port:-5432}"

# Skip PostgreSQL readiness check if needed
if [[ "$DB_HOST" == "" || "$DB_USER" == "" ]]; then
    echo "WARNING: Missing database connection information. Skipping database readiness check."
    echo "This might cause Ghost to fail to start properly."
else
    # Try to connect to PostgreSQL with a timeout
    echo "Trying to connect to PostgreSQL..."
    export PGPASSWORD="$DB_PASSWORD"
    
    # Use a timeout to prevent infinite waiting
    TIMEOUT=60
    START_TIME=$(date +%s)
    
    while true; do
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - START_TIME))
        
        if [ $ELAPSED -gt $TIMEOUT ]; then
            echo "Timeout waiting for PostgreSQL. Will try to start Ghost anyway."
            break
        fi
        
        # Try to connect
        if pg_isready -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t 5; then
            echo "PostgreSQL server is available!"
            break
        fi
        
        echo "Waiting for PostgreSQL server to be available... ($ELAPSED seconds elapsed)"
        sleep 5
    done
fi

# Try to check if database exists, but continue if it fails
if [[ "$DB_HOST" != "" && "$DB_USER" != "" && "$DB_NAME" != "" ]]; then
    if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" > /dev/null 2>&1; then
        echo "Database $DB_NAME already exists. Skipping initialization."
    else
        echo "Attempting to create database $DB_NAME..."
        PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -c "CREATE DATABASE $DB_NAME" postgres || echo "Failed to create database, it may already exist or we lack permissions"
    fi
else
    echo "Missing database configuration. Skipping database initialization."
fi

# Create the content directory structure if it doesn't exist
mkdir -p /var/lib/ghost/content/data
mkdir -p /var/lib/ghost/content/images
mkdir -p /var/lib/ghost/content/themes
mkdir -p /var/lib/ghost/content/logs
mkdir -p /var/lib/ghost/content/adapters
mkdir -p /var/lib/ghost/content/settings

# Make sure permissions are correct
chown -R node:node /var/lib/ghost/content

# Set server configuration to bind to all interfaces
export server__host="0.0.0.0"
export server__port=2368

# Start Ghost with explicit configuration to ensure it picks up environment variables
echo "Starting Ghost on 0.0.0.0:2368..."
exec node current/index.js
