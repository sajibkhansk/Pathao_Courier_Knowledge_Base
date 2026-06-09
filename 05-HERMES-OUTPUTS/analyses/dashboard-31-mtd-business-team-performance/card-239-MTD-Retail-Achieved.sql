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
    ROUND(COUNT(consignment_id) * 100.0 / 
		(
      SELECT targets
      FROM `data-cloud-production.hermes_bz_comms.business_team_targets`
      WHERE team_name = 'Retail'
        AND DATE(start_of_month) = DATE_TRUNC(CURRENT_DATE(), MONTH)
    )) AS Target_Achieved
FROM orders
WHERE order_type_id in (16,18)
 [[AND {{Current_Month}}= 'Yes' AND DATE(created_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH)  -- First day of previous (or current) month based on yesterday
  AND date(created_at) < CURRENT_DATE]]  
  [[AND DATE(created_at) between {{start_date}} and {{end_date}}]]

  --     AND DATE(created_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH)  -- First day of previous (or current) month based on yesterday
  -- AND date(created_at) < CURRENT_DATE    -- First day of the current month
  AND transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42);
