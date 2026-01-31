import { Pool } from 'pg';

let pool: Pool;

if (!global.pool) {
  global.pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  });
}
pool = global.pool;

declare global {
  var pool: Pool | undefined;
}

export default pool;