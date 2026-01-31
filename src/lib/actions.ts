'use server'

import pool from './db';
import { PaginationSchema, YearFilterSchema } from './validation';

type ActionResponse = {
  data?: any[];
  error?: string;
  pagination?: { page: number; limit: number };
};

export async function getReportData(reportId: string, searchParams: any): Promise<ActionResponse> {
  const pagination = PaginationSchema.safeParse(searchParams);
  
  if (!pagination.success) {
    return { error: "Parámetros de paginación inválidos" };
  }

  const { page, limit } = pagination.data;
  const offset = (page - 1) * limit;
  const client = await pool.connect();

  try {
    let query = '';
    let params: any[] = [];

    switch (reportId) {
      case '1': 
        query = `SELECT * FROM vw_top_productos_E ORDER BY ventas_total DESC LIMIT $1 OFFSET $2`;
        params = [limit, offset];
        break;
      case '2': 
        const yearParsed = YearFilterSchema.safeParse(searchParams.anio);
        const year = yearParsed.success ? yearParsed.data : undefined;
        if (year) {
          query = `SELECT * FROM vw_ventas_mensuales_E WHERE anio = $1 ORDER BY mes DESC`;
          params = [year];
        } else {
          query = `SELECT * FROM vw_ventas_mensuales_E ORDER BY anio DESC, mes DESC LIMIT $1 OFFSET $2`;
          params = [limit, offset];
        }
        break;
      case '3': 
        query = `SELECT * FROM vw_clientes_valor_E ORDER BY gasto_total DESC LIMIT $1 OFFSET $2`;
        params = [limit, offset];
        break; 
      case '4': 
        query = `SELECT * FROM vw_categorias_performance_E ORDER BY ventas_total DESC`;
        params = []; 
        break;
      case '5': 
        query = `SELECT * FROM vw_ranking_productos_E ORDER BY ranking_global ASC LIMIT $1 OFFSET $2`;
        params = [limit, offset];
        break;
      default:
        return { error: "Reporte no encontrado" };
    }

    const res = await client.query(query, params);
    return { data: res.rows, pagination: { page, limit } };

  } catch (err) {
    console.error("Error BD:", err);
    return { error: "Error al conectar con la base de datos." };
  } finally {
    client.release();
  }
}