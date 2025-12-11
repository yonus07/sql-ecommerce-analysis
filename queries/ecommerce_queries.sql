<?xml version="1.0" encoding="UTF-8"?><sqlb_project><db path="D:/Downloads/ecommerce.db" readonly="0" foreign_keys="1" case_sensitive_like="0" temp_store="0" wal_autocheckpoint="1000" synchronous="2"/><attached/><window><main_tabs open="structure browser pragmas query" current="3"/></window><tab_structure><column_width id="0" width="300"/><column_width id="1" width="0"/><column_width id="2" width="100"/><column_width id="3" width="2559"/><column_width id="4" width="0"/><expanded_item id="0" parent="1"/><expanded_item id="1" parent="1"/><expanded_item id="2" parent="1"/><expanded_item id="3" parent="1"/></tab_structure><tab_browse><table title="ecommerce&#10;" custom_title="0" dock_id="1" table="4,10:mainecommerce&#10;"/><dock_state state="000000ff00000000fd00000001000000020000043b000002aefc0100000001fb000000160064006f0063006b00420072006f007700730065003101000000000000043b0000013300ffffff000002580000000000000004000000040000000800000008fc00000000"/><default_encoding codec=""/><browse_table_settings><table schema="main" name="ecommerce&#10;" show_row_id="0" encoding="" plot_x_axis="" unlock_view_pk="_rowid_" freeze_columns="0"><sort><column index="0" mode="0"/></sort><column_widths><column index="1" value="77"/><column index="2" value="93"/><column index="3" value="93"/><column index="4" value="54"/><column index="5" value="78"/><column index="6" value="85"/><column index="7" value="78"/><column index="8" value="69"/><column index="9" value="163"/><column index="10" value="117"/><column index="11" value="55"/><column index="12" value="65"/><column index="13" value="70"/><column index="14" value="85"/><column index="15" value="79"/><column index="16" value="132"/><column index="17" value="42"/><column index="18" value="78"/><column index="19" value="70"/><column index="20" value="85"/></column_widths><filter_values/><conditional_formats/><row_id_formats/><display_formats/><hidden_columns/><plot_y_axes/><global_filter/></table></browse_table_settings></tab_browse><tab_sql><sql name="SQL 1*">-- ecommerce_queries.sql
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
HAVING orders_count &gt; 1
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
WHERE total_spent &gt; (SELECT AVG(total_spent) FROM spend)
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
-- 12) Reviews that mention &quot;great&quot;
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
</sql><sql name="SQL 2*"></sql><sql name="SQL 3*">-- 2) Basic filters / sample queries
-- Recent orders (last 30 days) - adjust date format if needed
SELECT * FROM ecommerce_dataset
WHERE order_date &gt;= date('now','-30 day')
ORDER BY order_date DESC
LIMIT 20;

</sql><sql name="SQL 4*">-- Orders with high quantity or high unit price
SELECT order_id, product_name, quantity, unit_price, (quantity * unit_price) AS line_total
FROM ecommerce_dataset
WHERE quantity &gt;= 10 OR unit_price &gt; 1000
ORDER BY line_total DESC
LIMIT 20;</sql><current_tab id="0"/></tab_sql></sqlb_project>
