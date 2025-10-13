// knexfile.js - Used by Ghost's database migration system
// This helps handle SSL certificate issues with PostgreSQL

module.exports = {
  client: 'pg',
  connection: {
    host: process.env.database__connection__host,
    user: process.env.database__connection__user,
    password: process.env.database__connection__password,
    database: process.env.database__connection__database,
    port: process.env.database__connection__port || 5432,
    ssl: {
      rejectUnauthorized: false,
      ca: null,
      key: null,
      cert: null
    }
  },
  migrations: {
    tableName: 'migrations',
    directory: './migrations'
  },
  debug: true
};
