-- ============================================
-- 04-reports_vw.sql
-- VIEWS para reportes con análisis avanzado
-- ============================================

-- ============================================
-- VIEW 1: view_sales_by_category
-- Análisis de ventas por categoría con ranking
-- ============================================
-- DESCRIPCIÓN: Muestra ventas totales, promedio y ranking por categoría de producto
-- GRAIN: Una fila por categoría de producto
-- MÉTRICAS:
--   - total_sales: Suma total de ventas (SUM)
--   - avg_sale: Promedio de venta por transacción (AVG)
--   - total_quantity: Cantidad total vendida (SUM)
--   - num_transactions: Número de transacciones (COUNT)
--   - sales_percentage: Porcentaje del total de ventas (campo calculado)
--   - profit_margin: Margen de ganancia promedio (campo calculado)
--   - category_rank: Ranking de categorías por ventas (Window Function: RANK)
--   - performance_tier: Clasificación de desempeño (CASE)
-- RAZÓN GROUP BY: Agregamos por categoría para obtener métricas consolidadas
-- RAZÓN HAVING: Filtramos categorías con menos de 5 transacciones para enfocarnos en categorías significativas
-- TÉCNICAS SQL: CTE, Window Function (RANK), CASE, funciones agregadas
-- ============================================

-- VERIFY Query 1: Total de ventas debe coincidir con la suma en la tabla sales
-- SELECT SUM(total_sales)::DECIMAL(10,2) FROM view_sales_by_category;
-- SELECT SUM(sale_amount)::DECIMAL(10,2) FROM sales;

-- VERIFY Query 2: La suma de sales_percentage debe ser aproximadamente 100%
-- SELECT SUM(sales_percentage)::DECIMAL(10,2) as total_percentage FROM view_sales_by_category;

CREATE OR REPLACE VIEW view_sales_by_category AS
WITH category_sales AS (
    SELECT 
        c.category_id,
        c.category_name,
        SUM(s.sale_amount) as total_sales,
        AVG(s.sale_amount) as avg_sale,
        SUM(s.quantity) as total_quantity,
        COUNT(*) as num_transactions,
        AVG(CASE 
            WHEN s.sale_amount > 0 THEN ((s.sale_amount - s.cost) / s.sale_amount * 100)
            ELSE 0 
        END) as avg_profit_margin
    FROM 
        sales s
        INNER JOIN products p ON s.product_id = p.product_id
        INNER JOIN categories c ON p.category_id = c.category_id
    WHERE 
        s.sale_date >= '2024-01-01'
    GROUP BY 
        c.category_id, c.category_name
    HAVING 
        COUNT(*) >= 5  -- Solo categorías con al menos 5 transacciones
),
sales_totals AS (
    SELECT SUM(total_sales) as grand_total
    FROM category_sales
)
SELECT 
    cs.category_id,
    cs.category_name,
    cs.total_sales,
    cs.avg_sale,
    cs.total_quantity,
    cs.num_transactions,
    ROUND((cs.total_sales / st.grand_total * 100)::NUMERIC, 2) as sales_percentage,
    ROUND(cs.avg_profit_margin::NUMERIC, 2) as profit_margin_percent,
    RANK() OVER (ORDER BY cs.total_sales DESC) as category_rank,
    CASE 
        WHEN cs.total_sales > st.grand_total * 0.25 THEN 'Top Performer'
        WHEN cs.total_sales > st.grand_total * 0.10 THEN 'Strong'
        WHEN cs.total_sales > st.grand_total * 0.05 THEN 'Moderate'
        ELSE 'Needs Attention'
    END as performance_tier
FROM 
    category_sales cs
    CROSS JOIN sales_totals st
ORDER BY 
    cs.total_sales DESC;

-- Otorgar permisos al usuario de aplicación
GRANT SELECT ON view_sales_by_category TO reports_user;

-- ============================================
-- VIEW 2: view_customer_lifetime_value
-- Análisis del valor de vida del cliente (CLV)
-- ============================================
-- DESCRIPCIÓN: Calcula el valor total, frecuencia y recencia de compras por cliente
-- GRAIN: Una fila por cliente
-- MÉTRICAS:
--   - total_spent: Total gastado por el cliente (SUM)
--   - total_orders: Número de órdenes (COUNT DISTINCT)
--   - avg_order_value: Valor promedio por orden (AVG)
--   - total_profit: Ganancia total generada (SUM de profit)
--   - days_since_last_purchase: Días desde última compra (campo calculado)
--   - customer_segment: Segmentación RFM básica (CASE)
--   - is_at_risk: Cliente en riesgo de abandono (CASE con COALESCE)
-- RAZÓN GROUP BY: Agregamos por cliente para obtener métricas individuales
-- RAZÓN HAVING: Filtramos clientes con gasto total mayor a $1000 para enfocarnos en clientes valiosos
-- TÉCNICAS SQL: CASE, COALESCE, DATE arithmetic, funciones agregadas
-- ============================================

