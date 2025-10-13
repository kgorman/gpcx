// init_db.js - Initialize the Ghost database and reset migration locks
const knex = require('knex')({
  client: 'pg',
  connection: {
    host: process.env.database__connection__host,
    user: process.env.database__connection__user,
    password: process.env.database__connection__password,
    database: process.env.database__connection__database,
    port: process.env.database__connection__port || 5432,
    ssl: { rejectUnauthorized: false }
  }
});

console.log('Initializing database and checking migration locks...');

async function init() {
  try {
    // Check if migrations_lock table exists
    const hasLockTable = await knex.schema.hasTable('migrations_lock');
    
    if (hasLockTable) {
      console.log('Found migrations_lock table, resetting lock...');
      await knex('migrations_lock').update({ locked: false }).where({ lock_key: '1' });
      console.log('Successfully reset migration lock');
    } else {
      console.log('migrations_lock table not found, will be created by Ghost');
    }

    // Check if any migrations were left incomplete
    const hasMigrationsTable = await knex.schema.hasTable('migrations');
    if (hasMigrationsTable) {
      console.log('Found migrations table, checking status...');
      const latestMigration = await knex('migrations').orderBy('id', 'desc').first();
      console.log('Latest migration:', latestMigration ? JSON.stringify(latestMigration) : 'None');
    }

    console.log('Database initialization completed successfully');
  } catch (error) {
    console.error('Error initializing database:', error);
    // Don't exit with error - let Ghost handle it
  } finally {
    // Always close the connection
    await knex.destroy();
  }
}

init();
