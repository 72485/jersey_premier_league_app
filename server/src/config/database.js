const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: parseInt(process.env.DATABASE_POOL_SIZE) || 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

pool.on('connect', () => {
  console.log('Database pool connection established');
});

/**
 * Query helper function
 * @param {string} text - SQL query text
 * @param {array} params - Query parameters
 */
const query = (text, params) => {
  const start = Date.now();
  return pool.query(text, params).then((res) => {
    const duration = Date.now() - start;
    console.log('Executed query', { text, params, duration, rows: res.rowCount });
    return res;
  }).catch((err) => {
    console.error('Database query error', { text, params, error: err.message });
    throw err;
  });
};

/**
 * Get a client from the pool for transactions
 */
const getClient = () => pool.connect();

module.exports = {
  query,
  getClient,
  pool,
};
