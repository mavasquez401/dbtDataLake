-- Gold Layer: Cross-Domain Analytics
-- Combines data from Finance and CRM domains for comprehensive customer insights

{{
    config(
        materialized='table',
        tags=['gold', 'cross-domain', 'analytics']
    )
}}

WITH customers AS (
    SELECT * FROM {{ ref('silver_customers') }}
),

accounts AS (
    SELECT * FROM {{ ref('bronze_accounts') }}
),

transactions AS (
    SELECT * FROM {{ ref('silver_transactions') }}
),

-- Link customers to accounts
customer_accounts AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.customer_segment,
        c.customer_status_clean AS customer_status,
        a.account_id,
        a.account_type,
        a.balance
    FROM customers c
    INNER JOIN {{ source('stage', 'link_customer_account') }} lca
        ON c.customer_hk = lca.customer_hk
    INNER JOIN accounts a
        ON lca.account_hk = a.account_hk
    WHERE a.account_status = 'ACTIVE'
),

-- Aggregate transactions per customer
customer_transactions AS (
    SELECT
        ca.customer_id,
        COUNT(DISTINCT t.transaction_id) AS total_transactions,
        SUM(t.amount) AS total_transaction_amount,
        AVG(t.amount) AS avg_transaction_amount,
        MAX(t.transaction_date) AS last_transaction_date
    FROM customer_accounts ca
    INNER JOIN {{ source('stage', 'link_account_transaction') }} lat
        ON ca.account_id = lat.account_hk
    INNER JOIN transactions t
        ON lat.transaction_hk = t.transaction_hk
    WHERE t.status_clean = 'COMPLETED'
    GROUP BY ca.customer_id
)

SELECT
    ca.customer_id,
    ca.full_name,
    ca.customer_segment,
    ca.customer_status,
    -- Account metrics
    COUNT(DISTINCT ca.account_id) AS total_accounts,
    SUM(ca.balance) AS total_balance_across_accounts,
    AVG(ca.balance) AS avg_account_balance,
    -- Transaction metrics
    COALESCE(ct.total_transactions, 0) AS total_transactions,
    COALESCE(ct.total_transaction_amount, 0) AS total_transaction_amount,
    COALESCE(ct.avg_transaction_amount, 0) AS avg_transaction_amount,
    ct.last_transaction_date,
    -- Customer value score (composite metric)
    (
        COALESCE(SUM(ca.balance), 0) * 0.4 +
        COALESCE(ct.total_transaction_amount, 0) * 0.6
    ) AS customer_value_score,
    -- Engagement level
    CASE
        WHEN COALESCE(ct.total_transactions, 0) >= 50 THEN 'HIGHLY_ENGAGED'
        WHEN COALESCE(ct.total_transactions, 0) >= 20 THEN 'ENGAGED'
        WHEN COALESCE(ct.total_transactions, 0) >= 5 THEN 'MODERATELY_ENGAGED'
        ELSE 'LOW_ENGAGEMENT'
    END AS engagement_level,
    -- Risk indicator
    CASE
        WHEN SUM(ca.balance) < 1000 AND COALESCE(ct.total_transactions, 0) < 5 THEN 'HIGH_RISK'
        WHEN SUM(ca.balance) < 5000 AND COALESCE(ct.total_transactions, 0) < 10 THEN 'MEDIUM_RISK'
        ELSE 'LOW_RISK'
    END AS churn_risk,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM customer_accounts ca
LEFT JOIN customer_transactions ct ON ca.customer_id = ct.customer_id
GROUP BY
    ca.customer_id,
    ca.full_name,
    ca.customer_segment,
    ca.customer_status,
    ct.total_transactions,
    ct.total_transaction_amount,
    ct.avg_transaction_amount,
    ct.last_transaction_date

