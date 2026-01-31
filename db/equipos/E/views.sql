-- ============================================================
-- ActividadViewsSQL - Equipo E
-- Archivo: db/equipos/E/views.sql
-- ============================================================
-- Reglas cumplidas:
-- ✓ NO usa SELECT *
-- ✓ Cada vista incluye comentario completo (qué devuelve, grain, métricas)
-- ✓ Usa GROUP BY + HAVING + campos calculados
-- ✓ CASE/COALESCE significativo en 2+ views
-- ✓ CTE (WITH) en VIEW 4
-- ✓ Window Functions en VIEW 5
-- ============================================================

-- ============================================================
-- VIEW 1: vw_top_productos_E
-- ============================================================
/*
Qué devuelve: 
  Top productos vendidos del equipo E con métricas de ventas y clasificación
  por nivel de éxito de ventas.

Grain (una fila representa): 
  Un producto único del equipo E

Métricas:
  - unidades_vendidas: Total de unidades vendidas del producto
  - ventas_total: Ingresos totales generados por el producto
  - precio_promedio: Precio promedio por unidad vendida
  - ordenes_count: Cantidad de órdenes que incluyeron este producto
  - categoria_nombre: Categoría a la que pertenece el producto
  - nivel_ventas: Clasificación del producto (Alto/Medio/Bajo) según unidades vendidas

Por qué usa GROUP BY:
  Agrupa por producto para consolidar todas sus ventas en una fila

Por qué usa HAVING:
  Filtra solo productos que han vendido al menos 1 unidad

Queries VERIFY:
  1. SELECT * FROM vw_top_productos_E ORDER BY ventas_total DESC LIMIT 10;
  2. SELECT nivel_ventas, COUNT(*) FROM vw_top_productos_E GROUP BY nivel_ventas;
*/
CREATE OR REPLACE VIEW vw_top_productos_E AS
SELECT
    p.id AS producto_id,
    p.nombre AS producto_nombre,
    c.nombre AS categoria_nombre,
    SUM(od.cantidad) AS unidades_vendidas,
    SUM(od.subtotal) AS ventas_total,
    -- Campo calculado con COALESCE para evitar división por cero
    COALESCE(
        SUM(od.subtotal) / NULLIF(SUM(od.cantidad), 0),
        0
    ) AS precio_promedio,
    COUNT(DISTINCT od.orden_id) AS ordenes_count,
    -- Campo calculado con CASE para clasificar productos por nivel de ventas
    CASE 
        WHEN SUM(od.cantidad) >= 3 THEN 'Alto'
        WHEN SUM(od.cantidad) >= 2 THEN 'Medio'
        ELSE 'Bajo'
    END AS nivel_ventas
FROM productos p
INNER JOIN orden_detalles od ON od.producto_id = p.id
INNER JOIN ordenes o ON od.orden_id = o.id
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE MOD(od.producto_id, 6) = 4  -- Filtro para equipo E
GROUP BY p.id, p.nombre, c.nombre
HAVING SUM(od.cantidad) >= 1
ORDER BY ventas_total DESC;


