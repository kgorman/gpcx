-- fix_migrations.sql
-- This script fixes potential issues with Ghost's migrations tables

-- Drop primary key constraint if it exists
ALTER TABLE IF EXISTS migrations_lock DROP CONSTRAINT IF EXISTS migrations_lock_pkey CASCADE;

-- Make sure the table has the right structure
CREATE TABLE IF NOT EXISTS migrations_lock (
    lock_key VARCHAR(255) NOT NULL,
    locked BOOLEAN DEFAULT false NOT NULL,
    CONSTRAINT migrations_lock_pkey PRIMARY KEY (lock_key)
);

-- Initialize the lock if it doesn't exist
INSERT INTO migrations_lock (lock_key, locked)
SELECT '1', false
WHERE NOT EXISTS (SELECT 1 FROM migrations_lock WHERE lock_key = '1');

-- Reset the lock regardless (this fixes locked migration issues)
UPDATE migrations_lock SET locked = false WHERE lock_key = '1';

-- Also fix the migrations table if it exists
CREATE TABLE IF NOT EXISTS migrations (
    id INTEGER,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(255) NOT NULL,
    CONSTRAINT migrations_pkey PRIMARY KEY (id)
);
