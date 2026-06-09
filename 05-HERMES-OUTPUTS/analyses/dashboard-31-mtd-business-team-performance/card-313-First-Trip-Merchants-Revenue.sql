WITH orders AS
  (SELECT *,
          TIMESTAMP(DATETIME(sorted_at, "UTC"), "Atlantic/Cape_Verde") AS updated_sorted_at
   FROM `hermes.orders`
   WHERE transfer_status_updated_at >= '2019-01-01'
     AND DATE(sorted_at) >= '2019-06-01' --      AND item_type_id <> 1

     AND country_id = 1
     AND merchant_id <> 1 QUALIFY ROW_NUMBER() OVER (PARTITION BY id
                                                     ORDER BY updated_at DESC) = 1 ),
                                                     
 First_trip_merchants AS
  (SELECT merchant_id,
          min(TIMESTAMP(DATETIME(sorted_at, "UTC"), "Atlantic/Cape_Verde")) AS first_order_date
   FROM `hermes.orders`
   WHERE transfer_status_updated_at >= '2019-01-01'
     AND country_id = 1
     AND merchant_id <> 1
   GROUP BY merchant_id)
   
SELECT ROUND(sum(first_trip_Revenue),0) from (SELECT DATE(updated_sorted_at) AS `Current Month`,
       SUM(DISTINCT CASE WHEN DATE(First_trip_merchants.first_order_date) = DATE(updated_sorted_at) THEN final_fee/100 END) AS first_trip_Revenue
FROM orders
LEFT JOIN First_trip_merchants ON orders.merchant_id = First_trip_merchants.merchant_id


WHERE DATE(updated_sorted_at) >= DATE_TRUNC(CURRENT_DATE()-1, MONTH)
and DATE(updated_sorted_at) < CURRENT_DATE()
GROUP BY 1
ORDER BY 1) x