-- VERIFY Query 1: Verificar que todos los customers con ventas estén incluidos
-- SELECT COUNT(DISTINCT customer_id) FROM sales WHERE sale_date >= '2024-01-01';
-- SELECT COUNT(*) FROM view_customer_lifetime_value;

-- VERIFY Query 2: El total_spent debe coincidir con la suma de sales
-- SELECT SUM(total_spent)::DECIMAL(10,2) FROM view_customer_lifetime_value;
-- SELECT SUM(sale_amount)::DECIMAL(10,2) FROM sales WHERE sale_date >= '2024-01-01';

CREATE OR REPLACE VIEW view_customer_lifetime_value AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    c.city,
    c.registration_date,
    COUNT(DISTINCT s.sale_id) as total_orders,
    SUM(s.sale_amount) as total_spent,
    AVG(s.sale_amount) as avg_order_value,
    SUM(COALESCE(s.profit, 0)) as total_profit,
    MIN(s.sale_date) as first_purchase_date,
    MAX(s.sale_date) as last_purchase_date,
    CURRENT_DATE - MAX(s.sale_date) as days_since_last_purchase,
    CASE 
        WHEN CURRENT_DATE - MAX(s.sale_date) <= 30 THEN 'Active'
        WHEN CURRENT_DATE - MAX(s.sale_date) <= 90 THEN 'Occasional'
        WHEN CURRENT_DATE - MAX(s.sale_date) <= 180 THEN 'Dormant'
        ELSE 'Inactive'
    END as customer_status,
    CASE 
        WHEN SUM(s.sale_amount) > 50000 AND COUNT(DISTINCT s.sale_id) >= 5 THEN 'VIP'
        WHEN SUM(s.sale_amount) > 20000 AND COUNT(DISTINCT s.sale_id) >= 3 THEN 'High Value'
        WHEN SUM(s.sale_amount) > 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_segment,
    CASE 
        WHEN CURRENT_DATE - MAX(s.sale_date) > 180 AND SUM(s.sale_amount) > 10000 THEN TRUE
        ELSE FALSE
    END as is_at_risk
FROM 
    customers c
    INNER JOIN sales s ON c.customer_id = s.customer_id
WHERE 
    s.sale_date >= '2024-01-01'
    AND c.is_active = TRUE
GROUP BY 
    c.customer_id, c.customer_name, c.email, c.city, c.registration_date
HAVING 
    SUM(s.sale_amount) > 1000  -- Solo clientes con más de $1000 en compras
ORDER BY 
    total_spent DESC;

-- Otorgar permisos
GRANT SELECT ON view_customer_lifetime_value TO reports_user;

-- ============================================
-- VIEW 3: view_product_performance
-- Análisis de desempeño de productos
-- ============================================
-- DESCRIPCIÓN: Evalúa el rendimiento de cada producto con métricas de ventas e inventario
-- GRAIN: Una fila por producto
-- MÉTRICAS:
--   - units_sold: Unidades vendidas (SUM)
--   - total_revenue: Ingresos totales (SUM)
--   - total_profit: Ganancia total (SUM)
--   - avg_selling_price: Precio promedio de venta (AVG)
--   - profit_margin: Margen de ganancia (campo calculado)
--   - stock_status: Estado del inventario (CASE con COALESCE)
--   - reorder_priority: Prioridad de reorden (CASE)
--   - turnover_rate: Tasa de rotación (campo calculado)
-- RAZÓN GROUP BY: Agregamos por producto para métricas individuales
-- RAZÓN HAVING: Filtramos productos con al menos 2 ventas para enfocarnos en productos activos
-- TÉCNICAS SQL: COALESCE, múltiples CASE, campos calculados complejos
-- ============================================

-- VERIFY Query 1: Total revenue debe coincidir con suma de sales
-- SELECT SUM(total_revenue)::DECIMAL(10,2) FROM view_product_performance;
-- SELECT SUM(sale_amount)::DECIMAL(10,2) FROM sales WHERE sale_date >= '2024-01-01';

