-- =========================================================
-- ANÁLISIS EXPLORATORIO DE DATOS (EDA)
-- =========================================================

-- SELECT * FROM raw_sales LIMIT 5;

-- =========================================================
-- 1. VISIÓN GENERAL DE INGRESOS
-- =========================================================
-- Total de ingrsos y numero de transacciones
SELECT 
    COUNT(sale_id) AS total_transactions,
    SUM(sales_amount) AS total_revenue
FROM fact_sales;

-- Valor promedio por venta
SELECT 
    AVG(sales_amount) AS avg_sale_value
FROM fact_sales;


-- Agregación simple de ventas por región
SELECT 
    r.region_name,
    COUNT(f.sale_id) AS total_transactions,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY r.region_name
ORDER BY total_revenue DESC;



-- =========================================================
-- 2. CANALES DE VENTA
-- =========================================================

-- Comparación de rendimiento: Online vs Offline
SELECT
    CASE 
        WHEN sc.sales_channel IN ('Online', 'E-Commerce') THEN 'Online'
        ELSE 'Offline'
    END AS channel_type,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_sales_channel sc ON f.sales_channel_id = sc.sales_channel_id
GROUP BY channel_type;

-- Ingresos por canal de ventas y año
WITH revenue_per_channel AS (
    SELECT 
        sc.sales_channel,
        d.year,
        SUM(f.sales_amount) AS total_revenue
    FROM fact_sales f
    JOIN dim_sales_channel sc ON f.sales_channel_id = sc.sales_channel_id
    JOIN dim_date d ON f.date_id = d.date_id
    GROUP BY sc.sales_channel, d.year
)
SELECT *
FROM revenue_per_channel
ORDER BY year, total_revenue DESC;

-- =========================================================
-- 3. ANÁLISIS TEMPORAL
-- =========================================================

-- Ventas mensuales por región con ranking
WITH monthly_region AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        r.region_name,
        SUM(f.sales_amount) AS total_revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_id = d.date_id
    JOIN dim_region r ON f.region_id = r.region_id
    GROUP BY d.year, d.month, d.month_name, r.region_name
)
SELECT *,
       RANK() OVER (
           PARTITION BY year, month
           ORDER BY total_revenue DESC
       ) AS region_rank
FROM monthly_region
ORDER BY year, month, region_rank;

-- Uso de la vista: ventas mensuales por región ordenado por ingresos
SELECT *
FROM vw_monthly_region_sales
ORDER BY total_revenue DESC;

-- Ventas por mes de mayor a menor
SELECT 
    d.year,
    d.month_name,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY total_revenue DESC;

-- Ventas por mes y día (granularidad diaria)
SELECT 
    d.year,
    d.month_name,
    d.day,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name, d.day
ORDER BY d.year, d.month, d.day;

-- Crecimiento mensual de ingresos
WITH monthly_revenue AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        SUM(f.sales_amount) AS total_revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_id = d.date_id
    GROUP BY d.year, d.month, d.month_name
)
SELECT 
    year,
    month_name,
    total_revenue,
    COALESCE(
        total_revenue - LAG(total_revenue) OVER (ORDER BY year, month),
        0
    ) AS revenue_diff,
    COALESCE(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY year, month)) * 100.0
        / LAG(total_revenue) OVER (ORDER BY year, month),
        0
    ) AS pct_change
FROM monthly_revenue
ORDER BY year, month;

-- Crecimiento mensual de ingresos de mayor a menor  por porcentage
WITH monthly_revenue AS (
    SELECT 
        d.year,
        d.month,
        d.month_name,
        SUM(f.sales_amount) AS total_revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_id = d.date_id
    GROUP BY d.year, d.month, d.month_name
),
growth AS (
    SELECT
        year,
        month,
        month_name,
        total_revenue,
        total_revenue
            - LAG(total_revenue) OVER (ORDER BY year, month) AS revenue_diff,
        (total_revenue
            - LAG(total_revenue) OVER (ORDER BY year, month))
            * 100.0
            / NULLIF(LAG(total_revenue) OVER (ORDER BY year, month), 0) AS pct_change
    FROM monthly_revenue
)
SELECT
    year,
    month_name,
    total_revenue,
    revenue_diff,
    pct_change
FROM growth
ORDER BY pct_change DESC NULLS LAST;

-- =========================================================
-- 4. CLIENTES
-- =========================================================

-- Ventas por tipo de cliente
SELECT 
    c.customer_type,
    COUNT(f.sale_id) AS total_transactions,
    SUM(f.sales_amount) AS total_revenue,
    AVG(f.sales_amount) AS avg_sale_value
FROM fact_sales f
JOIN dim_customer_type c ON f.customer_type_id = c.customer_type_id
GROUP BY c.customer_type
ORDER BY total_revenue DESC;

-- Ventas por tipo de cliente a lo largo del tiempo
SELECT 
    d.year,
    d.month_name,
    c.customer_type,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_customer_type c ON f.customer_type_id = c.customer_type_id
GROUP BY d.year, d.month, d.month_name, c.customer_type
ORDER BY d.year, d.month, total_revenue DESC;

-- =========================================================
-- 5. MÉTODOS DE PAGO
-- =========================================================

SELECT 
    pm.payment_method,
    COUNT(f.sale_id) AS total_transactions,
    SUM(f.sales_amount) AS total_revenue,
    AVG(f.sales_amount) AS avg_sale_value
FROM fact_sales f
JOIN dim_payment_method pm ON f.payment_method_id = pm.payment_method_id
GROUP BY pm.payment_method
ORDER BY total_revenue DESC;

-- =========================================================
-- 6. REPRESENTANTES DE VENTAS
-- =========================================================

-- Mejores representantes por ingresos
SELECT 
    sr.sales_rep_name,
    COUNT(f.sale_id) AS total_transactions,
    SUM(f.sales_amount) AS total_revenue,
    AVG(f.sales_amount) AS avg_sale_value
FROM fact_sales f
JOIN dim_sales_rep sr ON f.sales_rep_id = sr.sales_rep_id
GROUP BY sr.sales_rep_name
ORDER BY total_revenue DESC;

-- =========================================================
-- 7. PRODUCTOS
-- =========================================================

-- Productos con mayor ingreso
SELECT 
    p.product_id,
    COUNT(f.sale_id) AS total_transactions,
    SUM(f.sales_amount) AS total_revenue,
    AVG(f.sales_amount) AS avg_sale_value
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_revenue DESC;

-- Productos más vendidos por cantidad
SELECT 
    p.product_id,
    SUM(f.quantity_sold) AS total_quantity_sold,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_quantity_sold DESC;

-- Ventas por categoría de producto
SELECT 
    p.product_category,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_category
ORDER BY total_revenue DESC;

-- =========================================================
-- 8. ANÁLISIS CRUZADO
-- =========================================================

-- region por ventas totales
SELECT 
    r.region_name,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY r.region_name
ORDER BY total_revenue DESC;

-- Regiones top por ventas y canal
SELECT 
    r.region_name,
    sc.sales_channel,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
JOIN dim_sales_channel sc ON f.sales_channel_id = sc.sales_channel_id
GROUP BY r.region_name, sc.sales_channel
ORDER BY total_revenue DESC;

-- Top productos por región
SELECT 
    r.region_name,
    p.product_id,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY r.region_name, p.product_id
ORDER BY total_revenue DESC;
