-- Gold Layer: Transaction Summary by Account
-- Business-ready transaction analytics aggregated by account

{{
    config(
        materialized='table',
        tags=['gold', 'finance', 'summary']
    )
}}

WITH accounts AS (
    SELECT * FROM {{ ref('bronze_accounts') }}
),

transactions AS (
    SELECT * FROM {{ ref('silver_transactions') }}
),

-- Link accounts to transactions
account_transactions AS (
    SELECT
        a.account_id,
        a.account_type,
        a.account_status,
        a.balance AS current_balance,
        t.transaction_id,
        t.transaction_type,
        t.amount,
        t.transaction_date,
        t.transaction_year,
        t.transaction_month,
        t.category,
        t.status_clean AS transaction_status
    FROM accounts a
    LEFT JOIN {{ source('stage', 'link_account_transaction') }} lat
        ON a.account_hk = lat.account_hk
    LEFT JOIN transactions t
        ON lat.transaction_hk = t.transaction_hk
    WHERE t.status_clean = 'COMPLETED'
)

SELECT
    account_id,
    account_type,
    account_status,
    current_balance,
    -- Transaction counts
    COUNT(DISTINCT transaction_id) AS total_transactions,
    COUNT(DISTINCT CASE WHEN transaction_type = 'DEPOSIT' THEN transaction_id END) AS deposit_count,
    COUNT(DISTINCT CASE WHEN transaction_type = 'WITHDRAWAL' THEN transaction_id END) AS withdrawal_count,
    COUNT(DISTINCT CASE WHEN transaction_type = 'PAYMENT' THEN transaction_id END) AS payment_count,
    -- Transaction amounts
    SUM(amount) AS total_transaction_amount,
    SUM(CASE WHEN transaction_type = 'DEPOSIT' THEN amount ELSE 0 END) AS total_deposits,
    SUM(CASE WHEN transaction_type = 'WITHDRAWAL' THEN amount ELSE 0 END) AS total_withdrawals,
    SUM(CASE WHEN transaction_type = 'PAYMENT' THEN amount ELSE 0 END) AS total_payments,
    SUM(CASE WHEN transaction_type = 'FEE' THEN amount ELSE 0 END) AS total_fees,
    -- Average transaction size
    AVG(amount) AS avg_transaction_amount,
    -- Date ranges
    MIN(transaction_date) AS first_transaction_date,
    MAX(transaction_date) AS last_transaction_date,
    DATEDIFF(DAY, MIN(transaction_date), MAX(transaction_date)) AS account_age_days,
    -- Recent activity
    COUNT(DISTINCT CASE
        WHEN transaction_date >= DATEADD(DAY, -30, CURRENT_DATE())
        THEN transaction_id
    END) AS transactions_last_30_days,
    SUM(CASE
        WHEN transaction_date >= DATEADD(DAY, -30, CURRENT_DATE())
        THEN amount
        ELSE 0
    END) AS transaction_amount_last_30_days,
    -- Activity flags
    CASE
        WHEN MAX(transaction_date) >= DATEADD(DAY, -30, CURRENT_DATE()) THEN TRUE
        ELSE FALSE
    END AS is_active_last_30_days,
    CASE
        WHEN MAX(transaction_date) < DATEADD(DAY, -90, CURRENT_DATE()) THEN TRUE
        ELSE FALSE
    END AS is_dormant,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM account_transactions
GROUP BY
    account_id,
    account_type,
    account_status,
    current_balance

