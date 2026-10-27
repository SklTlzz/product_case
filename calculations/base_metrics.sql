CREATE OR REPLACE VIEW base_metrics AS

WITH users_count AS (
    SELECT
        COUNT(DISTINCT users.id) AS users_count,
        COUNT(DISTINCT orders.user_id) AS paying_users_count
    FROM users

    LEFT JOIN orders ON(users.id = orders.user_id AND orders.status != 'Cancelled')
), products_count AS (
    SELECT
        COUNT(DISTINCT product_id) AS products_count,
        COUNT(DISTINCT id) AS product_items_count
    FROM inventory_items
), product_cost_profit AS (
    SELECT
        SUM(cost) AS total_cost,
        SUM(product_retail_price) AS plan_revenue,
        SUM(product_retail_price) - SUM(cost) AS plan_profit
    FROM inventory_items

    WHERE sold_at IS NULL
), order_items_counts AS (
    SELECT
        COUNT(DISTINCT order_id) AS count_ordered,
        COUNT(*) AS count_ordered_items
    FROM order_items
), order_returns_cancels AS (
    SELECT
        SUM(CASE 
            WHEN status = 'Returned' THEN 1
            ELSE 0
        END) AS count_returned,
        SUM(CASE 
            WHEN status = 'Cancelled' THEN 1
            ELSE 0
        END) AS count_cancelled,
        SUM(CASE 
            WHEN status IN ('Returned', 'Cancelled') THEN 1
            ELSE 0
        END) AS count_returned_cancelled,
        ROUND(SUM(CASE 
            WHEN status IN ('Returned', 'Cancelled') THEN 1
            ELSE 0
        END) * 1.0 / COUNT(*) * 100, 2) AS returned_cancelled_pct
    FROM order_items
), avg_product_delivering AS (
    SELECT
        ROUND(AVG(EXTRACT(EPOCH FROM (delivered_at - created_at) / 86400)), 2) AS avg_delivering_days
    FROM order_items

    WHERE status != 'Cancelled'
), revenue AS (
    SELECT
        SUM(sale_price) AS total_revenue
    FROM order_items

    WHERE status != 'Cancelled'
)

SELECT
    *
FROM users_count, products_count, product_cost_profit, order_items_counts, order_returns_cancels, avg_product_delivering, revenue;
