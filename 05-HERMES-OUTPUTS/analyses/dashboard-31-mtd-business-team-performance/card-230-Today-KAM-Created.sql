WITH orders AS (
    SELECT *
    FROM `courier_realtime_datastream.public_orders`
    WHERE updated_at IS NOT NULL

    UNION ALL

    SELECT *
    FROM `courier_realtime_datastream.public_archived_orders`
    WHERE updated_at IS NOT NULL
),

ties_merchant AS (
    SELECT *
    FROM `courier_realtime_datastream.public_ties_merchant`
)
SELECT COUNT(consignment_id)
FROM orders
WHERE merchant_id IN (
        SELECT merchant_id 
        FROM ties_merchant 
        WHERE ties_id = 68
    )
  AND DATE(TIMESTAMP(created_at), "Asia/Dhaka") = CURRENT_DATE("Asia/Dhaka")
