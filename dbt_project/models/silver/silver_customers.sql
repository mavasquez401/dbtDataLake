-- Silver Layer: Cleansed and Conformed Customers
-- Applies data quality rules and standardization

{{
    config(
        materialized='table',
        tags=['silver', 'crm', 'customers']
    )
}}

SELECT
    customer_hk,
    customer_id,
    -- Standardize names
    UPPER(TRIM(first_name)) AS first_name,
    UPPER(TRIM(last_name)) AS last_name,
    UPPER(TRIM(first_name)) || ' ' || UPPER(TRIM(last_name)) AS full_name,
    -- Standardize email
    LOWER(TRIM(email)) AS email,
    -- Clean phone number
    REGEXP_REPLACE(phone, '[^0-9]', '') AS phone_clean,
    date_of_birth,
    -- Calculate age
    DATEDIFF(YEAR, date_of_birth, CURRENT_DATE()) AS age,
    -- Standardize customer type
    CASE
        WHEN customer_type IN ('INDIVIDUAL', 'RETAIL') THEN 'INDIVIDUAL'
        WHEN customer_type IN ('BUSINESS', 'COMMERCIAL') THEN 'BUSINESS'
        WHEN customer_type = 'INSTITUTIONAL' THEN 'INSTITUTIONAL'
        ELSE 'UNKNOWN'
    END AS customer_type_clean,
    customer_segment,
    -- Standardize address components
    TRIM(address) AS address,
    UPPER(TRIM(city)) AS city,
    UPPER(TRIM(state)) AS state,
    zip_code,
    UPPER(TRIM(country)) AS country,
    registration_date,
    -- Standardize status
    CASE
        WHEN customer_status = 'ACTIVE' THEN 'ACTIVE'
        WHEN customer_status IN ('INACTIVE', 'DORMANT') THEN 'INACTIVE'
        WHEN customer_status IN ('CHURNED', 'CLOSED') THEN 'CHURNED'
        ELSE 'UNKNOWN'
    END AS customer_status_clean,
    -- Ensure lifetime value is non-negative
    CASE
        WHEN lifetime_value < 0 THEN 0
        ELSE lifetime_value
    END AS lifetime_value,
    -- Data quality flags
    CASE
        WHEN email IS NULL OR email = '' THEN TRUE
        ELSE FALSE
    END AS is_missing_email,
    CASE
        WHEN phone IS NULL OR phone = '' THEN TRUE
        ELSE FALSE
    END AS is_missing_phone,
    record_source,
    hub_load_date,
    sat_load_date,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM {{ ref('bronze_customers') }}
WHERE customer_id IS NOT NULL  -- Filter out invalid records

