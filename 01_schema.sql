PRAGMA foreign_keys = ON;

-- dim_date (Fechas de ventas)
CREATE TABLE IF NOT EXISTS dim_date(
    date_id INTEGER PRIMARY KEY, -- Usamos YYYMMDD para facilitar joins
    full_date DATE NOT NULL UNIQUE,
    day INTEGER NOT NULL CHECK(day BETWEEN 1 AND 31),
    month INTEGER NOT NULL CHECK(month BETWEEN 1 AND 12),
    month_name TEXT NOT NULL,
    year INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_id TEXT PRIMARY KEY, -- Usamos el id de el csv 
    product_category TEXT NOT NULL,
    unit_cost REAL NOT NULL CHECK(unit_cost >= 0),
    unit_price REAL NOT NULL CHECK(unit_price >= 0)
);

CREATE TABLE IF NOT EXISTS dim_sales_rep(
    sales_rep_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sales_rep_name TEXT NOT NULL UNIQUE,
    region_and_sales_rep TEXT
);

CREATE TABLE IF NOT EXISTS dim_region(
    region_id INTEGER PRIMARY KEY AUTOINCREMENT,
    region_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_customer_type (
    customer_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_type TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_payment_method (
    payment_method_id INTEGER PRIMARY KEY AUTOINCREMENT,
    payment_method TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_sales_channel (
    sales_channel_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sales_channel TEXT NOT NULL UNIQUE
);

-- fact_sales (Hechos de ventas)
CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- Llaves foráneas
    product_id TEXT NOT NULL,
    date_id INTEGER NOT NULL,
    sales_rep_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    customer_type_id INTEGER NOT NULL,
    payment_method_id INTEGER NOT NULL,
    sales_channel_id INTEGER NOT NULL,

    -- Medidas
    quantity_sold INTEGER NOT NULL CHECK (quantity_sold >= 0),
    unit_price REAL NOT NULL CHECK (unit_price >= 0),
    unit_cost REAL NOT NULL CHECK (unit_cost >= 0),
    discount REAL DEFAULT 0 CHECK (discount >= 0 AND discount <= 1),
    sales_amount REAL NOT NULL CHECK (sales_amount >= 0),

    -- Relaciones
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (sales_rep_id) REFERENCES dim_sales_rep(sales_rep_id),
    FOREIGN KEY (region_id) REFERENCES dim_region(region_id),
    FOREIGN KEY (customer_type_id) REFERENCES dim_customer_type(customer_type_id),
    FOREIGN KEY (payment_method_id) REFERENCES dim_payment_method(payment_method_id),
    FOREIGN KEY (sales_channel_id) REFERENCES dim_sales_channel(sales_channel_id)
);

-- Indice para aggregaciones de tiempo-geografia
CREATE INDEX IF NOT EXISTS idx_fact_sales_date_region
ON fact_sales (date_id, region_id);

-- Vistas
CREATE VIEW IF NOT EXISTS vw_monthly_region_sales AS 
SELECT
    d.year,
    d.month,
    r.region_name,
    COUNT(f.sale_id) AS total_transactions,
    SUM(f.sales_amount) AS total_revenue,
    AVG(f.sales_amount) AS avg_sale_value
FROM fact_sales f
join dim_date d ON f.date_id = d.date_id
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY d.year, d.month, r.region_name;

-- Funcion para sacar ventas por canal
-- SELECT
--     sc.sales_channel,
--     SUM(f.sales_amount) AS total_revenue
-- FROM fact_sales f
-- JOIN dim_sales_channel sc ON f.sales_channel_id = sc.sales_channel_id
-- JOIN dim_date d ON f.date_id = d.date_id
-- WHERE d.year = :year_param
-- GROUP BY sc.sales_channel;