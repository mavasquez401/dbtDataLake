-- Silver Layer: Cleansed and Conformed Orders
-- Applies data quality rules and standardization

{{
    config(
        materialized='table',
        tags=['silver', 'operations', 'orders']
    )
}}

SELECT
    order_hk,
    order_id,
    order_date,
    -- Extract date components
    DATE(order_date) AS order_date_only,
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    EXTRACT(DAY FROM order_date) AS order_day,
    -- Standardize order status
    CASE
        WHEN order_status = 'PENDING' THEN 'PENDING'
        WHEN order_status = 'PROCESSING' THEN 'PROCESSING'
        WHEN order_status = 'SHIPPED' THEN 'SHIPPED'
        WHEN order_status = 'DELIVERED' THEN 'DELIVERED'
        WHEN order_status IN ('CANCELLED', 'CANCELED') THEN 'CANCELLED'
        ELSE 'UNKNOWN'
    END AS order_status_clean,
    -- Ensure order total is valid
    CASE
        WHEN order_total < 0 THEN 0
        ELSE order_total
    END AS order_total,
    UPPER(TRIM(currency)) AS currency,
    -- Standardize payment method
    UPPER(TRIM(payment_method)) AS payment_method,
    TRIM(shipping_address) AS shipping_address,
    TRIM(billing_address) AS billing_address,
    -- Standardize priority
    CASE
        WHEN priority = 'LOW' THEN 'LOW'
        WHEN priority = 'MEDIUM' THEN 'MEDIUM'
        WHEN priority = 'HIGH' THEN 'HIGH'
        WHEN priority = 'URGENT' THEN 'URGENT'
        ELSE 'MEDIUM'
    END AS priority_clean,
    -- Data quality flags
    CASE
        WHEN order_total = 0 THEN TRUE
        ELSE FALSE
    END AS is_zero_total,
    CASE
        WHEN shipping_address IS NULL OR shipping_address = '' THEN TRUE
        ELSE FALSE
    END AS is_missing_shipping_address,
    record_source,
    hub_load_date,
    sat_load_date,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM {{ ref('bronze_orders') }}
WHERE order_id IS NOT NULL
    AND order_date IS NOT NULL

