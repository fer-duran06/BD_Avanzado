// lib/db.ts
import { Pool, QueryResult } from 'pg';

// ============================================
// Configuración del Pool de PostgreSQL
// ============================================

const DATABASE_URL = process.env.DATABASE_URL;

// Validación de variable de entorno (solo en runtime, no en build)
if (!DATABASE_URL && process.env.NODE_ENV !== 'production') {
  console.warn('⚠️  DATABASE_URL no está definida. Conexión fallará en runtime.');
}

const pool = new Pool({
  connectionString: DATABASE_URL,
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// ============================================
// Función para ejecutar queries
// ============================================

export async function query(
  text: string,
  params?: any[]
): Promise<QueryResult<any>> {
  const start = Date.now();
  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    
    // Log solo en desarrollo
    if (process.env.NODE_ENV === 'development') {
      console.log('✅ Query ejecutada:', { text, duration: `${duration}ms`, rows: result.rowCount });
    }
    
    return result;
  } catch (error) {
    console.error('❌ Error ejecutando query:', {
      text,
      params,
      error: error instanceof Error ? error.message : 'Unknown error',
    });
    throw error;
  }
}

// ============================================
// Health check
// ============================================

export async function checkConnection(): Promise<boolean> {
  try {
    await pool.query('SELECT 1');
    return true;
  } catch {
    return false;
  }
}

// ============================================
// Helpers
// ============================================

export async function getOne<T = any>(text: string, params?: any[]): Promise<T | null> {
  const result = await query(text, params);
  return result.rows[0] || null;
}

export async function getMany<T = any>(text: string, params?: any[]): Promise<T[]> {
  const result = await query(text, params);
  return result.rows;
}