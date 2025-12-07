-- Sample Queries for Institutional Data Lake Platform
-- Demonstrates key analytics use cases and platform capabilities

-- ============================================================================
-- CUSTOMER 360 ANALYTICS
-- ============================================================================

-- 1. High-Value Customer Identification
-- Identify customers with high lifetime value and engagement
SELECT
    customer_id,
    full_name,
    email,
    customer_segment,
    lifetime_value,
    total_orders,
    value_tier,
    customer_lifecycle_stage
FROM DATA_LAKE.GOLD.GOLD_CUSTOMER_SUMMARY
WHERE value_tier IN ('HIGH_VALUE', 'MEDIUM_VALUE')
  AND customer_status = 'ACTIVE'
ORDER BY lifetime_value DESC
LIMIT 20;

-- 2. Customer Churn Risk Analysis
-- Find high-value customers at risk of churning
SELECT
    customer_id,
    full_name,
    customer_value_score,
    engagement_level,
    churn_risk,
    total_accounts,
    total_balance_across_accounts,
    total_transactions
FROM DATA_LAKE.GOLD.GOLD_CROSS_DOMAIN_ANALYTICS
WHERE engagement_level = 'HIGHLY_ENGAGED'
  AND churn_risk = 'HIGH_RISK'
ORDER BY customer_value_score DESC;

-- 3. Customer Lifecycle Analysis
-- Distribution of customers across lifecycle stages
SELECT
    customer_lifecycle_stage,
    COUNT(*) AS customer_count,
    AVG(lifetime_value) AS avg_lifetime_value,
    AVG(total_orders) AS avg_orders,
    SUM(total_order_value) AS total_revenue
FROM DATA_LAKE.GOLD.GOLD_CUSTOMER_SUMMARY
GROUP BY customer_lifecycle_stage
ORDER BY customer_count DESC;

-- 4. Customer Acquisition Trends
-- New customer registrations by month
SELECT
    DATE_TRUNC('MONTH', registration_date) AS month,
    COUNT(*) AS new_customers,
    AVG(lifetime_value) AS avg_ltv,
    COUNT(CASE WHEN total_orders > 0 THEN 1 END) AS customers_with_orders
FROM DATA_LAKE.GOLD.GOLD_CUSTOMER_SUMMARY
WHERE registration_date >= DATEADD(MONTH, -12, CURRENT_DATE())
GROUP BY month
ORDER BY month DESC;

-- ============================================================================
-- TRANSACTION ANALYTICS
-- ============================================================================

-- 5. Account Activity Summary
-- Overview of account transaction patterns
SELECT
    account_type,
    COUNT(DISTINCT account_id) AS account_count,
    SUM(total_transactions) AS total_txns,
    AVG(total_transaction_amount) AS avg_txn_amount,
    SUM(total_deposits) AS total_deposits,
    SUM(total_withdrawals) AS total_withdrawals,
    AVG(current_balance) AS avg_balance
FROM DATA_LAKE.GOLD.GOLD_TRANSACTION_SUMMARY
WHERE account_status = 'ACTIVE'
GROUP BY account_type
ORDER BY account_count DESC;

-- 6. Dormant High-Value Accounts
-- Identify inactive accounts with significant balances
SELECT
    account_id,
    account_type,
    current_balance,
    total_transactions,
    last_transaction_date,
    DATEDIFF(DAY, last_transaction_date, CURRENT_DATE()) AS days_dormant
FROM DATA_LAKE.GOLD.GOLD_TRANSACTION_SUMMARY
WHERE is_dormant = TRUE
  AND current_balance > 10000
ORDER BY current_balance DESC
LIMIT 50;

-- 7. Transaction Volume Trends
-- Daily transaction patterns
SELECT
    DATE(transaction_date) AS txn_date,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS avg_amount,
    COUNT(DISTINCT CASE WHEN transaction_type = 'DEPOSIT' THEN transaction_id END) AS deposits,
    COUNT(DISTINCT CASE WHEN transaction_type = 'WITHDRAWAL' THEN transaction_id END) AS withdrawals
FROM DATA_LAKE.SILVER.SILVER_TRANSACTIONS
WHERE transaction_date >= DATEADD(DAY, -30, CURRENT_DATE())
  AND status_clean = 'COMPLETED'
GROUP BY txn_date
ORDER BY txn_date DESC;

-- 8. High-Value Transactions
-- Identify unusually large transactions
SELECT
    t.transaction_id,
    t.transaction_type,
    t.amount,
    t.transaction_date,
    t.merchant,
    t.category,
    a.account_id,
    a.account_type