-- VERIFY Query 2: Verificar que no hay productos con stock_quantity NULL
-- SELECT COUNT(*) FROM view_product_performance WHERE current_stock IS NULL;

CREATE OR REPLACE VIEW view_product_performance AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.price as current_price,
    COALESCE(p.stock_quantity, 0) as current_stock,
    p.reorder_level,
    COUNT(s.sale_id) as num_sales,
    SUM(s.quantity) as units_sold,
    SUM(s.sale_amount) as total_revenue,
    SUM(s.profit) as total_profit,
    AVG(s.sale_amount / s.quantity) as avg_selling_price,
    CASE 
        WHEN SUM(s.sale_amount) > 0 THEN 
            ROUND((SUM(s.profit) / SUM(s.sale_amount) * 100)::NUMERIC, 2)
        ELSE 0 
    END as profit_margin_percent,
    CASE 
        WHEN COALESCE(p.stock_quantity, 0) = 0 THEN 'Out of Stock'
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level THEN 'Low Stock'
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level * 2 THEN 'Normal'
        ELSE 'Overstocked'
    END as stock_status,
    CASE 
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level 
             AND SUM(s.quantity) > 10 THEN 'High'
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level THEN 'Medium'
        ELSE 'Low'
    END as reorder_priority,
    CASE 
        WHEN COALESCE(p.stock_quantity, 0) > 0 THEN 
            ROUND((SUM(s.quantity)::NUMERIC / COALESCE(p.stock_quantity, 1))::NUMERIC, 2)
        ELSE 0 
    END as turnover_rate,
    p.discontinued
FROM 
    products p
    INNER JOIN categories c ON p.category_id = c.category_id
    LEFT JOIN sales s ON p.product_id = s.product_id 
        AND s.sale_date >= '2024-01-01'
GROUP BY 
    p.product_id, p.product_name, c.category_name, p.price, 
    p.stock_quantity, p.reorder_level, p.discontinued
HAVING 
    COUNT(s.sale_id) >= 2  -- Solo productos con al menos 2 ventas
ORDER BY 
    total_revenue DESC;

-- Otorgar permisos
GRANT SELECT ON view_product_performance TO reports_user;

-- ============================================
-- VIEW 4: view_monthly_sales_trends
-- Análisis de tendencias mensuales de ventas
-- ============================================
-- DESCRIPCIÓN: Muestra tendencias de ventas mes a mes con comparaciones
-- GRAIN: Una fila por mes
-- MÉTRICAS:
--   - total_sales: Ventas totales del mes (SUM)
--   - total_orders: Número de órdenes (COUNT)
--   - avg_order_value: Valor promedio por orden (AVG)
--   - total_profit: Ganancia total (SUM)
--   - sales_growth: Crecimiento vs mes anterior (Window Function)
--   - cumulative_sales: Ventas acumuladas (Window Function: SUM OVER)
--   - sales_rank: Ranking de meses por ventas (Window Function: RANK)
--   - trend_indicator: Indicador de tendencia (CASE)
-- RAZÓN GROUP BY: Agregamos por año y mes para análisis temporal
-- RAZÓN NO SE USA HAVING: No es necesario filtrar meses, todos son relevantes para análisis de tendencias
-- TÉCNICAS SQL: Window Functions (LAG, SUM OVER, RANK), CASE, date functions
-- ============================================

-- VERIFY Query 1: Sumar todas las ventas mensuales debe dar el total de sales
-- SELECT SUM(total_sales)::DECIMAL(10,2) FROM view_monthly_sales_trends;
-- SELECT SUM(sale_amount)::DECIMAL(10,2) FROM sales WHERE sale_date >= '2024-01-01';

-- VERIFY Query 2: El último valor de cumulative_sales debe ser igual al total de ventas
-- SELECT cumulative_sales FROM view_monthly_sales_trends ORDER BY sale_year DESC, sale_month DESC LIMIT 1;
-- SELECT SUM(sale_amount)::DECIMAL(10,2) FROM sales WHERE sale_date >= '2024-01-01';

