WITH users_count AS (
    SELECT
        COUNT(DISTINCT users.id) AS users_count,
        COUNT(DISTINCT orders.user_id) AS paying_users_count
    FROM users

    LEFT JOIN orders ON(users.id = orders.user_id)
), products_count AS (
    SELECT
        COUNT(DISTINCT products.id) AS products_count,
        COUNT(DISTINCT items.id) AS product_items_count
    FROM products

    JOIN inventory_items AS items ON(products.id = items.product_id)
), product_cost_profit AS (
    SELECT
        SUM(cost) AS total_cost,
        SUM(product_retail_price) AS plan_revenue,
        SUM(product_retail_price) - SUM(cost) AS plan_profit
    FROM inventory_items

    WHERE sold_at IS NULL
), order_items_counts AS (
    SELECT
        COUNT(returned_at) AS count_returned,
        COUNT(*) AS count_ordered,
        ROUND(COUNT(returned_at) * 1.0 / COUNT(*) * 100, 2) AS returned_prct
    FROM order_items
), avg_product_delivering AS (
    SELECT
        ROUND(AVG(EXTRACT(EPOCH FROM (delivered_at - created_at) / 86400)), 2) AS avg_delivering_days
    FROM order_items
)

SELECT
    *
FROM users_count, products_count, product_cost_profit, order_items_counts, avg_product_delivering;

WITH centers_by_items AS (
    SELECT
        items.product_distribution_center_id AS center_id,
        dist_centers.name AS center_name,
        COUNT(*) AS distribution_center_count
    FROM inventory_items AS items

    JOIN distribution_centers AS dist_centers ON(dist_centers.id = items.product_distribution_center_id)

    GROUP BY items.product_distribution_center_id, dist_centers.name
), max_items_center AS (
    SELECT
        center_id, center_name, distribution_center_count
    FROM centers_by_items

    WHERE distribution_center_count = (SELECT MAX(distribution_center_count) FROM centers_by_items)
)

SELECT
    *
FROM centers_by_items;
