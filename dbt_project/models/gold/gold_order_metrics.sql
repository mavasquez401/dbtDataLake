-- Gold Layer: Order Metrics
-- Business-ready order analytics with time-based aggregations

{{
    config(
        materialized='table',
        tags=['gold', 'operations', 'metrics']
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('silver_orders') }}
)

SELECT
    -- Time dimensions
    order_year,
    order_month,
    order_date_only,
    -- Order counts by status
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN order_status_clean = 'PENDING' THEN order_id END) AS pending_orders,
    COUNT(DISTINCT CASE WHEN order_status_clean = 'PROCESSING' THEN order_id END) AS processing_orders,
    COUNT(DISTINCT CASE WHEN order_status_clean = 'SHIPPED' THEN order_id END) AS shipped_orders,
    COUNT(DISTINCT CASE WHEN order_status_clean = 'DELIVERED' THEN order_id END) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN order_status_clean = 'CANCELLED' THEN order_id END) AS cancelled_orders,
    -- Order values
    SUM(order_total) AS total_order_value,
    AVG(order_total) AS avg_order_value,
    MIN(order_total) AS min_order_value,
    MAX(order_total) AS max_order_value,
    -- Priority breakdown
    COUNT(DISTINCT CASE WHEN priority_clean = 'URGENT' THEN order_id END) AS urgent_orders,
    COUNT(DISTINCT CASE WHEN priority_clean = 'HIGH' THEN order_id END) AS high_priority_orders,
    COUNT(DISTINCT CASE WHEN priority_clean = 'MEDIUM' THEN order_id END) AS medium_priority_orders,
    COUNT(DISTINCT CASE WHEN priority_clean = 'LOW' THEN order_id END) AS low_priority_orders,
    -- Payment method breakdown
    COUNT(DISTINCT CASE WHEN payment_method = 'CREDIT_CARD' THEN order_id END) AS credit_card_orders,
    COUNT(DISTINCT CASE WHEN payment_method = 'DEBIT_CARD' THEN order_id END) AS debit_card_orders,
    COUNT(DISTINCT CASE WHEN payment_method = 'BANK_TRANSFER' THEN order_id END) AS bank_transfer_orders,
    COUNT(DISTINCT CASE WHEN payment_method = 'PAYPAL' THEN order_id END) AS paypal_orders,
    -- Fulfillment rate
    ROUND(
        COUNT(DISTINCT CASE WHEN order_status_clean = 'DELIVERED' THEN order_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS fulfillment_rate_pct,
    -- Cancellation rate
    ROUND(
        COUNT(DISTINCT CASE WHEN order_status_clean = 'CANCELLED' THEN order_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS cancellation_rate_pct,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM orders
GROUP BY
    order_year,
    order_month,
    order_date_only
ORDER BY
    order_year DESC,
    order_month DESC,
    order_date_only DESC

