SELECT 
     sum(cash_on_delivery_fee/100 +  delivery_fee/100 ) as Final_fee
FROM orders
WHERE 1=1
      [[AND {{Current_Month}}= 'Yes' AND DATE(created_at) >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 day') -- First day of previous (or current) month based on yesterday
  AND date(created_at) < CURRENT_DATE]]  
  [[AND DATE(created_at) between {{start_date}} and {{end_date}}]]
  --   AND created_at >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 day')  -- First day of previous (or current) month based on yesterday
  -- AND created_at < CURRENT_DATE    -- First day of the current month
  -- AND transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42)
  AND order_type_id in (16,18)