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
    CASE 
        WHEN h.hub_operation_type = 1 THEN 'ISD'
        WHEN h.hub_operation_type = 2 THEN 'OSD'
        WHEN h.hub_operation_type = 3 THEN 'RSD'
    END as Hub_Type,
    COUNT(consignment_id) AS consignment_count
FROM orders o
left join hubs h
on h.id = o.delivery_hub_id
WHERE  1=1
     [[AND {{Current_Month}}= 'Yes' AND DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 0 DAY), MONTH)  -- First day of current month
    AND DATE(sorted_at) < CURRENT_DATE() ]]
	[[AND DATE(sorted_at) between {{start_date}} and {{end_date}}]]

  AND transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42)
GROUP BY 1
ORDER BY 1;
