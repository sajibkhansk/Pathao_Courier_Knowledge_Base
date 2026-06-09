WITH orders AS
  (SELECT *,
          TIMESTAMP(DATETIME(sorted_at, "UTC"), "Atlantic/Cape_Verde") AS updated_sorted_at
   FROM `hermes.orders`
   WHERE transfer_status_updated_at >= '2024-01-01'
     AND DATE(sorted_at) >= '2024-06-01' --      AND item_type_id <> 1

     AND country_id = 1
     AND merchant_id <> 1 QUALIFY ROW_NUMBER() OVER (PARTITION BY id
                                                     ORDER BY updated_at DESC) = 1 ),
     Booking_points AS (
    SELECT *
    FROM `hermes.merchants`
    WHERE updated_at IS NOT NULL
    and id in (46696,108077,108078,134572,149473,230000,240900,256671)
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) = 1
)
SELECT DATE(updated_sorted_at) AS `Current Month`,
       COUNT(DISTINCT CASE WHEN orders.merchant_id = Booking_points.id THEN consignment_id END) AS `Booking points orders`
FROM orders
LEFT JOIN Booking_points ON orders.merchant_id = Booking_points.id


WHERE DATE(updated_sorted_at) >= DATE_TRUNC(CURRENT_DATE()-1, MONTH)
and DATE(updated_sorted_at) < CURRENT_DATE()
GROUP BY 1
ORDER BY 1;

