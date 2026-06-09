WITH orders AS (
  SELECT *
  FROM `courier_realtime_datastream.public_orders`
  WHERE updated_at IS NOT NULL
    AND transfer_status_id IN (8,9,10,11,12,13,14,22,23,24,25,26,28,30,31,32,33,37,38,39,40,41,42,43,44)
    AND country_id = 1
    AND merchant_id <> 1
    AND DATE(sorted_at) BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL {{Interval_Days}} DAY)
                            AND DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
), 

merchants AS (
  SELECT id, name
  FROM `courier_realtime_datastream.public_merchants`
  WHERE updated_at IS NOT NULL
    AND created_at < TIMESTAMP(CURRENT_DATE)
),

orders_summary AS (
  SELECT
    merchant_id,discount_type,
    COUNT(id) AS total_orders,
    COUNT(DISTINCT DATE(sorted_at)) AS active_days,
    COUNT(CASE WHEN DATE(sorted_at) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) THEN id END) AS last_day_orders
  FROM orders
  GROUP BY merchant_id,2
)

  SELECT 
s.merchant_id,
  m.name AS merchant_name,discount_type,
  s.total_orders,
  s.active_days,
  s.last_day_orders,
  ROUND(SAFE_DIVIDE(s.total_orders, s.active_days), 0) AS daily_average,
  ROW_NUMBER() OVER(ORDER BY s.total_orders DESC) AS RANK,

  -- 📊 Emoji growth indicator
  CASE
    WHEN s.last_day_orders > ROUND(SAFE_DIVIDE(s.total_orders, s.active_days), 0)
      THEN CONCAT('🟢 +', CAST(s.last_day_orders - ROUND(SAFE_DIVIDE(s.total_orders, s.active_days), 0) AS STRING))
    WHEN s.last_day_orders < ROUND(SAFE_DIVIDE(s.total_orders, s.active_days), 0)
      THEN CONCAT('🔴 -', CAST(ROUND(SAFE_DIVIDE(s.total_orders, s.active_days), 0) - s.last_day_orders AS STRING))
    ELSE '🔵 0'
  END AS `DailyAvg vs LastDay`

FROM
  orders_summary s
JOIN
  merchants m ON s.merchant_id = m.id
ORDER BY
  s.total_orders DESC
LIMIT 200;