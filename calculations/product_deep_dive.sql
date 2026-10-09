-- Sellings by product

WITH sold_items AS (
    SELECT
        product_id, product_name,
        COUNT(*) AS all_items_product_count,
        COUNT(sold_at) AS sold_items_product_count,
        ROUND(COUNT(sold_at) * 1.0 / NULLIF(COUNT(*), 0) * 100, 2) AS sold_prct
    FROM inventory_items

    GROUP BY product_id, product_name
), median AS (
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY all_items_product_count) AS median_value
    FROM sold_items
), ranked_by_sellings_products AS (
    SELECT
        *,
        CASE
            WHEN all_items_product_count >= median.median_value THEN 'Big Volume' 
            ELSE 'Small Volume'
        END AS volume_segment
    FROM sold_items, median
)

SELECT
    product_id, product_name, all_items_product_count, sold_items_product_count, sold_prct, volume_segment,
    DENSE_RANK() OVER(PARTITION BY volume_segment ORDER BY sold_prct DESC) AS item_selling_rank
FROM ranked_by_sellings_products;


-- Products margin

WITH products_margin AS (
    SELECT
        id, name,
        ROUND((retail_price - cost) * 1.0 / NULLIF(retail_price, 0) * 100, 2) AS product_margin
    FROM products
), ranked_by_margin AS (
    SELECT
        id, name, product_margin,
        DENSE_RANK() OVER(ORDER BY product_margin DESC) AS product_margin_rank
    FROM products_margin
)

SELECT
    *
FROM ranked_by_margin;


-- Returns and cancels by category

WITH returns_cancells_by_category AS (
    SELECT
        products.category,
        COUNT(*) AS count_items_orders,
        COUNT(CASE WHEN items.status = 'Returned' THEN items.id END) AS count_returned,
        COUNT(CASE WHEN items.status = 'Cancelled' THEN items.id END) AS count_cancelled,
        COUNT(CASE WHEN items.status IN ('Cancelled', 'Returned') THEN items.id END) AS count_returned_and_cancelled,
        ROUND(COUNT(CASE WHEN items.status = 'Returned' THEN items.id END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS prct_returned,
        ROUND(COUNT(CASE WHEN items.status = 'Cancelled' THEN items.id END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS prct_cancelled,
        ROUND(COUNT(CASE WHEN items.status IN ('Cancelled', 'Returned') THEN items.id END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS prct_returned_and_cancelled
    FROM products

    JOIN order_items AS items ON (items.product_id = products.id)

    GROUP BY products.category
), median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY count_items_orders) AS median_value
    FROM returns_cancells_by_category
), ranked_by_category AS (
    SELECT
        *,
        CASE
            WHEN count_items_orders >= median.median_value THEN 'Big Volume'
            ELSE 'Small Volume'
        END AS volume_segment
    FROM returns_cancells_by_category, median
)

SELECT
    category, count_items_orders, count_returned, count_cancelled, count_returned_and_cancelled, prct_returned, prct_cancelled, prct_returned_and_cancelled, volume_segment,
    DENSE_RANK() OVER(PARTITION BY volume_segment ORDER BY prct_returned_and_cancelled DESC) AS category_rank
FROM ranked_by_category;


-- Returns and cancels by brand

WITH returns_cancells_by_brand AS (
    SELECT
        products.brand,
        COUNT(*) AS count_items_orders,
        COUNT(CASE WHEN items.status = 'Returned' THEN items.id END) AS count_returned,
        COUNT(CASE WHEN items.status = 'Cancelled' THEN items.id END) AS count_cancelled,
        COUNT(CASE WHEN items.status IN ('Cancelled', 'Returned') THEN items.id END) AS count_returned_and_cancelled,
        ROUND(COUNT(CASE WHEN items.status = 'Returned' THEN items.id END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS prct_returned,
        ROUND(COUNT(CASE WHEN items.status = 'Cancelled' THEN items.id END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS prct_cancelled,
        ROUND(COUNT(CASE WHEN items.status IN ('Cancelled', 'Returned') THEN items.id END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS prct_returned_and_cancelled
    FROM products

    JOIN order_items AS items ON (items.product_id = products.id)

    GROUP BY products.brand
), median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY count_items_orders) AS median_value
    FROM returns_cancells_by_brand
), ranked_by_brand AS (
    SELECT
        *,
        CASE
            WHEN count_items_orders >= median.median_value THEN 'Big Volume'
            ELSE 'Small Volume'
        END AS volume_segment
    FROM returns_cancells_by_brand, median
)

SELECT
    brand, count_items_orders, count_returned, count_cancelled, count_returned_and_cancelled, prct_returned, prct_cancelled, prct_returned_and_cancelled, volume_segment,
    DENSE_RANK() OVER(PARTITION BY volume_segment ORDER BY prct_returned_and_cancelled DESC) AS brand_rank
FROM ranked_by_brand;


-- Returns and cancels by country

WITH returns_cancells_by_country AS (
    SELECT
        users.country,
        COUNT(*) AS count_items_orders,
        COUNT(CASE WHEN items.status = 'Returned' THEN items.id END) AS count_returned,
        COUNT(CASE WHEN items.status = 'Cancelled' THEN items.id END) AS count_cancelled,
        COUNT(CASE WHEN items.status IN ('Cancelled', 'Returned') THEN items.id END) AS count_returned_and_cancelled,
        ROUND(COUNT(CASE WHEN items.status = 'Returned' THEN items.id END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS prct_returned,
        ROUND(COUNT(CASE WHEN items.status = 'Cancelled' THEN items.id END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS prct_cancelled,
        ROUND(COUNT(CASE WHEN items.status IN ('Cancelled', 'Returned') THEN items.id END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS prct_returned_and_cancelled
    FROM users

    JOIN order_items AS items ON (items.user_id = users.id)

    GROUP BY users.country
), median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY count_items_orders) AS median_value
    FROM returns_cancells_by_country
), ranked_by_country AS (
    SELECT
        *,
        CASE
            WHEN count_items_orders >= median.median_value THEN 'Big Volume'
            ELSE 'Small Volume'
        END AS volume_segment
    FROM returns_cancells_by_country, median
)

SELECT
    country, count_items_orders, count_returned, count_cancelled, count_returned_and_cancelled, prct_returned, prct_cancelled, prct_returned_and_cancelled, volume_segment,
    DENSE_RANK() OVER(PARTITION BY volume_segment ORDER BY prct_returned_and_cancelled DESC) AS country_rank
FROM ranked_by_country;
