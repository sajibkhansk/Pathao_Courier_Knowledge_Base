with orders as  (
    SELECT *
    FROM `courier_realtime_datastream.public_orders`
    WHERE updated_at IS NOT NULL
    UNION ALL
    SELECT *
    FROM `courier_realtime_datastream.public_archived_orders`
    WHERE updated_at IS NOT NULL
),
ties_merchant as (
	select * 
	from courier_realtime_datastream.public_ties_merchant
	--where updated_at is not null
)
SELECT 
    COUNT(consignment_id)
FROM orders
WHERE country_id = 1 
  AND merchant_id IN (SELECT merchant_id FROM ties_merchant WHERE ties_id = 68)
   [[AND {{Current_Month}}= 'Yes' AND DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH)  -- First day of previous (or current) month based on yesterday
  AND date(sorted_at) < CURRENT_DATE]]  
  [[AND DATE(sorted_at) between {{start_date}} and {{end_date}}]]
  
  -- AND DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH) -- First day of previous (or current) month based on yesterday
  -- AND date(sorted_at) < CURRENT_DATE     -- First day of the current month
  AND transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42,43,44);