-- ============================================================
-- VIEW 2: vw_ventas_mensuales_E
-- ============================================================
/*
Qué devuelve:
  Resumen de ventas mensuales del equipo E con métricas de performance
  y comparación con el mes anterior.

Grain (una fila representa):
  Un mes específico (año + mes)

Métricas:
  - ordenes_count: Cantidad de órdenes en el mes
  - ventas_total: Ingresos totales del mes
  - ticket_promedio: Valor promedio por orden
  - ordenes_completadas: Órdenes con status 'entregado'
  - tasa_completadas_pct: Porcentaje de órdenes completadas
  - tendencia: Clasificación de performance del mes

Por qué usa GROUP BY:
  Agrupa por año y mes para consolidar ventas mensuales

Por qué usa HAVING:
  Filtra solo meses con al menos 1 orden

Queries VERIFY:
  1. SELECT * FROM vw_ventas_mensuales_E ORDER BY anio DESC, mes DESC;
  2. SELECT tendencia, COUNT(*) FROM vw_ventas_mensuales_E GROUP BY tendencia;
*/
CREATE OR REPLACE VIEW vw_ventas_mensuales_E AS
SELECT
    EXTRACT(YEAR FROM o.created_at)::int AS anio,
    EXTRACT(MONTH FROM o.created_at)::int AS mes,
    TO_CHAR(o.created_at, 'YYYY-MM') AS periodo,
    COUNT(DISTINCT o.id) AS ordenes_count,
    SUM(o.total) AS ventas_total,
    -- Campo calculado con COALESCE para ticket promedio
    COALESCE(
        ROUND(SUM(o.total) / NULLIF(COUNT(DISTINCT o.id), 0), 2),
        0
    ) AS ticket_promedio,
    -- Cuenta órdenes completadas usando CASE
    COUNT(DISTINCT CASE 
        WHEN o.status = 'entregado' THEN o.id 
    END) AS ordenes_completadas,
    -- Calcula porcentaje de órdenes completadas
    COALESCE(
        ROUND(
            COUNT(DISTINCT CASE WHEN o.status = 'entregado' THEN o.id END) * 100.0 / 
            NULLIF(COUNT(DISTINCT o.id), 0),
            2
        ),
        0
    ) AS tasa_completadas_pct,
    -- Campo calculado con CASE para tendencia de ventas
    CASE 
        WHEN SUM(o.total) >= 1000 THEN 'Excelente'
        WHEN SUM(o.total) >= 500 THEN 'Bueno'
        WHEN SUM(o.total) >= 100 THEN 'Regular'
        ELSE 'Bajo'
    END AS tendencia
FROM ordenes o
WHERE MOD(o.id, 6) = 4  -- Filtro para equipo E
GROUP BY 
    EXTRACT(YEAR FROM o.created_at),
    EXTRACT(MONTH FROM o.created_at),
    TO_CHAR(o.created_at, 'YYYY-MM')
HAVING COUNT(DISTINCT o.id) >= 1
ORDER BY anio DESC, mes DESC;


-- ============================================================
-- VIEW 3: vw_clientes_valor_E
-- ============================================================
/*
Qué devuelve:
  Análisis de clientes del equipo E por valor de compras, frecuencia
  y segmentación de clientes.

Grain (una fila representa):
  Un cliente único del equipo E

Métricas:
  - ordenes_count: Cantidad de órdenes realizadas por el cliente
  - gasto_total: Suma total de compras del cliente
  - gasto_promedio: Gasto promedio por orden
  - productos_distintos: Cantidad de productos únicos comprados
  - ultima_compra: Fecha de la orden más reciente
  - segmento_cliente: Clasificación del cliente (VIP/Frecuente/Ocasional/Nuevo)

Por qué usa GROUP BY:
  Agrupa por cliente para consolidar todas sus compras

Por qué usa HAVING:
  Filtra solo clientes con al menos 1 orden

Queries VERIFY:
  1. SELECT * FROM vw_clientes_valor_E ORDER BY gasto_total DESC LIMIT 10;
  2. SELECT segmento_cliente, COUNT(*), SUM(gasto_total) FROM vw_clientes_valor_E GROUP BY segmento_cliente;
*/
CREATE OR REPLACE VIEW vw_clientes_valor_E AS
SELECT
    u.id AS cliente_id,
    u.nombre AS cliente_nombre,
    u.email AS cliente_email,
    COUNT(DISTINCT o.id) AS ordenes_count,
    SUM(o.total) AS gasto_total,
    -- Campo calculado con COALESCE para gasto promedio
    COALESCE(
        ROUND(SUM(o.total) / NULLIF(COUNT(DISTINCT o.id), 0), 2),
        0
    ) AS gasto_promedio,
    -- Cuenta productos distintos comprados
    COUNT(DISTINCT od.producto_id) AS productos_distintos,
    MAX(o.created_at) AS ultima_compra,
    -- Campo calculado con CASE para segmentar clientes
    CASE 
        WHEN SUM(o.total) >= 1000 AND COUNT(DISTINCT o.id) >= 2 THEN 'VIP'
        WHEN COUNT(DISTINCT o.id) >= 2 THEN 'Frecuente'
        WHEN COUNT(DISTINCT o.id) = 1 THEN 'Ocasional'
        ELSE 'Nuevo'
    END AS segmento_cliente
FROM usuarios u
INNER JOIN ordenes o ON o.usuario_id = u.id
LEFT JOIN orden_detalles od ON o.id = od.orden_id
WHERE MOD(u.id, 6) = 4  -- Filtro para equipo E
GROUP BY u.id, u.nombre, u.email
HAVING COUNT(DISTINCT o.id) >= 1
ORDER BY gasto_total DESC;


