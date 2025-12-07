-- Bronze Layer: Raw Operations Orders
-- Ingests order data from Data Vault hub and satellite

{{
    config(
        materialized='table',
        tags=['bronze', 'operations', 'orders']
    )
}}

WITH order_hub AS (
    SELECT
        order_hk,
        order_id,
        load_date AS hub_load_date,
        record_source
    FROM {{ source('stage', 'hub_order') }}
),

order_sat AS (
    SELECT
        order_hk,
        load_date,
        end_date,
        order_date,
        order_status,
        order_total,
        currency,
        payment_method,
        shipping_address,
        billing_address,
        priority,
        record_source
    FROM {{ source('stage', 'sat_order') }}
    WHERE end_date IS NULL  -- Get current records only
)

SELECT
    h.order_hk,
    h.order_id,
    s.order_date,
    s.order_status,
    s.order_total,
    s.currency,
    s.payment_method,
    s.shipping_address,
    s.billing_address,
    s.priority,
    h.hub_load_date,
    s.load_date AS sat_load_date,
    COALESCE(s.record_source, h.record_source) AS record_source,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM order_hub h
LEFT JOIN order_sat s ON h.order_hk = s.order_hk

