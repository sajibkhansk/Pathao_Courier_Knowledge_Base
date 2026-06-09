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
(
  SUM(
    CASE 
      WHEN transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42) 
      THEN (delivery_fee + additional_charge - (discount + promo_discount))
      ELSE 0 
    END
  )
  +
  SUM(
    CASE 
      WHEN transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42) 
      THEN cash_on_delivery_fee
      ELSE 0 
    END
  )
) / 100
* 100
/ (
  SELECT t.revenue 
  FROM `data-cloud-production.hermes_bz_comms.business_team_targets` t
  WHERE t.team_name = 'Total'   
        [[AND {{Current_Month}} = 'Yes'
          AND DATE(t.start_of_month) = DATE_TRUNC(CURRENT_DATE(), MONTH)]]
        [[AND {{start_date}} IS NOT NULL
          AND DATE(t.start_of_month) = DATE_TRUNC(CAST({{start_date}} AS DATE), MONTH)]]
)

FROM orders
WHERE 1=1
  [[AND {{Current_Month}}= 'Yes' AND DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 0 DAY), MONTH)  -- First day of current month
    AND DATE(sorted_at) < CURRENT_DATE() ]]
	  [[AND DATE(sorted_at) BETWEEN
        DATE_TRUNC(CAST({{start_date}} AS DATE), MONTH)
    AND LAST_DAY(CAST({{end_date}}   AS DATE), MONTH)]]
                                           -- Up to yesterday
  AND transfer_status_id IN (
        8, 9, 10, 11, 12, 13, 22, 23, 24, 26, 28, 
        25, 14, 30, 31, 32, 33, 36, 37, 38, 39, 40, 41, 42
  );
