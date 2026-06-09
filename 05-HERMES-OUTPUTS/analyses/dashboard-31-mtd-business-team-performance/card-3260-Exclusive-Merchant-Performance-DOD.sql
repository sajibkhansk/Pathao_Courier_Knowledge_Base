WITH filtered AS (
   SELECT *
FROM `data-cloud-production.courier_realtime_datastream.public_orders`
WHERE DATE(updated_at) >= '2026-04-01'
    AND DATE(sorted_at) >= DATE_TRUNC(CURRENT_DATE(), MONTH) 
	AND DATE(sorted_at) < CURRENT_DATE()  -- excludes today, includes everything up to yesterday
    AND country_id = 1
    AND merchant_id IN (799,186030,88912,346127,98646,370015,72156,141351,125025,137518,143146,89631,11305,72141,27873,270061,32535,90201,15925,812,250092,6525,73407,4114,73401,311415,321020,228801,205126,54878,197990,310845,137691,29743,42323,170211,169832,293774,161753,87341,6362,211955,8815,5827,256784,6346,132252,198451,230008,359978,327809)
),

-- Aggregate orders per day (all merchants combined)
daily_totals AS (
    SELECT
        DATE(sorted_at) AS order_date,
        COUNT(*) AS total_orders
    FROM filtered
    WHERE sorted_at IS NOT NULL
    GROUP BY DATE(sorted_at)
),

-- Add DOD growth vs previous day
daily_with_dod AS (
    SELECT
        order_date,
        total_orders,
        -- LAG(total_orders) OVER (ORDER BY order_date) AS prev_day_orders,
        -- total_orders - LAG(total_orders) OVER (ORDER BY order_date) AS dod_growth,
        CASE
            WHEN LAG(total_orders) OVER (ORDER BY order_date) IS NULL THEN 'N/A'
            WHEN LAG(total_orders) OVER (ORDER BY order_date) = 0 THEN '+∞'
            ELSE CONCAT(
                CASE WHEN total_orders >= LAG(total_orders) OVER (ORDER BY order_date) THEN '+' ELSE '' END,
                FORMAT('%.2f', SAFE_DIVIDE(
                    (total_orders - LAG(total_orders) OVER (ORDER BY order_date)) * 100,
                    LAG(total_orders) OVER (ORDER BY order_date)
                )),
                '%'
            )
        END AS dod_pct,
        CASE
            WHEN total_orders > LAG(total_orders) OVER (ORDER BY order_date) THEN '🟢'
            WHEN total_orders < LAG(total_orders) OVER (ORDER BY order_date) THEN '🔴'
            ELSE '⚪'
        END AS status
    FROM daily_totals
)

SELECT
    order_date,
    total_orders,
    -- prev_day_orders,
    -- dod_growth,
    dod_pct,
    status
FROM daily_with_dod
ORDER BY order_date DESC;


WITH filtered AS (
    SELECT *
    FROM `data-cloud-production.courier_realtime_datastream.public_orders`
    WHERE DATE(sorted_at) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
        AND DATE(sorted_at) < CURRENT_DATE()
		and DATE(updated_at) >= '2026-04-01'
        AND country_id = 1
        AND merchant_id IN (
            799,186030,88912,346127,98646,370015,72156,141351,125025,137518,
            143146,89631,11305,72141,27873,270061,32535,90201,15925,812,
            250092,6525,73407,4114,73401,311415,321020,228801,205126,54878,
            197990,310845,137691,29743,42323,170211,169832,293774,161753,
            87341,6362,211955,8815,5827,256784,6346,132252,198451,230008,
            359978,327809
        )
),

daily_totals AS (
    SELECT
        DATE(sorted_at)  AS order_date,
        COUNT(*)         AS total_orders
    FROM filtered
    WHERE sorted_at IS NOT NULL
    GROUP BY DATE(sorted_at)
)

SELECT
    order_date,
    total_orders,
    LAG(total_orders) OVER (ORDER BY order_date)                        AS prev_day_orders,
    total_orders - LAG(total_orders) OVER (ORDER BY order_date)         AS dod_growth,
    ROUND(
        SAFE_DIVIDE(
            (total_orders - LAG(total_orders) OVER (ORDER BY order_date)) * 100.0,
            LAG(total_orders) OVER (ORDER BY order_date)
        ), 2
    )                                                                   AS dod_pct_change
FROM daily_totals
ORDER BY order_date ASC