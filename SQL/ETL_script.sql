--DIMENSION TABLES
-- 1. Dim Customers
CREATE TABLE dim_customers (
    customer_key        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id         BIGINT UNIQUE,
    customer_name       VARCHAR(255),
    email               VARCHAR(255),
    phone               VARCHAR(30),
    address             VARCHAR(500),
    area                VARCHAR(255),
    pincode             VARCHAR(20),
    registration_date   DATE,
    customer_segment    VARCHAR(100),
    total_orders        INT,
    avg_order_value     DECIMAL(10,2)
);

-- 2. Dim Products
CREATE TABLE dim_products (
    product_key         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id          BIGINT UNIQUE,
    product_name        VARCHAR(255),
    category            VARCHAR(255),
    brand               VARCHAR(255),
    price               DECIMAL(10,2),
    mrp                 DECIMAL(10,2),
    margin_percentage   DECIMAL(5,2),
    shelf_life_days     INT,
    min_stock_level     INT,
    max_stock_level     INT
);

-- 3. Dim Inventory Products (derived from products + inventory)
CREATE TABLE dim_inventory_products (
    inventory_product_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_key           INT UNIQUE,
    stock_qty             INT,
    purchase_price        DECIMAL(10,2),
    selling_price         DECIMAL(10,2),
    expiry_date           DATE,
    
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_key) REFERENCES dim_products(product_key)
);

-- 4. Dim Stores
CREATE TABLE dim_stores (
    store_key     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    store_id      BIGINT UNIQUE,
    store_name    VARCHAR(255),
    city          VARCHAR(255),
    area          VARCHAR(255),
    region        VARCHAR(255)
);

-- 5. Dim Delivery Partners
CREATE TABLE dim_delivery_partners (
    delivery_partner_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    delivery_partner_id   BIGINT UNIQUE,
    partner_name          VARCHAR(255),
    zone                  VARCHAR(255),
    avg_rating            DECIMAL(3,2)
);

-- 6. Dim Campaigns
CREATE TABLE dim_campaigns (
    campaign_key      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campaign_id       BIGINT UNIQUE,
    campaign_name     VARCHAR(255),
    channel           VARCHAR(50),
    campaign_date_key INT,

    CONSTRAINT fk_campaign_date FOREIGN KEY (campaign_date_key) REFERENCES dim_date(date_key)
);

-- 7. Dim Date
CREATE TABLE dim_date (
    date_key       INT PRIMARY KEY,       -- YYYYMMDD
    date_value     DATE UNIQUE,
    day            INT,
    month          INT,
    month_name     VARCHAR(20),
    year           INT,
    quarter        INT,
    week           INT,
    day_of_week    INT,
    day_name       VARCHAR(20),
    is_weekend     BOOLEAN
);


--FACT TABLES
-- 1. Fact Sales
CREATE TABLE fact_sales (
    sales_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    customer_key INT NOT NULL,
    store_key INT NOT NULL,
    delivery_partner_key INT,
    order_date_key INT NOT NULL,
    order_status VARCHAR(50),
    payment_method VARCHAR(50),
    total_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    final_amount DECIMAL(10,2),

    -- Foreign Keys
    CONSTRAINT fk_sales_customer FOREIGN KEY (customer_key) REFERENCES dim_customers(customer_key),
    CONSTRAINT fk_sales_store FOREIGN KEY (store_key) REFERENCES dim_stores(store_key),
    CONSTRAINT fk_sales_delivery FOREIGN KEY (delivery_partner_key) REFERENCES dim_delivery_partners(delivery_partner_key),
    CONSTRAINT fk_sales_date FOREIGN KEY (order_date_key) REFERENCES dim_date(date_key)
);

-- 2. Fact Order Items
CREATE TABLE fact_order_items (
    order_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_key INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,

    -- Foreign Keys
    CONSTRAINT fk_oi_order FOREIGN KEY (order_id) REFERENCES fact_sales(order_id),
    CONSTRAINT fk_oi_product FOREIGN KEY (product_key) REFERENCES dim_products(product_key)
);

-- 3. Fact Inventory Movements
CREATE TABLE fact_inventory_movements (
    movement_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_key INT NOT NULL,
    store_key INT NOT NULL,
    movement_date_key INT NOT NULL,
    movement_type VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    stock_level INT,
    reorder_level INT,

    -- Foreign Keys
    CONSTRAINT fk_inv_product FOREIGN KEY (product_key) REFERENCES dim_products(product_key),
    CONSTRAINT fk_inv_store FOREIGN KEY (store_key) REFERENCES dim_stores(store_key),
    CONSTRAINT fk_inv_date FOREIGN KEY (movement_date_key) REFERENCES dim_date(date_key)
);