FROM DATA_LAKE.SILVER.SILVER_TRANSACTIONS t
JOIN DATA_LAKE.BRONZE.BRONZE_ACCOUNTS a
  ON t.transaction_hk = a.account_hk  -- Simplified for demo
WHERE t.amount > 10000
  AND t.status_clean = 'COMPLETED'
ORDER BY t.amount DESC
LIMIT 100;

-- ============================================================================
-- OPERATIONS & ORDER ANALYTICS
-- ============================================================================

-- 9. Order Fulfillment Performance
-- Monthly fulfillment metrics
SELECT
    order_year,
    order_month,
    total_orders,
    delivered_orders,
    cancelled_orders,
    fulfillment_rate_pct,
    cancellation_rate_pct,
    total_order_value,
    avg_order_value
FROM DATA_LAKE.GOLD.GOLD_ORDER_METRICS
WHERE order_year = 2024
ORDER BY order_year DESC, order_month DESC;

-- 10. Order Status Distribution
-- Current state of all orders
SELECT
    order_status_clean,
    COUNT(*) AS order_count,
    SUM(order_total) AS total_value,
    AVG(order_total) AS avg_value,
    MIN(order_date) AS oldest_order,
    MAX(order_date) AS newest_order
FROM DATA_LAKE.SILVER.SILVER_ORDERS
GROUP BY order_status_clean
ORDER BY order_count DESC;

-- 11. Priority Order Analysis
-- High-priority order handling
SELECT
    priority_clean,
    order_status_clean,
    COUNT(*) AS order_count,
    AVG(order_total) AS avg_order_value,
    AVG(DATEDIFF(DAY, order_date, CURRENT_DATE())) AS avg_age_days
FROM DATA_LAKE.SILVER.SILVER_ORDERS
WHERE priority_clean IN ('HIGH', 'URGENT')
GROUP BY priority_clean, order_status_clean
ORDER BY priority_clean, order_status_clean;

-- 12. Payment Method Preferences
-- Analysis of payment methods used
SELECT
    payment_method,
    COUNT(*) AS order_count,
    SUM(order_total) AS total_value,
    AVG(order_total) AS avg_order_value,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM DATA_LAKE.SILVER.SILVER_ORDERS
WHERE order_status_clean NOT IN ('CANCELLED', 'UNKNOWN')
GROUP BY payment_method
ORDER BY order_count DESC;

-- ============================================================================
-- DATA VAULT HISTORICAL QUERIES
-- ============================================================================

-- 13. Customer Status History
-- Track how a customer's status changed over time
SELECT
    h.customer_id,
    s.customer_status,
    s.load_date,
    s.end_date,
    CASE WHEN s.end_date IS NULL THEN 'CURRENT' ELSE 'HISTORICAL' END AS record_type,
    DATEDIFF(DAY, s.load_date, COALESCE(s.end_date, CURRENT_DATE())) AS days_in_status
FROM DATA_LAKE.STAGE.HUB_CUSTOMER h
JOIN DATA_LAKE.STAGE.SAT_CUSTOMER s ON h.customer_hk = s.customer_hk
WHERE h.customer_id = 'CUST000001'
ORDER BY s.load_date DESC;

-- 14. Account Balance History
-- Point-in-time account balance tracking
SELECT
    h.account_id,
    s.balance,
    s.account_status,
    s.load_date,
    s.end_date,
    CASE WHEN s.end_date IS NULL THEN 'CURRENT' ELSE 'HISTORICAL' END AS record_type
FROM DATA_LAKE.STAGE.HUB_ACCOUNT h
JOIN DATA_LAKE.STAGE.SAT_ACCOUNT s ON h.account_hk = s.account_hk
WHERE h.account_id = 'ACC000001'
ORDER BY s.load_date DESC;

-- 15. Customer-Account Relationships
-- All accounts owned by a customer
SELECT
    hc.customer_id,
    sc.first_name,
    sc.last_name,
    ha.account_id,
    sa.account_type,
    sa.balance,
    sa.account_status
FROM DATA_LAKE.STAGE.HUB_CUSTOMER hc
JOIN DATA_LAKE.STAGE.SAT_CUSTOMER sc ON hc.customer_hk = sc.customer_hk AND sc.end_date IS NULL
JOIN DATA_LAKE.STAGE.LINK_CUSTOMER_ACCOUNT lca ON hc.customer_hk = lca.customer_hk
JOIN DATA_LAKE.STAGE.HUB_ACCOUNT ha ON lca.account_hk = ha.account_hk
JOIN DATA_LAKE.STAGE.SAT_ACCOUNT sa ON ha.account_hk = sa.account_hk AND sa.end_date IS NULL
WHERE hc.customer_id = 'CUST000001';

