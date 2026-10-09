-- Cohorts revenune

WITH first_users_order AS (
    SELECT
        user_id,
        MIN(created_at) AS first_order
    FROM order_items

    WHERE status NOT IN ('Returned', 'Cancelled')

    GROUP BY user_id
)
SELECT
    TO_CHAR(users.first_order, 'YYYY-MM') AS first_order_date,
    (EXTRACT(YEAR FROM items.created_at) - EXTRACT(YEAR FROM users.first_order)) * 12 + (EXTRACT(MONTH FROM items.created_at) - EXTRACT(MONTH FROM users.first_order)) AS months_from_first_order,
    ROUND(SUM(items.sale_price), 2) AS cohort_revenue
FROM first_users_order AS users

JOIN order_items AS items ON(items.user_id = users.user_id)

WHERE items.status NOT IN ('Cancelled', 'Returned')

GROUP BY first_order_date, months_from_first_order

ORDER BY first_order_date, months_from_first_order;


-- Retention rate

WITH first_users_order AS (
    SELECT
        user_id,
        MIN(created_at) AS first_order
    FROM order_items

    WHERE status NOT IN ('Returned', 'Cancelled')

    GROUP BY user_id
), cohorts_size AS (
    SELECT
        TO_CHAR(first_order, 'YYYY-MM') AS first_order_date,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM first_users_order

    GROUP BY TO_CHAR(first_order, 'YYYY-MM')
), cohorts_active_users AS (
    SELECT
        TO_CHAR(users.first_order, 'YYYY-MM') AS first_order_date,
        COUNT(DISTINCT items.user_id) AS active_users,
        (EXTRACT(YEAR FROM items.created_at) - EXTRACT(YEAR FROM users.first_order)) * 12 + (EXTRACT(MONTH FROM items.created_at) - EXTRACT(MONTH FROM users.first_order)) AS months_from_first_order
    FROM order_items AS items

    JOIN first_users_order AS users ON (items.user_id = users.user_id)

    WHERE items.status NOT IN ('Cancelled', 'Returned')

    GROUP BY first_order_date, months_from_first_order
)

SELECT
    sizes.first_order_date,
    users.months_from_first_order,
    ROUND(users.active_users * 100.0 / NULLIF(sizes.cohort_size, 0), 2) AS retention_rate
FROM cohorts_active_users AS users

JOIN cohorts_size AS sizes ON (users.first_order_date = sizes.first_order_date)

ORDER BY sizes.first_order_date, users.months_from_first_order;
