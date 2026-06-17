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
),
orders_current_month AS (
    SELECT 
    COUNT(consignment_id) total_orders_so_far,
	        SAFE_DIVIDE(COUNT(DISTINCT consignment_id) * 1.0, (EXTRACT(DAY FROM CURRENT_DATE()) - 1)) AS daily_average 
FROM orders
WHERE country_id = 1 
  AND merchant_id IN (SELECT merchant_id FROM ties_merchant WHERE ties_id = 67)
  AND DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH) -- First day of previous (or current) month based on yesterday
  AND date(sorted_at) < CURRENT_DATE     -- First day of the current month
  AND transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42)
),

forecasted_orders AS (

SELECT
    ROUND(
        daily_average * COALESCE((
            SELECT ANY_VALUE(days)
            FROM `data-cloud-production.hermes_bz_comms.business_working_days`
            WHERE DATE(start_of_month) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
        ), 0),
        1
    ) AS forecasted_orders
FROM orders_current_month

),

target_met_percentage AS (
    SELECT
        SAFE_DIVIDE(forecasted_orders.forecasted_orders * 100.0, (
 (
      SELECT targets
      FROM `data-cloud-production.hermes_bz_comms.business_team_targets` t
      WHERE t.team_name = 'MTM'
        [[AND {{Current_Month}} = 'Yes'
          AND DATE(t.start_of_month) = DATE_TRUNC(CURRENT_DATE(), MONTH)]]
        [[AND {{start_date}} IS NOT NULL
          AND DATE(t.start_of_month) = DATE_TRUNC(CAST({{start_date}} AS DATE), MONTH)]]
    )
		)  
		) AS target_met_percentage -- Use SAFE_DIVIDE here as well
    FROM forecasted_orders
)

SELECT 
    daily_average,
    forecasted_orders.forecasted_orders,
    target_met_percentage.target_met_percentage
FROM orders_current_month, forecasted_orders, target_met_percentage
