WITH orders AS (
    SELECT *
    FROM `courier_realtime_datastream.public_orders`
    WHERE updated_at IS NOT NULL 
      AND country_id = 1 
      AND merchant_id <> 1 
    UNION ALL
    SELECT *
    FROM `courier_realtime_datastream.public_archived_orders`
    WHERE updated_at IS NOT NULL 
      AND country_id = 1 
      AND merchant_id <> 1 
),
	 
First_trip_merchants AS (
  SELECT 
    merchant_id as id,
    MIN(sorted_at) AS first_order_date
  FROM orders
  WHERE updated_at IS NOT NULL 
    AND country_id = 1
    AND merchant_id <> 1
  GROUP BY merchant_id
  HAVING DATE(MIN(sorted_at)) >= 
    DATE_ADD(DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH), INTERVAL 15 DAY)
)

SELECT DATE(sorted_at) AS `Current Month`,
       COUNT(DISTINCT CASE WHEN DATE(First_trip_merchants.first_order_date) >= DATE_TRUNC(CURRENT_DATE(), MONTH) THEN consignment_id END) AS `First trip merchant orders`,
	   COUNT(DISTINCT CASE WHEN DATE(First_trip_merchants.first_order_date) >= DATE_TRUNC(CURRENT_DATE(), MONTH) THEN orders.merchant_id END) AS `First trip merchant`,
	   COUNT(DISTINCT CASE WHEN DATE(First_trip_merchants.first_order_date) >=
      DATE_ADD(DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH), INTERVAL 15 DAY) THEN consignment_id END) AS `First trip merchant orders_too`,
	  COUNT(distinct case when orders.merchant_id in (select id from First_trip_merchants) then  merchant_id END) AS `First trip merchant orders_too_2`,
	   count(distinct consignment_id) as orders,
	    (COUNT(DISTINCT CASE WHEN DATE(First_trip_merchants.first_order_date) >=
      DATE_ADD(DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH), INTERVAL 15 DAY) THEN consignment_id END)/count(distinct consignment_id))*100 as First_trip
FROM orders
LEFT JOIN First_trip_merchants ON orders.merchant_id = First_trip_merchants.id


WHERE DATE(sorted_at) >= DATE_TRUNC(CURRENT_DATE()-1, MONTH)
and DATE(sorted_at) < CURRENT_DATE()
-- and DATE(first_order_date) >=
--       DATE_ADD(DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH), INTERVAL 15 DAY)
GROUP BY 1
ORDER BY 1;

