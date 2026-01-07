-- =========================================================
-- CONFIGURACIÓN INICIAL
-- =========================================================
PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- =========================================================
-- CARGA DE TABLAS DIMENSIÓN
-- =========================================================

-- ---------------------------------------------------------
-- Dimensión de fechas
-- ---------------------------------------------------------
-- Generamos date_id en formato YYYYMMDD
-- Extraemos día, mes, nombre del mes y año desde Sale_Date
INSERT OR IGNORE INTO dim_date (
    date_id,
    full_date,
    day,
    month,
    month_name,
    year
)
SELECT 
    CAST(strftime('%Y%m%d', Sale_Date) AS INTEGER) AS date_id,
    Sale_Date AS full_date,
    CAST(strftime('%d', Sale_Date) AS INTEGER) AS day,
    CAST(strftime('%m', Sale_Date) AS INTEGER) AS month,
    CASE CAST(strftime('%m', Sale_Date) AS INTEGER)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS month_name,
    CAST(strftime('%Y', Sale_Date) AS INTEGER) AS year
FROM raw_sales
WHERE Sale_Date <> 'Sale_Date';

-- ---------------------------------------------------------
-- Dimensión de productos
-- ---------------------------------------------------------
INSERT OR IGNORE INTO dim_product (
    product_id,
    product_category,
    unit_cost,
    unit_price
)
SELECT DISTINCT
    Product_ID,
    Product_Category,
    Unit_Cost,
    Unit_Price
FROM raw_sales
WHERE Product_ID <> 'Product_ID';

-- ---------------------------------------------------------
-- Dimensión de regiones
-- ---------------------------------------------------------
INSERT OR IGNORE INTO dim_region (region_name)
SELECT DISTINCT
    Region
FROM raw_sales
WHERE Region <> 'Region';

-- ---------------------------------------------------------
-- Dimensión de representantes de ventas
-- ---------------------------------------------------------
INSERT OR IGNORE INTO dim_sales_rep (
    sales_rep_name,
    region_and_sales_rep
)
SELECT DISTINCT
    Sales_Rep,
    Region_and_Sales_Rep
FROM raw_sales
WHERE Sales_Rep <> 'Sales_Rep';

-- ---------------------------------------------------------
-- Dimensión de tipos de cliente
-- ---------------------------------------------------------
INSERT OR IGNORE INTO dim_customer_type (customer_type)
SELECT DISTINCT
    Customer_Type
FROM raw_sales
WHERE Customer_Type <> 'Customer_Type';

-- ---------------------------------------------------------
-- Dimensión de métodos de pago
-- ---------------------------------------------------------
INSERT OR IGNORE INTO dim_payment_method (payment_method)
SELECT DISTINCT
    Payment_Method
FROM raw_sales
WHERE Payment_Method <> 'Payment_Method';

-- ---------------------------------------------------------
-- Dimensión de canales de venta
-- ---------------------------------------------------------
INSERT OR IGNORE INTO dim_sales_channel (sales_channel)
SELECT DISTINCT
    Sales_Channel
FROM raw_sales
WHERE Sales_Channel <> 'Sales_Channel';

-- =========================================================
-- CARGA DE TABLA DE HECHOS
-- =========================================================

-- Insertamos las ventas resolviendo las llaves foráneas
INSERT INTO fact_sales (
    product_id,
    date_id,
    sales_rep_id,
    region_id,
    customer_type_id,
    payment_method_id,
    sales_channel_id,
    quantity_sold,
    unit_price,
    unit_cost,
    discount,
    sales_amount
)
SELECT
    r.Product_ID,
    CAST(strftime('%Y%m%d', r.Sale_Date) AS INTEGER) AS date_id,
    s.sales_rep_id,
    rg.region_id,
    ct.customer_type_id,
    pm.payment_method_id,
    sc.sales_channel_id,
    r.Quantity_Sold,
    r.Unit_Price,
    r.Unit_Cost,
    r.Discount,
    r.Sales_Amount
FROM raw_sales r
JOIN dim_sales_rep s
    ON r.Sales_Rep = s.sales_rep_name
JOIN dim_region rg
    ON r.Region = rg.region_name
JOIN dim_customer_type ct
    ON r.Customer_Type = ct.customer_type
JOIN dim_payment_method pm
    ON r.Payment_Method = pm.payment_method
JOIN dim_sales_channel sc
    ON r.Sales_Channel = sc.sales_channel
WHERE r.Product_ID <> 'Product_ID';

-- =========================================================
-- FIN DE TRANSACCIÓN
-- =========================================================
COMMIT;
