WITH orders AS (
    SELECT *
    FROM `courier_realtime_datastream.public_orders`
    WHERE updated_at IS NOT NULL
      AND country_id = 1
      AND DATE(sorted_at) >=  DATE_TRUNC(current_date, month)
      AND merchant_id <> 1
	  AND transfer_status_id IN (
    8, 9, 10, 11, 12, 13, 14, 22, 23, 24, 25, 26, 28, 30, 31, 32, 33, 37, 38, 39, 40, 41, 42,43,44
  )
),
merchants AS (
    SELECT *
    FROM `courier_realtime_datastream.public_merchants`
    WHERE updated_at IS NOT NULL
      AND country_id = 1
),
ties_merchant AS (
    SELECT *
    FROM courier_realtime_datastream.public_ties_merchant
),
all_orders AS (
    SELECT * FROM `courier_realtime_datastream.public_orders`          WHERE updated_at IS NOT NULL AND country_id = 1
    UNION ALL
    SELECT * FROM `courier_realtime_datastream.public_archived_orders` WHERE updated_at IS NOT NULL AND country_id = 1
),
new_merchant AS (
    SELECT
        COALESCE(p.merchant_id, m.id) AS merchant_id,
        DATE(p.created_at)            AS lead_created_at,
        p.onboard_type
    FROM courier_appsmith.new_onboards p
    LEFT JOIN merchants m
        ON  (p.merchant_id IS NOT NULL AND m.id    = p.merchant_id)
        OR  (p.merchant_id IS NULL     AND m.phone = p.phone)
    WHERE p.updated_at IS NOT NULL
      AND (
            p.onboard_type = 'Post Corporate'
            OR p.created_at > '2026-03-15'
          )
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY COALESCE(p.merchant_id, m.id)
        ORDER BY p.created_at DESC
    ) = 1
),
first_orders AS (
    SELECT
        nm.merchant_id,
        MIN(DATE(o.created_at)) AS first_order_date
    FROM new_merchant nm
    LEFT JOIN all_orders o
        ON  nm.merchant_id = o.merchant_id
        AND DATE(o.created_at) >= nm.lead_created_at
    GROUP BY nm.merchant_id
),
crm_category AS (
    SELECT
        nm.merchant_id,
        nm.onboard_type,
        nm.lead_created_at,
        fo.first_order_date
    FROM new_merchant nm
    LEFT JOIN first_orders fo ON fo.merchant_id = nm.merchant_id
    WHERE nm.onboard_type = 'Post Corporate'
       OR fo.first_order_date > DATE_ADD(DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH), INTERVAL 15 DAY)
),
base AS (
    SELECT
        DATE(o.sorted_at)  AS day,           -- ✅ added sorted_at here
        o.merchant_id,
        m.name AS merchant_name,
        COALESCE(
            CASE WHEN o.merchant_id = 80297                                                                          THEN m.name           END, -- 1st: Pathao C2C
            cc.onboard_type,                                                                                                                    -- 2nd: CRM
            CASE WHEN o.merchant_id IN (SELECT merchant_id FROM ties_merchant WHERE ties_id = 68)                    THEN 'KAM'
                 WHEN o.merchant_id IN (SELECT merchant_id FROM ties_merchant WHERE ties_id = 67)                    THEN 'MTM'            END, -- 3rd: KAM / MTM
            CASE WHEN o.order_type_id IN (18, 16)                                                                    THEN 'Booking Points' END, -- 4th: Booking Points
            CASE WHEN m.merchant_type = 1                                                                            THEN 'Kiosk'          END, -- 5th: Kiosk
            'Unguided'                                                                                                                          -- 6th: fallback
        ) AS category,
        cc.lead_created_at,
        cc.first_order_date,
        COUNT(o.consignment_id) AS order_count
    FROM orders o
    LEFT JOIN merchants m     ON o.merchant_id = m.id
    LEFT JOIN crm_category cc ON o.merchant_id = cc.merchant_id
    GROUP BY 1, 2, 3, 4, 5, 6
)

SELECT
    day,
    category,
    COUNT(DISTINCT merchant_id) AS merchant_count,
    SUM(order_count)            AS total_orders
FROM base
WHERE 1 = 1
GROUP BY 1, 2
ORDER BY 1, 2