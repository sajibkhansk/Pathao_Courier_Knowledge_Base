WITH orders AS (
  SELECT 
    consignment_id,
    merchant_id,
    DATE(sorted_at) AS order_date
  FROM `courier_realtime_datastream.public_orders`
  WHERE updated_at IS NOT NULL
    AND transfer_status_id IN (8,9,10,11,12,13,14,22,23,24,25,26,28,30,31,32,33,37,38,39,40,41,42)
    AND country_id = 1
    AND merchant_id <> 1
    AND DATE(sorted_at) BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL {{Duration}} DAY)
                            AND DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
), 

merchants AS (
  SELECT id, name
  FROM `courier_realtime_datastream.public_merchants`
  WHERE updated_at IS NOT NULL
    AND created_at < TIMESTAMP(CURRENT_DATE)
	 [[and  {{merchant_name}}]]
),

daily_volume AS (
  SELECT
    order_date,
    merchant_id,
    COUNT(DISTINCT consignment_id) AS daily_orders
  FROM orders
  GROUP BY order_date, merchant_id
),

top_10_merchants AS (
  SELECT merchant_id
  FROM daily_volume
  GROUP BY merchant_id
  ORDER BY SUM(daily_orders) DESC
  LIMIT 20
),

running_avg AS (
  SELECT
    dv.order_date,
    dv.merchant_id,
    m.name AS merchant_name,
    dv.daily_orders,
    ROUND(AVG(dv.daily_orders) OVER (
      PARTITION BY dv.merchant_id
      ORDER BY dv.order_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS running_avg_7d
  FROM daily_volume dv
  JOIN merchants m ON dv.merchant_id = m.id
  JOIN top_10_merchants t ON dv.merchant_id = t.merchant_id
  where 1=1
 
)

SELECT *
FROM running_avg
ORDER BY daily_orders desc;