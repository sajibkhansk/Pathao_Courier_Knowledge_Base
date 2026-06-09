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
(
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
)*100
/
NULLIF(
  (
    SELECT revenue
    FROM `data-cloud-production.hermes_bz_comms.business_team_targets`
    WHERE team_name = 'KAM'
      AND DATE(start_of_month) = DATE_TRUNC(CURRENT_DATE(), MONTH)
  ),
  0
) AS Target_Achieved
from orders
WHERE merchant_id IN (SELECT merchant_id FROM ties_merchant WHERE ties_id = 68)
 [[AND {{Current_Month}}= 'Yes' AND DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH) -- First day of previous (or current) month based on yesterday
  AND date(sorted_at) < CURRENT_DATE]]
  [[AND DATE(sorted_at) between {{start_date}} and {{end_date}}]]



  -- AND DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH) -- First day of previous (or current) month based on yesterday
  -- AND date(sorted_at) < CURRENT_DATE
  -- [[AND DATE(sorted_at) between {{start_date}} and {{end_date}}]]-- First day of the current month
  AND transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42);
