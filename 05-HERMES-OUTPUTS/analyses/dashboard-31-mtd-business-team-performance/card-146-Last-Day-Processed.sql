SELECT 
  DATE(sorted_at) AS order_day,
  COUNT(consignment_id) AS order_count
FROM `courier_realtime_datastream.public_orders`
WHERE 
  DATE(updated_at) >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY)
  AND merchant_id != 1
  AND country_id = 1
  AND transfer_status_id IN (
    8, 9, 10, 11, 12, 13, 14, 22, 23, 24, 25, 26, 
    28, 30, 31, 32, 33, 37, 38, 39, 40, 41, 42,43,44
  )
  AND DATE(sorted_at) IN (
    DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),
    DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)
  )
GROUP BY order_day
ORDER BY order_day;