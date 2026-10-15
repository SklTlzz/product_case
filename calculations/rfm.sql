-- RFM (Recency, Frequency, Monetary)

WITH global_max AS (
    SELECT
        MAX(created_at)::DATE AS max_dataset_date
    FROM order_items
), base_rfm AS (
    SELECT
        items.user_id,
        (global_max.max_dataset_date - MAX(items.created_at)::DATE) AS last_buy,
        COUNT(DISTINCT items.order_id) AS all_buys,
        SUM(items.sale_price) AS revenue
    FROM order_items AS items, global_max

    WHERE items.status NOT IN ('Returned', 'Cancelled')

    GROUP BY items.user_id, global_max.max_dataset_date
), rfm_ranking AS (
    SELECT
        user_id, last_buy, all_buys, revenue,
        CASE
            WHEN last_buy < 45 THEN 5
            WHEN last_buy < 90 THEN 4
            WHEN last_buy < 180 THEN 3
            WHEN last_buy < 365 THEN 2
            ELSE 1
        END AS recency_rank,
        CASE
            WHEN all_buys > 3 THEN 5
            WHEN all_buys > 2 THEN 4
            WHEN all_buys > 1 THEN 3
            WHEN all_buys > 0 THEN 1
        END AS frequency_rank,
        CASE
            WHEN revenue > 189 THEN 5
            WHEN revenue > 105 THEN 4
            WHEN revenue > 60 THEN 3
            WHEN revenue > 32 THEN 2
            ELSE 1
        END AS monetary_rank
    FROM base_rfm
), rfm_human_readable_ranking AS (
    SELECT
        *,
        CASE 
            WHEN recency_rank >= 4 AND frequency_rank >= 4 AND monetary_rank >= 4 THEN 'VIP'
            WHEN recency_rank >= 3 AND frequency_rank >= 3 THEN 'Лояльные'
            WHEN recency_rank >= 4 AND frequency_rank = 1 THEN 'Новички'
            WHEN recency_rank <= 2 AND frequency_rank >= 3 THEN 'В зоне риска'
            ELSE 'Потерянные'
        END AS segment_name
    FROM rfm_ranking
)

SELECT
    *
FROM rfm_human_readable_ranking

ORDER BY recency_rank DESC, frequency_rank DESC, monetary_rank DESC