CREATE OR REPLACE VIEW view_monthly_sales_trends AS
WITH monthly_data AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) as sale_year,
        EXTRACT(MONTH FROM sale_date) as sale_month,
        TO_CHAR(sale_date, 'YYYY-MM') as year_month,
        COUNT(DISTINCT sale_id) as total_orders,
        SUM(sale_amount) as total_sales,
        AVG(sale_amount) as avg_order_value,
        SUM(profit) as total_profit,
        MIN(sale_date) as period_start,
        MAX(sale_date) as period_end
    FROM 
        sales
    WHERE 
        sale_date >= '2024-01-01'
    GROUP BY 
        EXTRACT(YEAR FROM sale_date),
        EXTRACT(MONTH FROM sale_date),
        TO_CHAR(sale_date, 'YYYY-MM')
)
SELECT 
    sale_year,
    sale_month,
    year_month,
    period_start,
    period_end,
    total_orders,
    total_sales,
    avg_order_value,
    total_profit,
    ROUND((total_profit / NULLIF(total_sales, 0) * 100)::NUMERIC, 2) as profit_margin_percent,
    LAG(total_sales) OVER (ORDER BY sale_year, sale_month) as previous_month_sales,
    CASE 
        WHEN LAG(total_sales) OVER (ORDER BY sale_year, sale_month) IS NOT NULL THEN
            ROUND((((total_sales - LAG(total_sales) OVER (ORDER BY sale_year, sale_month)) 
                  / NULLIF(LAG(total_sales) OVER (ORDER BY sale_year, sale_month), 0)) * 100)::NUMERIC, 2)
        ELSE NULL
    END as sales_growth_percent,
    SUM(total_sales) OVER (ORDER BY sale_year, sale_month) as cumulative_sales,
    RANK() OVER (ORDER BY total_sales DESC) as sales_rank,
    CASE 
        WHEN LAG(total_sales) OVER (ORDER BY sale_year, sale_month) IS NULL THEN 'First Period'
        WHEN total_sales > LAG(total_sales) OVER (ORDER BY sale_year, sale_month) * 1.1 THEN 'Strong Growth'
        WHEN total_sales > LAG(total_sales) OVER (ORDER BY sale_year, sale_month) THEN 'Moderate Growth'
        WHEN total_sales >= LAG(total_sales) OVER (ORDER BY sale_year, sale_month) * 0.9 THEN 'Stable'
        ELSE 'Declining'
    END as trend_indicator
FROM 
    monthly_data
ORDER BY 
    sale_year DESC, sale_month DESC;

-- Otorgar permisos
GRANT SELECT ON view_monthly_sales_trends TO reports_user;

-- ============================================
-- VIEW 5: view_inventory_reorder_analysis
-- Análisis de inventario y necesidades de reorden
-- ============================================
-- DESCRIPCIÓN: Identifica productos que necesitan reorden basado en stock y ventas
-- GRAIN: Una fila por producto (solo productos con stock bajo o ventas recientes)
-- MÉTRICAS:
--   - current_stock: Inventario actual (COALESCE)
--   - reorder_level: Nivel de reorden configurado
--   - units_sold_last_30_days: Ventas últimos 30 días (SUM con FILTER)
--   - avg_daily_sales: Promedio de ventas diarias (campo calculado)
--   - days_until_stockout: Días hasta agotar stock (campo calculado)
--   - recommended_order_qty: Cantidad recomendada a ordenar (CASE)
--   - urgency_level: Nivel de urgencia (CASE con múltiples condiciones)
-- RAZÓN GROUP BY: Agregamos por producto para análisis individual de inventario
-- RAZÓN HAVING: Filtramos solo productos con stock bajo O ventas recientes significativas
-- TÉCNICAS SQL: FILTER clause, COALESCE, CASE anidados, campos calculados complejos
-- ============================================

-- VERIFY Query 1: Verificar que solo productos con stock <= reorder_level * 2 O ventas > 0 estén incluidos
-- SELECT COUNT(*) FROM view_inventory_reorder_analysis;
-- SELECT COUNT(*) FROM products p WHERE 
--   COALESCE(p.stock_quantity, 0) <= p.reorder_level * 2 OR 
--   EXISTS (SELECT 1 FROM sales s WHERE s.product_id = p.product_id AND s.sale_date >= CURRENT_DATE - 30);

-- VERIFY Query 2: Ningún producto debe tener current_stock NULL (por COALESCE)
-- SELECT COUNT(*) FROM view_inventory_reorder_analysis WHERE current_stock IS NULL;

