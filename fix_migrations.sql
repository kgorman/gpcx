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