-- ============================================================================
-- DATA QUALITY QUERIES
-- ============================================================================

-- 16. Data Quality Flags Summary
-- Overview of data quality issues
SELECT
    'Missing Email' AS quality_issue,
    COUNT(*) AS affected_records,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM DATA_LAKE.SILVER.SILVER_CUSTOMERS), 2) AS percentage
FROM DATA_LAKE.SILVER.SILVER_CUSTOMERS
WHERE is_missing_email = TRUE

UNION ALL

SELECT
    'Missing Phone' AS quality_issue,
    COUNT(*) AS affected_records,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM DATA_LAKE.SILVER.SILVER_CUSTOMERS), 2) AS percentage
FROM DATA_LAKE.SILVER.SILVER_CUSTOMERS
WHERE is_missing_phone = TRUE

UNION ALL

SELECT
    'Zero Amount Transaction' AS quality_issue,
    COUNT(*) AS affected_records,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM DATA_LAKE.SILVER.SILVER_TRANSACTIONS), 2) AS percentage
FROM DATA_LAKE.SILVER.SILVER_TRANSACTIONS
WHERE is_zero_amount = TRUE;

-- 17. Record Source Distribution
-- Track data lineage by source system
SELECT
    record_source,
    COUNT(*) AS record_count,
    MIN(hub_load_date) AS first_load,
    MAX(hub_load_date) AS last_load
FROM DATA_LAKE.BRONZE.BRONZE_CUSTOMERS
GROUP BY record_source
ORDER BY record_count DESC;

-- ============================================================================
-- ADVANCED ANALYTICS
-- ============================================================================

-- 18. Customer Segmentation Matrix
-- RFM-style segmentation
SELECT
    CASE
        WHEN days_since_last_order <= 30 THEN 'Recent'
        WHEN days_since_last_order <= 90 THEN 'Moderate'
        ELSE 'Inactive'
    END AS recency_segment,
    CASE
        WHEN total_orders >= 10 THEN 'Frequent'
        WHEN total_orders >= 5 THEN 'Regular'
        ELSE 'Occasional'
    END AS frequency_segment,
    value_tier AS monetary_segment,
    COUNT(*) AS customer_count,
    AVG(lifetime_value) AS avg_ltv
FROM DATA_LAKE.GOLD.GOLD_CUSTOMER_SUMMARY
WHERE customer_status = 'ACTIVE'
GROUP BY recency_segment, frequency_segment, monetary_segment
ORDER BY customer_count DESC;

-- 19. Cross-Sell Opportunities
-- Customers with only one account type
SELECT
    c.customer_id,
    c.full_name,
    c.customer_segment,
    c.lifetime_value,
    COUNT(DISTINCT a.account_type) AS account_types,
    STRING_AGG(DISTINCT a.account_type, ', ') AS current_accounts
FROM DATA_LAKE.SILVER.SILVER_CUSTOMERS c
JOIN DATA_LAKE.STAGE.LINK_CUSTOMER_ACCOUNT lca ON c.customer_hk = lca.customer_hk
JOIN DATA_LAKE.BRONZE.BRONZE_ACCOUNTS a ON lca.account_hk = a.account_hk
WHERE c.customer_status_clean = 'ACTIVE'
  AND a.account_status = 'ACTIVE'
GROUP BY c.customer_id, c.full_name, c.customer_segment, c.lifetime_value
HAVING COUNT(DISTINCT a.account_type) = 1
ORDER BY c.lifetime_value DESC
LIMIT 100;

-- 20. Cohort Analysis
-- Customer retention by registration cohort
SELECT
    DATE_TRUNC('MONTH', registration_date) AS cohort_month,
    COUNT(*) AS cohort_size,
    COUNT(CASE WHEN customer_status = 'ACTIVE' THEN 1 END) AS active_customers,
    ROUND(COUNT(CASE WHEN customer_status = 'ACTIVE' THEN 1 END) * 100.0 / COUNT(*), 2) AS retention_rate,
    AVG(total_orders) AS avg_orders_per_customer,
    AVG(lifetime_value) AS avg_ltv
FROM DATA_LAKE.GOLD.GOLD_CUSTOMER_SUMMARY
WHERE registration_date >= DATEADD(MONTH, -12, CURRENT_DATE())
GROUP BY cohort_month
ORDER BY cohort_month DESC;

