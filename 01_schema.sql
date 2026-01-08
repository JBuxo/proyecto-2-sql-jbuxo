-- =========================================================
-- Raw Sales
-- =========================================================
CREATE TABLE IF NOT EXISTS raw_sales (
    Product_ID TEXT,
    Sale_Date TEXT,
    Sales_Rep TEXT,
    Region TEXT,
    Sales_Amount REAL,
    Quantity_Sold INTEGER,
    Product_Category TEXT,
    Unit_Cost REAL,
    Unit_Price REAL,
    Customer_Type TEXT,
    Discount REAL,
    Payment_Method TEXT,
    Sales_Channel TEXT,
    Region_and_Sales_Rep TEXT
);

-- =========================================================
-- CONFIGURACIÓN INICIAL
-- =========================================================
-- Activamos el uso de llaves foráneas en SQLite
PRAGMA foreign_keys = ON;

-- =========================================================
-- TABLAS DIMENSIÓN
-- =========================================================

-- Dimensión de fechas
CREATE TABLE IF NOT EXISTS dim_date (
    date_id INTEGER PRIMARY KEY,       -- Usamos YYYYMMDD para facilitar joins
    full_date DATE NOT NULL UNIQUE,    -- Fecha completa
    day INTEGER NOT NULL CHECK(day BETWEEN 1 AND 31),          -- Día del mes
    month INTEGER NOT NULL CHECK(month BETWEEN 1 AND 12),     -- Número del mes
    month_name TEXT NOT NULL,                                    -- Nombre del mes
    year INTEGER NOT NULL                                        -- Año
);

-- Dimensión de productos
CREATE TABLE IF NOT EXISTS dim_product (
    product_id TEXT PRIMARY KEY,       -- ID único del producto (del CSV)
    product_category TEXT NOT NULL,    -- Categoría del producto
    unit_cost REAL NOT NULL CHECK(unit_cost >= 0),    -- Costo unitario
    unit_price REAL NOT NULL CHECK(unit_price >= 0)   -- Precio unitario
);

-- Dimensión de representantes de ventas
CREATE TABLE IF NOT EXISTS dim_sales_rep (
    sales_rep_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sales_rep_name TEXT NOT NULL UNIQUE,     -- Nombre del representante
    region_and_sales_rep TEXT                -- Texto adicional opcional (si aplica)
);

-- Dimensión de regiones
CREATE TABLE IF NOT EXISTS dim_region (
    region_id INTEGER PRIMARY KEY AUTOINCREMENT,
    region_name TEXT NOT NULL UNIQUE        -- Nombre de la región
);

-- Dimensión de tipos de clientes
CREATE TABLE IF NOT EXISTS dim_customer_type (
    customer_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_type TEXT NOT NULL UNIQUE
);

-- Dimensión de métodos de pago
CREATE TABLE IF NOT EXISTS dim_payment_method (
    payment_method_id INTEGER PRIMARY KEY AUTOINCREMENT,
    payment_method TEXT NOT NULL UNIQUE
);

-- Dimensión de canales de venta
CREATE TABLE IF NOT EXISTS dim_sales_channel (
    sales_channel_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sales_channel TEXT NOT NULL UNIQUE
);

-- =========================================================
-- TABLA DE HECHOS
-- =========================================================

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID de venta

    -- Llaves foráneas a dimensiones
    product_id TEXT NOT NULL,
    date_id INTEGER NOT NULL,
    sales_rep_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    customer_type_id INTEGER NOT NULL,
    payment_method_id INTEGER NOT NULL,
    sales_channel_id INTEGER NOT NULL,

    -- Medidas de la venta
    quantity_sold INTEGER NOT NULL CHECK (quantity_sold >= 0),  -- Cantidad vendida
    unit_price REAL NOT NULL CHECK (unit_price >= 0),           -- Precio unitario
    unit_cost REAL NOT NULL CHECK (unit_cost >= 0),             -- Costo unitario
    discount REAL DEFAULT 0 CHECK (discount >= 0 AND discount <= 1), -- Descuento aplicado (0-1)
    sales_amount REAL NOT NULL CHECK (sales_amount >= 0),       -- Monto total de la venta

    -- Relaciones con dimensiones
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (sales_rep_id) REFERENCES dim_sales_rep(sales_rep_id),
    FOREIGN KEY (region_id) REFERENCES dim_region(region_id),
    FOREIGN KEY (customer_type_id) REFERENCES dim_customer_type(customer_type_id),
    FOREIGN KEY (payment_method_id) REFERENCES dim_payment_method(payment_method_id),
    FOREIGN KEY (sales_channel_id) REFERENCES dim_sales_channel(sales_channel_id)
);

-- =========================================================
-- ÍNDICES
-- =========================================================

-- Índice para consultas por fecha y región (común en agregaciones)
CREATE INDEX IF NOT EXISTS idx_fact_sales_date_region
ON fact_sales (date_id, region_id);

-- =========================================================
-- VISTAS
-- =========================================================

-- Vista de ventas mensuales por región
CREATE VIEW IF NOT EXISTS vw_monthly_region_sales AS
SELECT
    d.year,
    d.month,
    d.month_name,
    r.region_name,
    COUNT(f.sale_id) AS total_transactions,    -- Número de transacciones
    SUM(f.sales_amount) AS total_revenue,      -- Ingreso total
    AVG(f.sales_amount) AS avg_sale_value      -- Valor promedio por venta
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY d.year, d.month, d.month_name, r.region_name;
