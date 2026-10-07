-- Traffic

WITH returns_cancells_by_traffic AS ( 
    SELECT
        users.traffic_source,
        COUNT(*) AS items_count,
        COUNT(CASE WHEN items.status = 'Returned' THEN items.id END) AS count_returned,
        COUNT(CASE WHEN items.status = 'Cancelled' THEN items.id END) AS count_cancelled,
        COUNT(CASE WHEN items.status IN ('Cancelled', 'Returned') THEN items.id END) AS count_returned_and_cancelled,
        ROUND(COUNT(CASE WHEN items.status = 'Returned' THEN items.id END) * 1.0 / COUNT(*) * 100, 2) AS prct_returned,
        ROUND(COUNT(CASE WHEN items.status = 'Cancelled' THEN items.id END) * 1.0 / COUNT(*) * 100, 2) AS prct_cancelled,
        ROUND(COUNT(CASE WHEN items.status IN ('Cancelled', 'Returned') THEN items.id END) * 1.0 / COUNT(*) * 100, 2) AS prct_returned_and_cancelled
    FROM users

    JOIN order_items AS items ON (items.user_id = users.id)

    GROUP BY users.traffic_source
), ranked_by_traffic AS (
    SELECT
        *,
        DENSE_RANK() OVER(ORDER BY prct_returned_and_cancelled DESC) AS traffic_rank
    FROM returns_cancells_by_traffic
)

SELECT
    *
FROM ranked_by_traffic;


-- Funnel

CREATE TEMP TABLE count_by_event_type AS
    SELECT
        event_type,
        COUNT(DISTINCT session_id) AS count_events,
        CASE
            WHEN event_type = 'home' THEN 1
            WHEN event_type = 'department' THEN 2
            WHEN event_type = 'product' THEN 3
            WHEN event_type = 'cart' THEN 4
            WHEN event_type = 'purchase' THEN 5
            ELSE 6
        END AS event_funnel_num
    FROM events

    GROUP BY event_type;

WITH count_by_event AS (
    SELECT
        event_type, 
        count_events,
        LEAD(count_events) OVER(ORDER BY event_funnel_num) AS next_count_events
    FROM count_by_event_type

    WHERE event_type NOT IN ('department', 'home', 'cancel')
), conversion_by_event AS (
    SELECT
        *,
        ROUND(next_count_events * 100.0 / count_events, 2) AS event_conversion
    FROM count_by_event
)

SELECT
    *
FROM conversion_by_event;


-- Section popularity

SELECT
    *
FROM count_by_event_type;

/*
SELECT
    event_type, COUNT(DISTINCT session_id)
FROM events

WHERE session_id IN (
    SELECT
        DISTINCT session_id
    FROM events
    
    WHERE event_type = 'cancel'
)

GROUP BY event_type;
*/ -- это показывает, что датасет - синтетический, и в категориях c cancel есть только 3 event_type, причем c равным кол-вом сессий, поэтому у нас cancel исключен из воронки