-- 4. Fact Delivery Performance
CREATE TABLE fact_delivery_performance (
    delivery_perf_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    delivery_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    delivery_partner_key INT NOT NULL,
    delivery_date_key INT NOT NULL,
    delivery_time_minutes INT,
    distance_km DECIMAL(10,2),
    delivery_status VARCHAR(50),
    delivery_rating INT,

    -- Foreign Keys
    CONSTRAINT fk_dp_order FOREIGN KEY (order_id) REFERENCES fact_sales(order_id),
    CONSTRAINT fk_dp_partner FOREIGN KEY (delivery_partner_key) REFERENCES dim_delivery_partners(delivery_partner_key),
    CONSTRAINT fk_dp_date FOREIGN KEY (delivery_date_key) REFERENCES dim_date(date_key)
);

-- 5. Fact Marketing Performance
CREATE TABLE fact_marketing_performance (
    marketing_fact_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campaign_key INT NOT NULL,
    date_key INT NOT NULL,
    channel VARCHAR(50),
    total_spend DECIMAL(12,2),
    impressions BIGINT,
    clicks BIGINT,
    conversions BIGINT,
    revenue DECIMAL(12,2),

    -- Foreign Keys
    CONSTRAINT fk_mp_campaign FOREIGN KEY (campaign_key) REFERENCES dim_campaigns(campaign_key),
    CONSTRAINT fk_mp_date FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);







--Populate dim_date

--Assuming you want to cover all dates from orders, deliveries, campaigns, inventory:

INSERT INTO dim_date (date_key, date_value, day, month, month_name, year, quarter, week, day_of_week, day_name, is_weekend)
SELECT DISTINCT
    TO_CHAR(date_value, 'YYYYMMDD')::INT AS date_key,
    date_value,
    EXTRACT(DAY FROM date_value) AS day,
    EXTRACT(MONTH FROM date_value) AS month,
    TO_CHAR(date_value, 'Mon') AS month_name,
    EXTRACT(YEAR FROM date_value) AS year,
    EXTRACT(QUARTER FROM date_value) AS quarter,
    EXTRACT(WEEK FROM date_value) AS week,
    EXTRACT(DOW FROM date_value) AS day_of_week,
    TO_CHAR(date_value, 'Day') AS day_name,
    CASE WHEN EXTRACT(DOW FROM date_value) IN (0,6) THEN TRUE ELSE FALSE END AS is_weekend
FROM (
    SELECT order_date AS date_value FROM stg_orders
    UNION
    SELECT actual_time::DATE FROM stg_delivery
    UNION
    SELECT date FROM stg_campaigns
    UNION
    SELECT date FROM stg_inventory
) AS all_dates
ON CONFLICT (date_key) DO NOTHING;


--Populate dim_customers
INSERT INTO dim_customers (
    customer_id, customer_name, email, phone, address, area, pincode, registration_date, customer_segment, total_orders, avg_order_value
)
SELECT DISTINCT
    customer_id,
    customer_name,
    email,
    phone,
    address,
    area,
    pincode,
    registration_date,
    customer_segment,
    total_orders,
    avg_order_value
FROM stg_customers;


--Populate dim_products
INSERT INTO dim_products (
    product_id, product_name, category, brand, price, mrp, margin_percentage, shelf_life_days, min_stock_level, max_stock_level
)
SELECT DISTINCT
    product_id,
    product_name,
    category,
    brand,
    price,
    mrp,
    margin_percentage,
    shelf_life_days,
    min_stock_level,
    max_stock_level
FROM stg_products;


--Populate dim_inventory_products
INSERT INTO dim_inventory_products (product_key, stock_qty, purchase_price, selling_price, expiry_date)
SELECT 
    dp.product_key,
    COALESCE(SUM(si.stock_received - si.damaged_stock), 0) AS stock_qty,
    dp.price AS purchase_price,
    dp.mrp AS selling_price,
    CURRENT_DATE + (dp.shelf_life_days || ' day')::INTERVAL AS expiry_date
FROM stg_inventory si
JOIN dim_products dp ON si.product_id = dp.product_id
GROUP BY dp.product_key, dp.price, dp.mrp, dp.shelf_life_days;

--Populate dim_stores
INSERT INTO dim_stores (store_id, store_name, city, area, region)
SELECT DISTINCT
    so.store_id,
    'Store ' || so.store_id AS store_name,
    'Unknown' AS city,          -- placeholder
    'Unknown' AS area,          -- placeholder
    'Region 1' AS region        -- placeholder
