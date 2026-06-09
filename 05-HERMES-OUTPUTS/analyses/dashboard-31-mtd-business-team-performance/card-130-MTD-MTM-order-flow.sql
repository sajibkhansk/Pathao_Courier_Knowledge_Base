with orders as  (
    SELECT *
    FROM `courier_realtime_datastream.public_orders`
    WHERE updated_at IS NOT NULL
    UNION ALL
    SELECT *
    FROM `courier_realtime_datastream.public_archived_orders`
    WHERE updated_at IS NOT NULL
),

ties_merchant AS (
  SELECT *
  from courier_realtime_datastream.public_ties_merchant
),


KAM_merchants AS
  (SELECT *
   FROM `courier_realtime_datastream.public_merchants`
   WHERE updated_at IS NOT NULL
     AND id in (SELECT merchant_id FROM ties_merchant WHERE ties_id = 67) )

SELECT DATE(sorted_at) AS `Current Month`,
       COUNT(DISTINCT CASE WHEN orders.merchant_id = KAM_merchants.id THEN consignment_id END) AS `MTM orders`
FROM orders
LEFT JOIN KAM_merchants ON orders.merchant_id = KAM_merchants.id


WHERE DATE(sorted_at) >= DATE_TRUNC(CURRENT_DATE()-1, MONTH)
and DATE(sorted_at) < CURRENT_DATE()
GROUP BY 1
ORDER BY 1;

