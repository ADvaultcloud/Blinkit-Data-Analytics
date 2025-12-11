--stg_customers
CREATE TABLE stg_customers (
    customer_id BIGINT,
    customer_name TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    area TEXT,
    pincode TEXT,
    registration_date DATE,
    customer_segment TEXT,
    total_orders INT,
    avg_order_value DECIMAL(10,2)
);


--stg_orders
DROP TABLE IF EXISTS stg_orders;
CREATE TABLE stg_orders (
    order_id BIGINT,
    customer_id BIGINT,
    order_date TIMESTAMP,
    promised_delivery_time TIMESTAMP,
    actual_delivery_time TIMESTAMP,
    delivery_status TEXT,
    order_total DECIMAL(10,2),
    payment_method TEXT,
    delivery_partner_id BIGINT,
    store_id BIGINT
);

--stg_order_items
CREATE TABLE stg_order_items (
    order_id BIGINT,
    product_id BIGINT,
    quantity INT,
    unit_price DECIMAL(10,2)
);


--stg_products
CREATE TABLE stg_products (
    product_id BIGINT,
    product_name TEXT,
    category TEXT,
    brand TEXT,
    price DECIMAL(10,2),
    mrp DECIMAL(10,2),
    margin_percentage DECIMAL(10,2),
    shelf_life_days INT,
    min_stock_level INT,
    max_stock_level INT
);


--stg_delivery
DROP TABLE IF EXISTS stg_delivery;
CREATE TABLE stg_delivery (
    order_id BIGINT NOT NULL,
    delivery_partner_id INT NOT NULL,
    promised_time TIMESTAMP NOT NULL,
    actual_time TIMESTAMP NOT NULL,
    delivery_time_minutes DECIMAL(6,2),  -- use decimal to accept the .0 values
    distance_km DECIMAL(5,2),
    delivery_status VARCHAR(50),
    reasons_if_delayed VARCHAR(255)
);
UPDATE stg_delivery
SET delivery_time_minutes = ROUND(delivery_time_minutes);


--stg_inventory
CREATE TABLE stg_inventory (
    product_id BIGINT NOT NULL,
    date DATE NOT NULL,
    stock_received INT,
    damaged_stock INT
);


--stg_inventory_new
CREATE TABLE stg_inventory_new (
    product_id BIGINT NOT NULL,
    date VARCHAR(7) NOT NULL,   -- stores format like 'Mar-23'
    stock_received INT,
    damaged_stock INT
);


--stg_feedback
CREATE TABLE stg_feedback (
    feedback_id BIGINT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    rating INT,
    feedback_text TEXT,
    feedback_category VARCHAR(100),
    sentiment VARCHAR(50),
    feedback_date DATE
);


--stg_marketing
CREATE TABLE stg_campaigns (
    campaign_id BIGINT PRIMARY KEY,
    campaign_name VARCHAR(255),
    date DATE,
    target_audience VARCHAR(100),
    channel VARCHAR(50),
    impressions BIGINT,
    clicks BIGINT,
    conversions BIGINT,
    spend DECIMAL(12,2),
    revenue_generated DECIMAL(12,2),
    roas DECIMAL(5,2)
);