FROM stg_orders so
ON CONFLICT (store_id) DO NOTHING;
--If you get real store metadata later, you can update this table.

--Populate dim_delivery_partners
INSERT INTO dim_delivery_partners (delivery_partner_id, partner_name, zone, avg_rating)
SELECT DISTINCT
    sd.delivery_partner_id,
    'Partner ' || sd.delivery_partner_id AS partner_name, -- placeholder
    'Zone 1' AS zone,                                     -- placeholder
    NULL::DECIMAL(3,2) AS avg_rating
FROM stg_delivery sd
ON CONFLICT (delivery_partner_id) DO NOTHING;

--Populate dim_campaigns
INSERT INTO dim_campaigns (campaign_id, campaign_name, channel, campaign_date_key)
SELECT 
    sc.campaign_id,
    sc.campaign_name,
    sc.channel,
    dd.date_key
FROM stg_campaigns sc
JOIN dim_date dd ON sc.date = dd.date_value
ON CONFLICT (campaign_id) DO NOTHING;



--Populate fact_sales
INSERT INTO fact_sales (order_id, customer_key, store_key, delivery_partner_key, order_date_key, order_status, payment_method, total_amount, discount_amount, final_amount)
SELECT 
    so.order_id,
    dc.customer_key,
    ds.store_key,
    ddp.delivery_partner_key,
    dd.date_key,
    so.delivery_status,
    so.payment_method,
    so.order_total AS total_amount,
    0 AS discount_amount,  -- placeholder
    so.order_total AS final_amount
FROM stg_orders so
JOIN dim_customers dc ON so.customer_id = dc.customer_id
JOIN dim_stores ds ON so.store_id = ds.store_id
LEFT JOIN dim_delivery_partners ddp ON so.delivery_partner_id = ddp.delivery_partner_id
JOIN dim_date dd ON so.order_date::DATE = dd.date_value
ON CONFLICT (order_id) DO NOTHING;


--Populate fact_order_items
INSERT INTO fact_order_items (order_id, product_key, quantity, unit_price)
SELECT 
    soi.order_id,
    dp.product_key,
    soi.quantity,
    soi.unit_price
FROM stg_order_items soi
JOIN dim_products dp ON soi.product_id = dp.product_id
ON CONFLICT (order_item_id) DO NOTHING;


--Populate fact_inventory_movements
INSERT INTO fact_inventory_movements (product_key, store_key, movement_date_key, movement_type, quantity, stock_level, reorder_level)
SELECT
    dp.product_key,
    (SELECT store_key FROM dim_stores LIMIT 1) AS store_key,  -- single placeholder store
    dd.date_key,
    'IN' AS movement_type,
    si.stock_received,
    NULL::INT AS stock_level,
    NULL::INT AS reorder_level
FROM stg_inventory si
JOIN dim_products dp ON si.product_id = dp.product_id
JOIN dim_date dd ON si.date = dd.date_value
ON CONFLICT (movement_id) DO NOTHING;



--Populate fact_delivery_performance
INSERT INTO fact_delivery_performance (delivery_id, order_id, delivery_partner_key, delivery_date_key, delivery_time_minutes, distance_km, delivery_status, delivery_rating)
SELECT
    sd.order_id AS delivery_id,
    sd.order_id,
    ddp.delivery_partner_key,
    dd.date_key,
    ROUND(sd.delivery_time_minutes)::INT,
    sd.distance_km,
    sd.delivery_status,
    NULL AS delivery_rating
FROM stg_delivery sd
JOIN dim_delivery_partners ddp ON sd.delivery_partner_id = ddp.delivery_partner_id
JOIN dim_date dd ON sd.actual_time::DATE = dd.date_value
ON CONFLICT (delivery_perf_id) DO NOTHING;


--Populate fact_marketing_performance
INSERT INTO fact_marketing_performance (campaign_key, date_key, channel, total_spend, impressions, clicks, conversions, revenue)
SELECT
    dc.campaign_key,
    dd.date_key,
    sc.channel,
    sc.spend AS total_spend,
    sc.impressions,
    sc.clicks,
    sc.conversions,
    sc.revenue_generated AS revenue
FROM stg_campaigns sc
JOIN dim_campaigns dc ON sc.campaign_id = dc.campaign_id
JOIN dim_date dd ON sc.date = dd.date_value
ON CONFLICT (marketing_fact_id) DO NOTHING;









