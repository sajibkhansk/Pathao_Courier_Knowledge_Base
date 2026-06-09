WITH orders AS (
    SELECT *
    FROM `courier_realtime_datastream.public_orders`
    WHERE updated_at IS NOT NULL AND country_id = 1 and merchant_id <> 1

    UNION ALL

    SELECT *
    FROM `courier_realtime_datastream.public_archived_orders`
    WHERE updated_at IS NOT NULL AND country_id = 1 and merchant_id <> 1
),
merchants as (
SELECT *
FROM courier_realtime_datastream.public_merchants
WHERE updated_at IS NOT NULL
  AND created_at < TIMESTAMP(CURRENT_DATE) 
),

hubs as (
SELECT *
FROM courier_realtime_datastream.public_hubs
WHERE updated_at IS NOT NULL
  AND created_at < TIMESTAMP(CURRENT_DATE) 
)




SELECT
  DATE(sorted_at) AS `Current Month`,
  COUNT(DISTINCT consignment_id) AS `Orders Processed`,
  COUNT(DISTINCT merchant_id) AS `Active Merchant`
FROM
  orders
WHERE 1=1
         [[AND {{Current_Month}}= 'Yes' AND DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 0 DAY), MONTH)  -- First day of current month
    AND DATE(sorted_at) < CURRENT_DATE() ]]
	[[AND DATE(sorted_at) between {{start_date}} and {{end_date}}]]

  AND merchant_id <> 1 and country_id = 1
  AND transfer_status_id IN (
    8, 9, 10, 11, 12, 13, 14, 22, 23, 24, 25, 26, 28, 30, 31, 32, 33, 37, 38, 39, 40, 41, 42,43,44
  )
GROUP BY
  1
ORDER BY
  1;
