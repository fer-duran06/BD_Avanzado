// ============================================
// lib/reports.ts
// Capa de lógica de negocio para reportes
// ============================================

import { query } from './db';

// ============================================
// Metadata de reportes
// ============================================

export const REPORTS_METADATA = [
  {
    id: 1,
    title: 'Ventas por Categoría',
    description: 'Análisis de ventas totales, ranking y porcentaje por categoría de producto',
    viewName: 'view_sales_by_category',
    icon: '📊',
  },
  {
    id: 2,
    title: 'Valor de Vida del Cliente',
    description: 'Valor total, frecuencia y segmentación de clientes (CLV)',
    viewName: 'view_customer_lifetime_value',
    icon: '👥',
  },
  {
    id: 3,
    title: 'Desempeño de Productos',
    description: 'Análisis de ventas, inventario y rentabilidad por producto',
    viewName: 'view_product_performance',
    icon: '📦',
  },
  {
    id: 4,
    title: 'Tendencias Mensuales',
    description: 'Análisis de ventas mes a mes con crecimiento y comparaciones',
    viewName: 'view_monthly_sales_trends',
    icon: '📈',
  },
  {
    id: 5,
    title: 'Análisis de Inventario',
    description: 'Productos que necesitan reorden basado en stock y demanda',
    viewName: 'view_inventory_reorder_analysis',
    icon: '📋',
  },
];

// ============================================
// Función genérica para obtener datos de reportes
// ============================================

export async function getReportData(reportId: number, page = 1, limit = 10) {
  const report = REPORTS_METADATA.find(r => r.id === reportId);
  
  if (!report) {
    throw new Error(`Reporte ${reportId} no encontrado`);
  }
  
  const offset = (page - 1) * limit;
  
  // Query con paginación
  const sql = `
    SELECT * 
    FROM ${report.viewName}
    LIMIT $1 OFFSET $2
  `;
  
  const result = await query(sql, [limit, offset]);
  
  // Contar total para paginación
  const countSql = `SELECT COUNT(*) FROM ${report.viewName}`;
  const countResult = await query(countSql);
  
  const total = parseInt(countResult.rows[0].count);
  
  return {
    data: result.rows,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
    metadata: report,
  };
}

// ============================================
// Obtener KPIs de un reporte
// ============================================

export async function getReportKPIs(reportId: number) {
  const report = REPORTS_METADATA.find(r => r.id === reportId);
  
  if (!report) {
    return [];
  }
  
  // KPIs específicos por reporte
  switch (reportId) {
    case 1: // Ventas por Categoría
      const cat = await query(`
        SELECT 
          COUNT(*) as total_categories,
          SUM(total_sales)::NUMERIC as total_sales,
          AVG(sales_percentage)::NUMERIC as avg_percentage
        FROM view_sales_by_category
      `);
      return [
        { label: 'Total Categorías', value: cat.rows[0].total_categories },
        { label: 'Ventas Totales', value: `$${parseFloat(cat.rows[0].total_sales || 0).toLocaleString()}` },
        { label: 'Promedio %', value: `${parseFloat(cat.rows[0].avg_percentage || 0).toFixed(1)}%` },
      ];
      
    case 2: // Valor de Vida del Cliente
      const clv = await query(`
        SELECT 
          COUNT(*) as total_customers,
          SUM(total_spent)::NUMERIC as total_revenue,
          AVG(total_orders)::NUMERIC as avg_orders
        FROM view_customer_lifetime_value
      `);
      return [
        { label: 'Total Clientes', value: clv.rows[0].total_customers },
        { label: 'Ingresos Totales', value: `$${parseFloat(clv.rows[0].total_revenue || 0).toLocaleString()}` },
        { label: 'Promedio Órdenes', value: parseFloat(clv.rows[0].avg_orders || 0).toFixed(1) },
      ];
      
    case 3: // Desempeño de Productos
      const prod = await query(`
        SELECT 
          COUNT(*) as total_products,
          SUM(total_revenue)::NUMERIC as total_revenue,
          AVG(profit_margin_percent)::NUMERIC as avg_margin
        FROM view_product_performance
      `);
      return [
        { label: 'Total Productos', value: prod.rows[0].total_products },
        { label: 'Ingresos Totales', value: `$${parseFloat(prod.rows[0].total_revenue || 0).toLocaleString()}` },
        { label: 'Margen Promedio', value: `${parseFloat(prod.rows[0].avg_margin || 0).toFixed(1)}%` },
      ];
      
    case 4: // Tendencias Mensuales
      const trends = await query(`
        SELECT 
          COUNT(*) as total_months,
          MAX(total_sales)::NUMERIC as max_sales,
          AVG(sales_growth_percent)::NUMERIC as avg_growth
        FROM view_monthly_sales_trends
      `);
      return [
        { label: 'Meses Analizados', value: trends.rows[0].total_months },
        { label: 'Ventas Máximas', value: `$${parseFloat(trends.rows[0].max_sales || 0).toLocaleString()}` },
        { label: 'Crecimiento Promedio', value: `${parseFloat(trends.rows[0].avg_growth || 0).toFixed(1)}%` },
      ];
      
    case 5: // Análisis de Inventario
      const inv = await query(`
        SELECT 
          COUNT(*) as total_products,
          SUM(CASE WHEN urgency_level = 'Critical' THEN 1 ELSE 0 END) as critical_items,
          SUM(recommended_order_qty) as total_to_order
        FROM view_inventory_reorder_analysis
      `);
      return [
        { label: 'Productos Analizados', value: inv.rows[0].total_products },
        { label: 'Items Críticos', value: inv.rows[0].critical_items },
        { label: 'Total a Ordenar', value: inv.rows[0].total_to_order },
      ];
      
    default:
      return [];
  }
}