#!/bin/bash
# This script helps initialize the Ghost blog on first deployment

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
export PGPASSWORD="$DATABASE_PASSWORD"
until pg_isready -h "$DATABASE_HOST" -U "$DATABASE_USER" -q; do
    echo "Waiting for PostgreSQL server to be available..."
    sleep 5
done

# Check if the database exists
if psql -h "$DATABASE_HOST" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c "SELECT 1" > /dev/null 2>&1; then
    echo "Database $DATABASE_NAME already exists. Skipping initialization."
else
    echo "Creating database $DATABASE_NAME..."
    psql -h "$DATABASE_HOST" -U "$DATABASE_USER" -c "CREATE DATABASE $DATABASE_NAME" postgres
    echo "Database created successfully!"
fi

# Start Ghost
echo "Starting Ghost..."
exec node current/index.js
