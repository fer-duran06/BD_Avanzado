// ============================================
// lib/schemas.ts
// Schemas de validación con Zod
// ============================================

import { z } from 'zod';

// ============================================
// Schema base de paginación
// ============================================
export const paginationSchema = z.object({
  page: z
    .string()
    .default('1')
    .transform((val) => parseInt(val, 10))
    .pipe(z.number().int().min(1).max(1000)),
  limit: z
    .string()
    .default('10')
    .transform((val) => parseInt(val, 10))
    .pipe(z.number().int().min(5).max(50)),
});

export type PaginationParams = z.infer<typeof paginationSchema>;

// ============================================
// Schema para ordenamiento
// ============================================
export const sortOrderSchema = z.enum(['asc', 'desc', 'ASC', 'DESC']).default('desc');

export type SortOrder = z.infer<typeof sortOrderSchema>;

// ============================================
// Schema para VIEW 1: Sales by Category
// ============================================
export const salesByCategoryFiltersSchema = z.object({
  page: paginationSchema.shape.page,
  limit: paginationSchema.shape.limit,
  sortBy: z
    .enum([
      'category_name',
      'total_sales',
      'avg_sale',
      'num_transactions',
      'sales_percentage',
      'category_rank',
    ])
    .default('total_sales'),
  sortOrder: sortOrderSchema,
  minSales: z
    .string()
    .optional()
    .transform((val) => (val ? parseFloat(val) : undefined))
    .pipe(z.number().nonnegative().optional()),
});

export type SalesByCategoryFilters = z.infer<typeof salesByCategoryFiltersSchema>;

// ============================================
// Schema para VIEW 2: Customer Lifetime Value
// ============================================
export const customerLifetimeValueFiltersSchema = z.object({
  page: paginationSchema.shape.page,
  limit: paginationSchema.shape.limit,
  sortBy: z
    .enum([
      'customer_name',
      'total_spent',
      'total_orders',
      'avg_order_value',
      'days_since_last_purchase',
    ])
    .default('total_spent'),
  sortOrder: sortOrderSchema,
  customerSegment: z
    .enum(['VIP', 'High Value', 'Medium Value', 'Low Value', 'all'])
    .default('all'),
  minSpent: z
    .string()
    .optional()
    .transform((val) => (val ? parseFloat(val) : undefined))
    .pipe(z.number().nonnegative().optional()),
});

export type CustomerLifetimeValueFilters = z.infer<typeof customerLifetimeValueFiltersSchema>;

// ============================================
// Schema para VIEW 3: Product Performance
// ============================================
export const productPerformanceFiltersSchema = z.object({
  page: paginationSchema.shape.page,
  limit: paginationSchema.shape.limit,
  sortBy: z
    .enum([
      'product_name',
      'total_revenue',
      'units_sold',
      'profit_margin_percent',
      'current_stock',
    ])
    .default('total_revenue'),
  sortOrder: sortOrderSchema,
  stockStatus: z
    .enum(['Out of Stock', 'Low Stock', 'Normal', 'Overstocked', 'all'])
    .default('all'),
});

export type ProductPerformanceFilters = z.infer<typeof productPerformanceFiltersSchema>;

// ============================================
// Schema para VIEW 4: Monthly Sales Trends
// ============================================
export const monthlySalesTrendsFiltersSchema = z.object({
  page: paginationSchema.shape.page,
  limit: paginationSchema.shape.limit,
  sortBy: z
    .enum(['year_month', 'total_sales', 'total_orders', 'sales_growth_percent'])
    .default('year_month'),
  sortOrder: sortOrderSchema,
  year: z
    .string()
    .optional()
    .transform((val) => (val ? parseInt(val, 10) : undefined))
    .pipe(z.number().int().min(2020).max(2030).optional()),
});

export type MonthlySalesTrendsFilters = z.infer<typeof monthlySalesTrendsFiltersSchema>;

// ============================================
// Schema para VIEW 5: Inventory Reorder Analysis
// ============================================
export const inventoryReorderFiltersSchema = z.object({
  page: paginationSchema.shape.page,
  limit: paginationSchema.shape.limit,
  sortBy: z
    .enum([
      'product_name',
      'current_stock',
      'urgency_level',
      'days_until_stockout',
      'units_sold_last_30_days',
    ])
    .default('urgency_level'),
  sortOrder: sortOrderSchema,
  urgencyLevel: z
    .enum(['Critical', 'High', 'Medium', 'Low', 'Normal', 'Discontinued', 'all'])
    .default('all'),
});

export type InventoryReorderFilters = z.infer<typeof inventoryReorderFiltersSchema>;

// ============================================
// Helper para parsear y validar parámetros de URL
// ============================================
export function parseAndValidate<T>(
  schema: z.ZodSchema<T>,
  params: Record<string, string | string[] | undefined>
): { success: true; data: T } | { success: false; error: z.ZodError } {
  const result = schema.safeParse(params);

  if (result.success) {
    return { success: true, data: result.data };
  }

  return { success: false, error: result.error };
}

// ============================================
// Helper para obtener mensaje de error user-friendly
// ============================================
export function getValidationErrorMessage(error: z.ZodError): string {
  const firstError = error.errors[0];
  
  if (!firstError) {
    return 'Error de validación desconocido';
  }

  const field = firstError.path.join('.');
  const message = firstError.message;

  return `${field}: ${message}`;
}
