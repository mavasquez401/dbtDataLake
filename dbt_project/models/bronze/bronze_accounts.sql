-- Bronze Layer: Raw Finance Accounts
-- Ingests account data from Data Vault hub and satellite

{{
    config(
        materialized='table',
        tags=['bronze', 'finance', 'accounts']
    )
}}

WITH account_hub AS (
    SELECT
        account_hk,
        account_id,
        load_date AS hub_load_date,
        record_source
    FROM {{ source('stage', 'hub_account') }}
),

account_sat AS (
    SELECT
        account_hk,
        load_date,
        end_date,
        account_number,
        account_type,
        account_status,
        balance,
        currency,
        open_date,
        record_source
    FROM {{ source('stage', 'sat_account') }}
    WHERE end_date IS NULL  -- Get current records only
)

SELECT
    h.account_hk,
    h.account_id,
    s.account_number,
    s.account_type,
    s.account_status,
    s.balance,
    s.currency,
    s.open_date,
    h.hub_load_date,
    s.load_date AS sat_load_date,
    COALESCE(s.record_source, h.record_source) AS record_source,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM account_hub h
LEFT JOIN account_sat s ON h.account_hk = s.account_hk

