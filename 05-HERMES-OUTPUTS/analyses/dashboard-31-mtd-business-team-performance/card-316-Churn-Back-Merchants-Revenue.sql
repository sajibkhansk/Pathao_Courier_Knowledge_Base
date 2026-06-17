WITH
  dates AS (
    SELECT
      DATE_TRUNC(CURRENT_DATE(), MONTH) AS month_start,
      CURRENT_DATE() AS today,
      DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 45 DAY) AS cutoff_date
  ),

  orders AS (
    SELECT
      merchant_id,
      DATE(sorted_at) AS order_date,
      consignment_id,
	   final_fee/100 as final_fee,
	   transfer_status_id
    FROM
      courier_realtime_datastream.public_orders
    WHERE
      updated_at IS NOT NULL
      AND country_id = 1
      AND merchant_id <> 1
	  

    UNION ALL

    SELECT
      merchant_id,
      DATE(sorted_at) AS order_date,
      consignment_id,
	  final_fee/100 as final_fee,
	  transfer_status_id
    FROM
      courier_realtime_datastream.public_archived_orders
    WHERE
      updated_at IS NOT NULL
      AND country_id = 1
      AND merchant_id <> 1
  ),

  merchant_flags AS (
    SELECT
      o.merchant_id,
      MAX(CASE WHEN o.order_date < d.cutoff_date THEN 1 ELSE 0 END) AS has_before_cutoff,
      MAX(CASE WHEN o.order_date >= d.cutoff_date
                    AND o.order_date < d.month_start THEN 1 ELSE 0 END) AS has_in_gap_period,
      MAX(CASE WHEN o.order_date >= d.month_start
                    AND o.order_date < d.today THEN 1 ELSE 0 END) AS has_in_current_month
    FROM
      orders o
    CROSS JOIN
      dates d
    GROUP BY
      o.merchant_id
  ),

  churnback_merchants AS (
    SELECT
      merchant_id
    FROM
      merchant_flags
    WHERE
      has_before_cutoff = 1          -- had orders before cutoff
      AND has_in_gap_period = 0      -- no orders between cutoff and month start
      AND has_in_current_month = 1   -- has orders in current month
  )

SELECT
  sum(final_fee)
FROM
  orders o
CROSS JOIN
  dates d
WHERE
  o.order_date >= d.month_start
  AND o.order_date < d.today
  AND o.merchant_id IN (SELECT merchant_id FROM churnback_merchants)