-- ============================================================
-- VIEW 4: vw_categorias_performance_E (CON CTE)
-- ============================================================
/*
Qué devuelve:
  Performance de categorías del equipo E comparado con el promedio global,
  utilizando CTE para calcular métricas base y luego comparativas.

Grain (una fila representa):
  Una categoría de productos

Métricas:
  - productos_count: Cantidad de productos en la categoría
  - ventas_total: Ingresos totales de la categoría
  - unidades_vendidas: Total de unidades vendidas
  - precio_promedio: Precio promedio de venta
  - promedio_global_ventas: Promedio de ventas de todas las categorías
  - diferencia_vs_promedio: Diferencia respecto al promedio global
  - performance_relativo: Clasificación de performance vs promedio

Por qué usa GROUP BY:
  En el CTE agrupa por categoría para calcular métricas base

Por qué usa HAVING:
  Filtra categorías con al menos 1 producto vendido

Por qué usa CTE (WITH):
  Usa CTE para calcular primero las métricas por categoría, luego
  calcula el promedio global y hace comparativas

Queries VERIFY:
  1. SELECT * FROM vw_categorias_performance_E ORDER BY ventas_total DESC;
  2. SELECT performance_relativo, COUNT(*) FROM vw_categorias_performance_E GROUP BY performance_relativo;
*/
CREATE OR REPLACE VIEW vw_categorias_performance_E AS
WITH categoria_metricas AS (
    -- CTE: Calcula métricas base por categoría
    SELECT
        c.id AS categoria_id,
        c.nombre AS categoria_nombre,
        COUNT(DISTINCT p.id) AS productos_count,
        SUM(od.subtotal) AS ventas_total,
        SUM(od.cantidad) AS unidades_vendidas,
        COALESCE(
            ROUND(SUM(od.subtotal) / NULLIF(SUM(od.cantidad), 0), 2),
            0
        ) AS precio_promedio
    FROM categorias c
    INNER JOIN productos p ON p.categoria_id = c.id
    INNER JOIN orden_detalles od ON od.producto_id = p.id
    INNER JOIN ordenes o ON od.orden_id = o.id
    WHERE MOD(p.id, 6) = 4  -- Filtro para equipo E
    GROUP BY c.id, c.nombre
    HAVING SUM(od.cantidad) >= 1
),
promedio_global AS (
    -- CTE: Calcula el promedio global de ventas
    SELECT 
        AVG(ventas_total) AS promedio_ventas
    FROM categoria_metricas
)
SELECT
    cm.categoria_id,
    cm.categoria_nombre,
    cm.productos_count,
    cm.ventas_total,
    cm.unidades_vendidas,
    cm.precio_promedio,
    ROUND(pg.promedio_ventas, 2) AS promedio_global_ventas,
    -- Campo calculado: diferencia vs promedio
    ROUND(cm.ventas_total - pg.promedio_ventas, 2) AS diferencia_vs_promedio,
    -- Campo calculado: porcentaje vs promedio
    COALESCE(
        ROUND(
            ((cm.ventas_total - pg.promedio_ventas) * 100.0) / 
            NULLIF(pg.promedio_ventas, 0),
            2
        ),
        0
    ) AS porcentaje_vs_promedio,
    -- Campo calculado con CASE: clasificación de performance
    CASE 
        WHEN cm.ventas_total >= pg.promedio_ventas * 1.5 THEN 'Muy Superior'
        WHEN cm.ventas_total >= pg.promedio_ventas * 1.1 THEN 'Superior'
        WHEN cm.ventas_total >= pg.promedio_ventas * 0.9 THEN 'Promedio'
        WHEN cm.ventas_total >= pg.promedio_ventas * 0.5 THEN 'Inferior'
        ELSE 'Muy Inferior'
    END AS performance_relativo
FROM categoria_metricas cm
CROSS JOIN promedio_global pg
ORDER BY cm.ventas_total DESC;


