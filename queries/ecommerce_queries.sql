-- ecommerce_queries.sql
-- Queries for SQLite based on table: ecommerce_dataset

-------------------------------------------------------
-- 0) Preview the data
-------------------------------------------------------
SELECT * FROM ecommerce_dataset LIMIT 10;

-------------------------------------------------------
-- 1) Row counts and basic info
-------------------------------------------------------
SELECT COUNT(*) AS total_rows FROM ecommerce_dataset;

SELECT COUNT(DISTINCT customer_id) AS total_customers FROM ecommerce_dataset;

SELECT COUNT(DISTINCT order_id) AS total_orders FROM ecommerce_dataset;

SELECT COUNT(DISTINCT product_id) AS total_products FROM ecommerce_dataset;

-------------------------------------------------------
-- 2) Total revenue (quantity * unit_price)
-------------------------------------------------------
SELECT 
    SUM(quantity * unit_price) AS total_revenue
FROM ecommerce_dataset;

-------------------------------------------------------
-- 3) Revenue by country
-------------------------------------------------------
SELECT 
    country,
    SUM(quantity * unit_price) AS revenue
FROM ecommerce_dataset
GROUP BY country
ORDER BY revenue DESC;

-------------------------------------------------------
-- 4) Top 10 customers by total spending
-------------------------------------------------------
SELECT 
    customer_id,
    first_name || ' ' || last_name AS customer_name,
    SUM(quantity * unit_price) AS total_spent,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM ecommerce_dataset
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-------------------------------------------------------
-- 5) Top 10 best-selling products (units sold)
-------------------------------------------------------
SELECT 
    product_id,
    product_name,
    category,
    SUM(quantity) AS units_sold,
    SUM(quantity * unit_price) AS revenue_generated
FROM ecommerce_dataset
GROUP BY product_id, product_name, category
ORDER BY units_sold DESC
LIMIT 10;

-------------------------------------------------------
-- 6) Monthly revenue trends (YYYY-MM)
-------------------------------------------------------
SELECT 
    substr(order_date, 1, 7) AS month,
    SUM(quantity * unit_price) AS monthly_revenue
FROM ecommerce_dataset
GROUP BY month
ORDER BY month;

-------------------------------------------------------
-- 7) Category performance summary
-------------------------------------------------------
SELECT 
    category,
    SUM(quantity * unit_price) AS category_revenue,
    SUM(quantity) AS total_units_sold,
    AVG(unit_price) AS avg_price
FROM ecommerce_dataset
GROUP BY category
ORDER BY category_revenue DESC;

-------------------------------------------------------
-- 8) Repeat customers (more than 1 order)
-------------------------------------------------------
SELECT 
    customer_id,
    first_name || ' ' || last_name AS customer_name,
    COUNT(DISTINCT order_id) AS orders_count
FROM ecommerce_dataset
GROUP BY customer_id
HAVING orders_count > 1
ORDER BY orders_count DESC;

-------------------------------------------------------
-- 9) Customers spending more than the average customer
-------------------------------------------------------
WITH spend AS (
    SELECT 
        customer_id,
        SUM(quantity * unit_price) AS total_spent
    FROM ecommerce_dataset
    GROUP BY customer_id
)
SELECT 
    customer_id,
    total_spent
FROM spend
WHERE total_spent > (SELECT AVG(total_spent) FROM spend)
ORDER BY total_spent DESC;

-------------------------------------------------------
-- 10) Orders that were cancelled or refunded
-------------------------------------------------------
SELECT 
    order_id,
    order_status,
    SUM(quantity * unit_price) AS order_value
FROM ecommerce_dataset
WHERE lower(order_status) LIKE '%cancel%'
   OR lower(order_status) LIKE '%refund%'
GROUP BY order_id, order_status;

-------------------------------------------------------
-- 11) Rating distribution (how many 1-star, 2-star, etc.)
-------------------------------------------------------
SELECT 
    rating,
    COUNT(*) AS total_reviews
FROM ecommerce_dataset
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY rating DESC;

-------------------------------------------------------
-- 12) Reviews that mention "great"
-------------------------------------------------------
SELECT 
    review_id,
    product_name,
    rating,
    review_text
FROM ecommerce_dataset
WHERE review_text IS NOT NULL
  AND lower(review_text) LIKE '%great%'
ORDER BY review_date DESC;

-------------------------------------------------------
-- 13) Create a view for repeated analysis: customer_revenue
-------------------------------------------------------
CREATE VIEW IF NOT EXISTS customer_revenue AS
SELECT 
    customer_id,
    first_name || ' ' || last_name AS customer_name,
    SUM(quantity * unit_price) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_dataset
GROUP BY customer_id;

-------------------------------------------------------
-- 14) Query the view
-------------------------------------------------------
SELECT *
FROM customer_revenue
ORDER BY total_revenue DESC
LIMIT 20;

-------------------------------------------------------
-- 15) Useful indexes for faster queries
-------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_customer_id ON ecommerce_dataset(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_id ON ecommerce_dataset(order_id);
CREATE INDEX IF NOT EXISTS idx_product_id ON ecommerce_dataset(product_id);
CREATE INDEX IF NOT EXISTS idx_order_date ON ecommerce_dataset(order_date);
CREATE INDEX IF NOT EXISTS idx_category ON ecommerce_dataset(category);

-------------------------------------------------------
-- END OF FILE
-------------------------------------------------------