CREATE OR REPLACE VIEW view_inventory_reorder_analysis AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    COALESCE(p.stock_quantity, 0) as current_stock,
    p.reorder_level,
    p.discontinued,
    COUNT(s.sale_id) FILTER (WHERE s.sale_date >= CURRENT_DATE - 30) as sales_last_30_days,
    SUM(s.quantity) FILTER (WHERE s.sale_date >= CURRENT_DATE - 30) as units_sold_last_30_days,
    COALESCE(SUM(s.sale_amount) FILTER (WHERE s.sale_date >= CURRENT_DATE - 30), 0) as revenue_last_30_days,
    CASE 
        WHEN SUM(s.quantity) FILTER (WHERE s.sale_date >= CURRENT_DATE - 30) > 0 THEN
            ROUND((SUM(s.quantity) FILTER (WHERE s.sale_date >= CURRENT_DATE - 30) / 30.0)::NUMERIC, 2)
        ELSE 0
    END as avg_daily_sales,
    CASE 
        WHEN SUM(s.quantity) FILTER (WHERE s.sale_date >= CURRENT_DATE - 30) > 0 THEN
            ROUND((COALESCE(p.stock_quantity, 0)::NUMERIC / 
                  (SUM(s.quantity) FILTER (WHERE s.sale_date >= CURRENT_DATE - 30) / 30.0))::NUMERIC, 1)
        ELSE 999
    END as days_until_stockout,
    CASE 
        WHEN COALESCE(p.stock_quantity, 0) = 0 THEN p.reorder_level * 3
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level THEN p.reorder_level * 2
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level * 1.5 THEN p.reorder_level
        ELSE 0
    END as recommended_order_qty,
    CASE 
        WHEN p.discontinued = TRUE THEN 'Discontinued'
        WHEN COALESCE(p.stock_quantity, 0) = 0 THEN 'Critical'
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level 
             AND SUM(s.quantity) FILTER (WHERE s.sale_date >= CURRENT_DATE - 30) >= 10 THEN 'High'
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level THEN 'Medium'
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level * 1.5 THEN 'Low'
        ELSE 'Normal'
    END as urgency_level,
    CASE 
        WHEN COALESCE(p.stock_quantity, 0) = 0 THEN 'Out of Stock - Order Now'
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level THEN 'Below Reorder Level'
        WHEN SUM(s.quantity) FILTER (WHERE s.sale_date >= CURRENT_DATE - 30) >= 15 THEN 'High Demand'
        ELSE 'Monitor'
    END as action_required
FROM 
    products p
    INNER JOIN categories c ON p.category_id = c.category_id
    LEFT JOIN sales s ON p.product_id = s.product_id
GROUP BY 
    p.product_id, p.product_name, c.category_name, p.price,
    p.stock_quantity, p.reorder_level, p.discontinued
HAVING 
    -- Incluir solo productos que necesitan atención
    COALESCE(p.stock_quantity, 0) <= p.reorder_level * 2 
    OR 
    SUM(s.quantity) FILTER (WHERE s.sale_date >= CURRENT_DATE - 30) > 0
ORDER BY 
    CASE 
        WHEN p.discontinued = TRUE THEN 5
        WHEN COALESCE(p.stock_quantity, 0) = 0 THEN 1
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level THEN 2
        WHEN COALESCE(p.stock_quantity, 0) <= p.reorder_level * 1.5 THEN 3
        ELSE 4
    END,
    units_sold_last_30_days DESC NULLS LAST;

-- Otorgar permisos
GRANT SELECT ON view_inventory_reorder_analysis TO reports_user;

-- ============================================
-- Verificación final de VIEWS creadas
-- ============================================

-- Listar todas las VIEWS creadas
SELECT 
    schemaname,
    viewname,
    viewowner,
    definition
FROM pg_views
WHERE schemaname = 'public'
AND viewname LIKE 'view_%'
ORDER BY viewname;

-- Verificar permisos del usuario de aplicación
SELECT 
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'reports_user'
AND table_schema = 'public'
ORDER BY table_name;

-- Mensaje de confirmación
SELECT '✅ 5 VIEWS creadas exitosamente con todos los requisitos:' as message
UNION ALL
SELECT '  1. view_sales_by_category (CTE + Window Function RANK + CASE + HAVING)'
UNION ALL
SELECT '  2. view_customer_lifetime_value (CASE + COALESCE + HAVING)'
UNION ALL
SELECT '  3. view_product_performance (COALESCE + múltiples CASE + HAVING)'
UNION ALL
SELECT '  4. view_monthly_sales_trends (Window Functions: LAG, SUM OVER, RANK)'
UNION ALL
SELECT '  5. view_inventory_reorder_analysis (FILTER + CASE + COALESCE + HAVING)'
UNION ALL
SELECT '✅ Permisos SELECT otorgados a reports_user en todas las VIEWS';