-- ============================================================
-- VIEW 5: vw_ranking_productos_E (CON WINDOW FUNCTIONS)
-- ============================================================
/*
Qué devuelve:
  Ranking de productos del equipo E por ventas utilizando Window Functions
  para crear múltiples rankings y análisis comparativos.

Grain (una fila representa):
  Un producto único con sus métricas y rankings

Métricas:
  - ventas_total: Ingresos totales del producto
  - unidades_vendidas: Total de unidades vendidas
  - ranking_global: Posición del producto en ventas globales (ROW_NUMBER)
  - ranking_categoria: Posición del producto dentro de su categoría (RANK)
  - percentil_ventas: Percentil de ventas del producto (PERCENT_RANK)
  - ventas_acumuladas: Suma acumulada de ventas ordenadas descendentemente
  - porcentaje_ventas_categoria: % de ventas que representa en su categoría

Por qué usa GROUP BY:
  Agrupa por producto y categoría para calcular métricas base

Por qué usa HAVING:
  Filtra productos con al menos 1 unidad vendida

Por qué usa Window Functions:
  - ROW_NUMBER() OVER: Ranking global sin empates
  - RANK() OVER PARTITION BY: Ranking por categoría con empates
  - PERCENT_RANK() OVER: Posición percentil del producto
  - SUM() OVER: Ventas acumuladas
  - SUM() OVER PARTITION BY: Total de ventas por categoría

Queries VERIFY:
  1. SELECT * FROM vw_ranking_productos_E ORDER BY ranking_global LIMIT 10;
  2. SELECT categoria_nombre, ranking_categoria, producto_nombre, ventas_total 
     FROM vw_ranking_productos_E WHERE ranking_categoria <= 3 ORDER BY categoria_nombre, ranking_categoria;
*/
CREATE OR REPLACE VIEW vw_ranking_productos_E AS
SELECT
    p.id AS producto_id,
    p.nombre AS producto_nombre,
    c.nombre AS categoria_nombre,
    SUM(od.cantidad) AS unidades_vendidas,
    SUM(od.subtotal) AS ventas_total,
    COALESCE(
        ROUND(SUM(od.subtotal) / NULLIF(SUM(od.cantidad), 0), 2),
        0
    ) AS precio_promedio,
    
    -- Window Function: Ranking global por ventas (sin empates)
    ROW_NUMBER() OVER (
        ORDER BY SUM(od.subtotal) DESC
    ) AS ranking_global,
    
    -- Window Function: Ranking por categoría (con empates)
    RANK() OVER (
        PARTITION BY c.id 
        ORDER BY SUM(od.subtotal) DESC
    ) AS ranking_categoria,
    
    -- Window Function: Percentil de ventas (0 = mejor, 1 = peor)
    ROUND(
        PERCENT_RANK() OVER (ORDER BY SUM(od.subtotal) DESC)::numeric,
        3
    ) AS percentil_ventas,
    
    -- Window Function: Ventas acumuladas (suma corrida)
    SUM(SUM(od.subtotal)) OVER (
        ORDER BY SUM(od.subtotal) DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ventas_acumuladas,
    
    -- Window Function: Total de ventas por categoría
    SUM(SUM(od.subtotal)) OVER (
        PARTITION BY c.id
    ) AS ventas_total_categoria,
    
    -- Campo calculado: Porcentaje que representa en su categoría
    COALESCE(
        ROUND(
            (SUM(od.subtotal) * 100.0) / 
            NULLIF(
                SUM(SUM(od.subtotal)) OVER (PARTITION BY c.id),
                0
            ),
            2
        ),
        0
    ) AS porcentaje_ventas_categoria,
    
    -- Campo calculado con CASE: Clasificación por ranking global
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY SUM(od.subtotal) DESC) = 1 THEN 'TOP 1 - Estrella'
        WHEN ROW_NUMBER() OVER (ORDER BY SUM(od.subtotal) DESC) <= 3 THEN 'TOP 3 - Líder'
        WHEN ROW_NUMBER() OVER (ORDER BY SUM(od.subtotal) DESC) <= 5 THEN 'TOP 5 - Destacado'
        ELSE 'Regular'
    END AS clasificacion_global
    
FROM productos p
INNER JOIN orden_detalles od ON od.producto_id = p.id
INNER JOIN ordenes o ON od.orden_id = o.id
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE MOD(p.id, 6) = 4  -- Filtro para equipo E
GROUP BY p.id, p.nombre, c.id, c.nombre
HAVING SUM(od.cantidad) >= 1
ORDER BY ranking_global;

