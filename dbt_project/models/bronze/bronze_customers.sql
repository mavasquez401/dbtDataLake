-- Bronze Layer: Raw CRM Customers
-- Ingests customer data from Data Vault hub and satellite

{{
    config(
        materialized='table',
        tags=['bronze', 'crm', 'customers']
    )
}}

WITH customer_hub AS (
    SELECT
        customer_hk,
        customer_id,
        load_date AS hub_load_date,
        record_source
    FROM {{ source('stage', 'hub_customer') }}
),

customer_sat AS (
    SELECT
        customer_hk,
        load_date,
        end_date,
        first_name,
        last_name,
        email,
        phone,
        date_of_birth,
        customer_type,
        customer_segment,
        address,
        city,
        state,
        zip_code,
        country,
        registration_date,
        customer_status,
        lifetime_value,
        record_source
    FROM {{ source('stage', 'sat_customer') }}
    WHERE end_date IS NULL  -- Get current records only
)

SELECT
    h.customer_hk,
    h.customer_id,
    s.first_name,
    s.last_name,
    s.email,
    s.phone,
    s.date_of_birth,
    s.customer_type,
    s.customer_segment,
    s.address,
    s.city,
    s.state,
    s.zip_code,
    s.country,
    s.registration_date,
    s.customer_status,
    s.lifetime_value,
    h.hub_load_date,
    s.load_date AS sat_load_date,
    COALESCE(s.record_source, h.record_source) AS record_source,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM customer_hub h
LEFT JOIN customer_sat s ON h.customer_hk = s.customer_hk

