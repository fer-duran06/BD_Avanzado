// app/api/health/route.ts
import { NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function GET() {
  try {
    // Verificar conexión a base de datos
    const result = await query('SELECT 1 as health');
    
    if (result.rows[0].health === 1) {
      return NextResponse.json({
        status: 'healthy',
        database: 'connected',
        timestamp: new Date().toISOString(),
      });
    }
    
    return NextResponse.json(
      { status: 'unhealthy', database: 'disconnected' },
      { status: 503 }
    );
  } catch (error) {
    return NextResponse.json(
      {
        status: 'unhealthy',
        database: 'error',
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 503 }
    );
  }
}
