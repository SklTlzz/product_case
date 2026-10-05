WITH product_cost_profit AS (
    SELECT
        products.id AS product_id,
        products.name AS product_name,
        SUM(items.cost) AS total_cost,
        SUM(items.product_retail_price) AS plan_revenue
    FROM inventory_items AS items

    JOIN products ON(products.id = items.product_id)

    GROUP BY products.id, products.name
), products_count AS (
    SELECT
        products.id AS product_id,
        products.name AS product_name,
        -- COUNT(DISTINCT products.id) AS products_count,
        COUNT(DISTINCT items.id) AS product_items_count
    FROM products

    JOIN inventory_items AS items ON(products.id = items.product_id)

    GROUP BY products.id, products.name
)