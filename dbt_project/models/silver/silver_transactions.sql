-- Silver Layer: Cleansed and Conformed Transactions
-- Applies data quality rules and standardization

{{
    config(
        materialized='table',
        tags=['silver', 'finance', 'transactions']
    )
}}

SELECT
    transaction_hk,
    transaction_id,
    -- Standardize transaction type
    UPPER(TRIM(transaction_type)) AS transaction_type,
    -- Ensure amount is valid
    CASE
        WHEN amount IS NULL THEN 0
        WHEN amount < 0 AND transaction_type IN ('WITHDRAWAL', 'PAYMENT', 'FEE') THEN ABS(amount)
        ELSE amount
    END AS amount,
    UPPER(TRIM(currency)) AS currency,
    transaction_date,
    -- Extract date components for analysis
    DATE(transaction_date) AS transaction_date_only,
    EXTRACT(YEAR FROM transaction_date) AS transaction_year,
    EXTRACT(MONTH FROM transaction_date) AS transaction_month,
    EXTRACT(DAY FROM transaction_date) AS transaction_day,
    DAYNAME(transaction_date) AS transaction_day_name,
    TRIM(description) AS description,
    TRIM(merchant) AS merchant,
    -- Standardize category
    UPPER(TRIM(category)) AS category,
    -- Standardize status
    CASE
        WHEN status = 'COMPLETED' THEN 'COMPLETED'
        WHEN status = 'PENDING' THEN 'PENDING'
        WHEN status IN ('FAILED', 'DECLINED', 'REJECTED') THEN 'FAILED'
        ELSE 'UNKNOWN'
    END AS status_clean,
    -- Data quality flags
    CASE
        WHEN merchant IS NULL OR merchant = '' THEN TRUE
        ELSE FALSE
    END AS is_missing_merchant,
    CASE
        WHEN amount = 0 THEN TRUE
        ELSE FALSE
    END AS is_zero_amount,
    record_source,
    hub_load_date,
    sat_load_date,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM {{ ref('bronze_transactions') }}
WHERE transaction_id IS NOT NULL
    AND transaction_date IS NOT NULL

