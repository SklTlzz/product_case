-- ARPU, ARPPU, AOV, AVG_MARGIN

WITH count_users AS (
    SELECT
        COUNT(DISTINCT users.id) AS count_all_users,
        COUNT(
            DISTINCT CASE 
                WHEN order_items.status != 'Cancelled' THEN users.id 
            END
        ) AS count_gross_paying_users,
        COUNT(
            DISTINCT CASE
                WHEN order_items.status NOT IN ('Cancelled', 'Returned') THEN users.id
            END
        ) AS count_net_paying_users
    FROM users

    LEFT JOIN order_items ON (users.id = order_items.user_id)
), arpus AS (
    SELECT
        ROUND(SUM(
            CASE
                WHEN status != 'Cancelled' THEN sale_price
                ELSE 0
            END
        ) / NULLIF((SELECT count_all_users FROM count_users), 0), 2) AS gross_arpu,
        ROUND(SUM(
            CASE
                WHEN status NOT IN ('Returned', 'Cancelled') THEN sale_price
                ELSE 0
            END
        ) / NULLIF((SELECT count_all_users FROM count_users), 0), 2) AS net_arpu,
        ROUND(SUM(
            CASE
                WHEN status != 'Cancelled' THEN sale_price
                ELSE 0
            END
        ) / NULLIF((SELECT count_gross_paying_users FROM count_users), 0), 2) AS gross_arppu,
        ROUND(SUM(
            CASE
                WHEN status NOT IN ('Returned', 'Cancelled') THEN sale_price
                ELSE 0
            END
        ) / NULLIF((SELECT count_net_paying_users FROM count_users), 0), 2) AS net_arppu
    FROM order_items
), aov AS (
    SELECT
        ROUND(SUM(
            CASE
                WHEN status != 'Cancelled' THEN sale_price
                ELSE 0
            END
        )
        /
        NULLIF(COUNT(DISTINCT CASE WHEN status != 'Cancelled' THEN order_id END), 0), 2) AS aov
    FROM order_items
), avg_margin AS (
    SELECT
        AVG(order_items.sale_price - products.cost) AS avg_margin
    FROM order_items

    JOIN products ON (products.id = order_items.product_id)

    WHERE order_items.status NOT IN ('Cancelled', 'Returned')
)

SELECT
    *
FROM arpus, aov, avg_margin;


-- Costs and profits by product

WITH cost_profit_by_product AS (
    SELECT
        products.id AS product_id,
        products.name AS product_name,
        SUM(items.cost) AS total_cost,
        SUM(items.product_retail_price) AS plan_revenue
    FROM inventory_items AS items

    JOIN products ON(products.id = items.product_id)

    GROUP BY products.id, products.name
)

SELECT
    *
FROM cost_profit_by_product;


-- Counts by product

WITH products_count AS (
    SELECT
        products.id AS product_id,
        products.name AS product_name,
        COUNT(DISTINCT items.id) AS product_items_count
    FROM products

    JOIN inventory_items AS items ON(products.id = items.product_id)

    GROUP BY products.id, products.name
)

SELECT
    *
FROM products_count;


-- Centers by items count

WITH centers_by_items AS (
    SELECT
        items.product_distribution_center_id AS center_id,
        dist_centers.name AS center_name,
        COUNT(*) AS distribution_center_count
    FROM inventory_items AS items

    JOIN distribution_centers AS dist_centers ON(dist_centers.id = items.product_distribution_center_id)

    GROUP BY items.product_distribution_center_id, dist_centers.name
)

SELECT
    *
FROM centers_by_items;


-- Revenue by month

WITH order_items_by_months AS (
    SELECT
        TO_CHAR(created_at, 'YYYY-MM') AS order_date,
        sale_price
    FROM order_items

    WHERE status NOT IN ('Cancelled', 'Returned')
), revenue_by_months AS (
    SELECT
        order_date,
        SUM(sale_price) AS revenue
    FROM order_items_by_months AS items

    GROUP BY order_date
)

SELECT
    *
FROM revenue_by_months;
