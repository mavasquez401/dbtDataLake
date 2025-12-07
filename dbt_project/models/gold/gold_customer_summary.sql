-- Gold Layer: Customer Summary
-- Business-ready customer analytics with aggregated metrics

{{
    config(
        materialized='table',
        tags=['gold', 'crm', 'summary']
    )
}}

WITH customer_base AS (
    SELECT * FROM {{ ref('silver_customers') }}
),

-- Aggregate customer orders
customer_orders AS (
    SELECT
        c.customer_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.order_total) AS total_order_value,
        AVG(o.order_total) AS avg_order_value,
        MAX(o.order_date) AS last_order_date,
        MIN(o.order_date) AS first_order_date
    FROM customer_base c
    LEFT JOIN {{ source('stage', 'link_customer_order') }} lco
        ON c.customer_hk = lco.customer_hk
    LEFT JOIN {{ ref('silver_orders') }} o
        ON lco.order_hk = o.order_hk
    WHERE o.order_status_clean NOT IN ('CANCELLED', 'UNKNOWN')
    GROUP BY c.customer_id
)

SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.phone_clean AS phone,
    c.age,
    c.customer_type_clean AS customer_type,
    c.customer_segment,
    c.city,
    c.state,
    c.country,
    c.registration_date,
    c.customer_status_clean AS customer_status,
    c.lifetime_value,
    -- Order metrics
    COALESCE(co.total_orders, 0) AS total_orders,
    COALESCE(co.total_order_value, 0) AS total_order_value,
    COALESCE(co.avg_order_value, 0) AS avg_order_value,
    co.first_order_date,
    co.last_order_date,
    -- Customer segmentation
    CASE
        WHEN COALESCE(co.total_orders, 0) = 0 THEN 'PROSPECT'
        WHEN COALESCE(co.total_orders, 0) = 1 THEN 'NEW_CUSTOMER'
        WHEN COALESCE(co.total_orders, 0) BETWEEN 2 AND 5 THEN 'REGULAR_CUSTOMER'
        WHEN COALESCE(co.total_orders, 0) > 5 THEN 'LOYAL_CUSTOMER'
    END AS customer_lifecycle_stage,
    -- Value tier
    CASE
        WHEN c.lifetime_value >= 50000 THEN 'HIGH_VALUE'
        WHEN c.lifetime_value >= 10000 THEN 'MEDIUM_VALUE'
        WHEN c.lifetime_value >= 1000 THEN 'LOW_VALUE'
        ELSE 'MINIMAL_VALUE'
    END AS value_tier,
    -- Recency calculation
    DATEDIFF(DAY, co.last_order_date, CURRENT_DATE()) AS days_since_last_order,
    -- Data quality flags
    c.is_missing_email,
    c.is_missing_phone,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM customer_base c
LEFT JOIN customer_orders co ON c.customer_id = co.customer_id

