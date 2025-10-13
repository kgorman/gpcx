#!/bin/bash
# This script helps initialize the Ghost blog on first deployment

# Extract database connection info from Ghost's environment variables
DB_HOST="${database__connection__host}"
DB_USER="${database__connection__user}"
DB_PASSWORD="${database__connection__password}"
DB_NAME="${database__connection__database}"

# Display connection information (without credentials)
echo "Database connection info:"
echo "Host: $DB_HOST"
echo "Database: $DB_NAME"
echo "User: $DB_USER"

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
export PGPASSWORD="$DB_PASSWORD"
until pg_isready -h "$DB_HOST" -U "$DB_USER" -q; do
    echo "Waiting for PostgreSQL server to be available..."
    sleep 5
done

# Check if the database exists
if psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" > /dev/null 2>&1; then
    echo "Database $DB_NAME already exists. Skipping initialization."
else
    echo "Creating database $DB_NAME..."
    psql -h "$DB_HOST" -U "$DB_USER" -c "CREATE DATABASE $DB_NAME" postgres
    echo "Database created successfully!"
fi

# Start Ghost
echo "Starting Ghost..."
exec node current/index.js
