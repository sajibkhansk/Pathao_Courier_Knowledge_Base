with orders as  (
    SELECT *
    FROM `courier_realtime_datastream.public_orders`
    WHERE updated_at IS NOT NULL
    UNION ALL
    SELECT *
    FROM `courier_realtime_datastream.public_archived_orders`
    WHERE updated_at IS NOT NULL
),
hubs as (
SELECT *
FROM courier_realtime_datastream.public_hubs
WHERE updated_at IS NOT NULL
  AND created_at < TIMESTAMP(CURRENT_DATE) 
),
ties_merchant as (
SELECT *
FROM courier_realtime_datastream.public_ties_merchant
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
WHERE  merchant_id IN (SELECT merchant_id FROM ties_merchant WHERE ties_id = 68)
 [[AND {{Current_Month}}= 'Yes' AND DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH)  -- First day of previous (or current) month based on yesterday
  AND date(sorted_at) < CURRENT_DATE]]  
  [[AND DATE(sorted_at) between {{start_date}} and {{end_date}}]]
  AND transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42)
GROUP BY 1
ORDER BY 1;
