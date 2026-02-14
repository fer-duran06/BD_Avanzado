-- ============================================
-- 05-indexes.sql
-- Creación de índices para optimización de queries
-- ============================================

-- ============================================
-- ÍNDICE 1: idx_sales_date
-- ============================================
CREATE INDEX idx_sales_date ON sales(sale_date);

COMMENT ON INDEX idx_sales_date IS 
'Índice B-tree en sale_date para acelerar filtros temporales. 
Usado en: view_sales_by_category, view_customer_lifetime_value, view_product_performance, view_monthly_sales_trends';

-- ============================================
-- ÍNDICE 2: idx_sales_product_customer
-- ============================================
CREATE INDEX idx_sales_product_customer ON sales(product_id, customer_id, sale_date);

COMMENT ON INDEX idx_sales_product_customer IS 
'Índice compuesto para optimizar JOINs y filtros en sales. 
Orden: product_id (igualdad), customer_id (igualdad), sale_date (rango/ordenamiento).
Usado en: view_customer_lifetime_value, view_product_performance, view_inventory_reorder_analysis';

-- ============================================
-- ÍNDICE 3: idx_products_category
-- ============================================
CREATE INDEX idx_products_category ON products(category_id, product_id);

COMMENT ON INDEX idx_products_category IS 
'Índice para GROUP BY en categorías. Covering index incluye product_id.
Usado en: view_sales_by_category, view_product_performance';

-- ============================================
-- ÍNDICE 4: idx_sales_date_amount (Partial Index)
-- ============================================
CREATE INDEX idx_sales_date_amount ON sales(sale_date, sale_amount)
WHERE sale_date >= '2024-01-01';

COMMENT ON INDEX idx_sales_date_amount IS 
'Índice parcial para SUM(sale_amount) en datos >= 2024-01-01. 
Index-only scan reduce I/O. Más pequeño que índice completo.
Usado en: Todas las VIEWS que calculan totales de ventas';

-- ============================================
-- ÍNDICE 5: idx_products_stock (Partial Index)
-- ============================================
CREATE INDEX idx_products_stock ON products(stock_quantity, reorder_level, product_id)
WHERE discontinued = FALSE AND stock_quantity <= reorder_level * 2;

COMMENT ON INDEX idx_products_stock IS 
'Índice parcial para análisis de inventario. Solo productos activos con stock bajo.
Condición: discontinued = FALSE AND stock_quantity <= reorder_level * 2.
Usado en: view_inventory_reorder_analysis';

-- ============================================
-- Actualizar estadísticas para el optimizador
-- ============================================
ANALYZE sales;
ANALYZE products;
ANALYZE customers;
ANALYZE categories;

-- ============================================
-- Verificar índices creados
-- ============================================
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- ============================================
-- EVIDENCIA DE PERFORMANCE CON EXPLAIN ANALYZE
-- ============================================

-- EXPLAIN 1: Filtro por fecha en sales
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    COUNT(*) as total_sales,
    SUM(sale_amount) as total_amount,
    AVG(sale_amount) as avg_amount
FROM sales
WHERE sale_date >= '2024-01-01';

-- EXPLAIN 2: JOIN products-sales con índice
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    p.product_id,
    p.product_name,
    SUM(s.sale_amount) as total_sales
FROM products p
JOIN sales s ON p.product_id = s.product_id
WHERE s.sale_date >= '2024-01-01'
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC
LIMIT 10;

-- EXPLAIN 3: Productos con stock bajo
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    product_id,
    product_name,
    stock_quantity,
    reorder_level
FROM products
WHERE discontinued = FALSE
AND stock_quantity <= reorder_level * 2
ORDER BY stock_quantity ASC;

-- ============================================
-- Mensaje de confirmación
-- ============================================
SELECT '✅ 5 índices creados exitosamente y optimizador actualizado' as status;
SELECT '📊 EXPLAIN ANALYZE ejecutado correctamente' as note;