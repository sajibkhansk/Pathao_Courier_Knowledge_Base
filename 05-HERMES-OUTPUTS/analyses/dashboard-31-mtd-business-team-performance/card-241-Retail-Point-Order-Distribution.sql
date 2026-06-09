SELECT 
    REPLACE(m.name, ' point', '') AS "Booking Point",
    COUNT(consignment_id) AS "Order_Processed",
    SUM(o.cash_on_delivery_fee / 100 + o.delivery_fee / 100) As "Revenue"
FROM orders o 
LEFT JOIN merchants_vw_non_pii m ON o.merchant_id = m.id
WHERE 1=1
 [[AND {{Current_Month}}= 'Yes' AND DATE(o.created_at) >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 day')  -- First day of previous (or current) month based on yesterday
  AND date(o.created_at) < CURRENT_DATE]]  
  [[AND DATE(o.created_at) between {{start_date}} and {{end_date}}]]

-- AND o.created_at >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 day')  -- First day of previous (or current) month based on yesterday
--   AND o.created_at < CURRENT_DATE   -- First day of the current month
  AND transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42)
  AND order_type_id IN (18,16)
GROUP BY 1;
