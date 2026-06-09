WITH orders AS (
  SELECT id, sorted_at, created_at, consignment_id, merchant_id,
         delivery_fee, cash_on_delivery_fee, promo_discount, discount,
         transfer_status_id, final_fee
  FROM `courier_realtime_datastream.public_orders`
  WHERE updated_at IS NOT NULL
    AND country_id = 1
    AND merchant_id <> 1

  UNION ALL

  SELECT id, sorted_at, created_at, consignment_id, merchant_id,
         delivery_fee, cash_on_delivery_fee, promo_discount, discount,
         transfer_status_id, final_fee
  FROM `courier_realtime_datastream.public_archived_orders`
  WHERE updated_at IS NOT NULL
    AND country_id = 1
    AND merchant_id <> 1
)

SELECT
  SAFE_DIVIDE(
    COUNT(DISTINCT consignment_id) * 100.0,
    (
      SELECT targets
      FROM `data-cloud-production.hermes_bz_comms.business_team_targets` t
      WHERE t.team_name = 'Total'
        [[AND {{Current_Month}} = 'Yes'
          AND DATE(t.start_of_month) = DATE_TRUNC(CURRENT_DATE(), MONTH)]]
        [[AND {{start_date}} IS NOT NULL
          AND DATE(t.start_of_month) = DATE_TRUNC(CAST({{start_date}} AS DATE), MONTH)]]
    )
  ) AS Target_Achieved
FROM orders
WHERE 1 = 1
  [[AND {{Current_Month}} = 'Yes'
    AND DATE(sorted_at) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
    AND DATE(sorted_at) <  CURRENT_DATE() ]]
  [[AND DATE(sorted_at) BETWEEN
        DATE_TRUNC(CAST({{start_date}} AS DATE), MONTH)
    AND LAST_DAY(CAST({{end_date}}   AS DATE), MONTH)]]
  AND transfer_status_id IN (
    8, 9, 10, 11, 12, 13, 14, 22, 23, 24, 25, 26, 28, 30, 31, 32, 33, 37, 38, 39, 40, 41, 42, 43, 44
  );
