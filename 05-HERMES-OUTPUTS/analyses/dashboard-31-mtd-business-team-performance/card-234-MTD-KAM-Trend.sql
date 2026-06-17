WITH orders AS (
    SELECT id, merchant_id, consignment_id, sorted_at, transfer_status_id
    FROM `courier_realtime_datastream.public_orders`
    WHERE updated_at IS NOT NULL

    UNION ALL

    SELECT id, merchant_id, consignment_id, sorted_at, transfer_status_id
    FROM `courier_realtime_datastream.public_archived_orders`
    WHERE updated_at IS NOT NULL
),

ties_merchant AS (
    SELECT merchant_id
    FROM `courier_realtime_datastream.public_ties_merchant`
    WHERE
	--updated_at IS NOT NULL
       ties_id = 68
)

SELECT 
    DATE(sorted_at) AS order_date, 
    COUNT(consignment_id) AS Order_Processed,
    COUNT(DISTINCT merchant_id) AS Active_Merchant
FROM orders
WHERE merchant_id IN (SELECT merchant_id FROM ties_merchant)
      [[AND {{Current_Month}}= 'Yes' AND DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH)  
  AND date(sorted_at) < CURRENT_DATE]]  
  [[AND DATE(sorted_at) between {{start_date}} and {{end_date}}]]
  -- AND DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH)
  -- AND DATE(sorted_at) < CURRENT_DATE()
  AND transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42)
GROUP BY order_date
ORDER BY order_date;
