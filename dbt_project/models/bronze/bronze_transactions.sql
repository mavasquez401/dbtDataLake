-- Bronze Layer: Raw Finance Transactions
-- Ingests transaction data from Data Vault hub and satellite

{{
    config(
        materialized='table',
        tags=['bronze', 'finance', 'transactions']
    )
}}

WITH transaction_hub AS (
    SELECT
        transaction_hk,
        transaction_id,
        load_date AS hub_load_date,
        record_source
    FROM {{ source('stage', 'hub_transaction') }}
),

transaction_sat AS (
    SELECT
        transaction_hk,
        load_date,
        end_date,
        transaction_type,
        amount,
        currency,
        transaction_date,
        description,
        merchant,
        category,
        status,
        record_source
    FROM {{ source('stage', 'sat_transaction') }}
    WHERE end_date IS NULL  -- Get current records only
)

SELECT
    h.transaction_hk,
    h.transaction_id,
    s.transaction_type,
    s.amount,
    s.currency,
    s.transaction_date,
    s.description,
    s.merchant,
    s.category,
    s.status,
    h.hub_load_date,
    s.load_date AS sat_load_date,
    COALESCE(s.record_source, h.record_source) AS record_source,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM transaction_hub h
LEFT JOIN transaction_sat s ON h.transaction_hk = s.transaction_hk

