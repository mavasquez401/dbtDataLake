# Demo Walkthrough

This document provides a step-by-step walkthrough for demonstrating the Institutional Client Data Lake platform.

## Pre-Demo Setup

### 1. Environment Check

```bash
# Verify all services are running
aws s3 ls s3://institutional-data-lake/
snowflake --version
dbt --version
terraform --version
```

### 2. Generate Fresh Data

```bash
python scripts/generate_sample_data.py
python scripts/upload_to_s3.py
```

### 3. Run Transformations

```bash
cd dbt_project
dbt run
dbt test
```

## Demo Flow (15-20 minutes)

### Part 1: Architecture Overview (3 minutes)

**Show**: `docs/architecture_diagram.png`

**Key Points:**

- Multi-domain data lake (Finance, Operations, CRM)
- AWS S3 for scalable storage
- Glue for metadata cataloging
- Snowflake for data warehousing
- dbt for transformations
- Great Expectations for quality
- GitHub Actions for CI/CD

**Script:**

> "This is an enterprise data lake platform I built to showcase modern data engineering practices. It ingests data from three domains—Finance, Operations, and CRM—stores it in AWS S3, catalogs it with Glue, and loads it into Snowflake. We then use dbt to transform the data through bronze, silver, and gold layers, with Great Expectations ensuring quality at each step."

### Part 2: Data Vault 2.0 Modeling (4 minutes)

**Show**: `docs/data_vault_design.md` and Snowflake schema

**Demo Commands:**

```sql
-- Show Hubs (business keys)
SELECT * FROM DATA_LAKE.STAGE.HUB_CUSTOMER LIMIT 5;

-- Show Satellites (attributes with history)
SELECT
    customer_id,
    customer_status,
    load_date,
    end_date
FROM DATA_LAKE.STAGE.HUB_CUSTOMER h
JOIN DATA_LAKE.STAGE.SAT_CUSTOMER s ON h.customer_hk = s.customer_hk
WHERE customer_id = 'CUST000001'
ORDER BY load_date;

-- Show Links (relationships)
SELECT * FROM DATA_LAKE.STAGE.LINK_CUSTOMER_ACCOUNT LIMIT 5;
```

**Key Points:**

- Hubs contain unique business keys
- Satellites track full history (SCD Type 2)
- Links represent relationships
- Enables auditability and agility

**Script:**

> "I implemented Data Vault 2.0, which is an enterprise data warehouse methodology. It separates business keys in Hubs, relationships in Links, and attributes in Satellites. This design provides full historical tracking—notice how we can see when a customer's status changed over time. This is crucial for audit and compliance."

### Part 3: Medallion Architecture (5 minutes)

**Show**: dbt lineage graph

**Demo Commands:**

```sql
-- Bronze: Raw data
SELECT * FROM DATA_LAKE.BRONZE.BRONZE_CUSTOMERS LIMIT 5;

-- Silver: Cleansed data
SELECT
    customer_id,
    full_name,
    age,
    customer_status_clean,
    is_missing_email
FROM DATA_LAKE.SILVER.SILVER_CUSTOMERS
LIMIT 5;

-- Gold: Business aggregates
SELECT
    customer_id,
    full_name,
    total_orders,
    lifetime_value,
    customer_lifecycle_stage,
    value_tier
FROM DATA_LAKE.GOLD.GOLD_CUSTOMER_SUMMARY
WHERE value_tier = 'HIGH_VALUE'
LIMIT 10;
```

**Key Points:**

- Bronze: Minimal transformation, preserves raw data
- Silver: Cleansed, standardized, validated
- Gold: Business-ready aggregates
- Each layer adds value and quality

**Script:**

> "I implemented the medallion architecture with three layers. Bronze is raw data from our Data Vault. Silver applies cleansing rules—notice how names are standardized, ages are calculated, and we flag data quality issues. Gold provides business-ready aggregates like customer lifetime value and lifecycle stages. This layered approach ensures data quality improves at each step."

### Part 4: Cross-Domain Analytics (3 minutes)

**Demo Commands:**

```sql
-- Customer 360 view combining CRM and Finance
SELECT
    customer_id,
    full_name,
    customer_segment,
    total_accounts,
    total_balance_across_accounts,
    total_transactions,
    customer_value_score,
    engagement_level,
    churn_risk
FROM DATA_LAKE.GOLD.GOLD_CROSS_DOMAIN_ANALYTICS
WHERE engagement_level = 'HIGHLY_ENGAGED'
  AND churn_risk = 'HIGH_RISK'
ORDER BY customer_value_score DESC
LIMIT 10;
```

**Key Points:**

- Combines data from multiple domains
- Provides 360-degree customer view
- Enables advanced analytics
- Supports business decision-making

**Script:**

> "One of the most powerful features is cross-domain analytics. This query combines CRM and Finance data to identify high-value customers who are highly engaged but at risk of churning. This insight enables proactive retention strategies. The customer value score is a composite metric I created that weighs both account balances and transaction activity."

### Part 5: Data Quality & Testing (3 minutes)

**Show**: Great Expectations report and dbt test results

**Demo Commands:**

```bash
# Show dbt tests
cd dbt_project
dbt test --select silver_customers

# Show data quality validations
python scripts/run_data_quality.py
```

**Key Points:**

- Automated validation at every layer
- dbt tests for referential integrity
- Great Expectations for business rules
- Quality gates in CI/CD pipeline

**Script:**

> "Data quality is critical, so I implemented comprehensive testing. dbt tests validate things like primary key uniqueness and referential integrity. Great Expectations validates business rules—like ensuring ages are between 18 and 120, or that transaction amounts are non-negative. These validations run automatically in our CI/CD pipeline, preventing bad data from reaching production."

### Part 6: CI/CD & Infrastructure (2 minutes)

**Show**: GitHub Actions workflows and Terraform code

**Demo:**

- Show `.github/workflows/ci_cd.yml`
- Show Terraform modules
- Show a successful pipeline run

**Key Points:**

- Fully automated infrastructure with Terraform
- CI/CD pipeline with testing and deployment
- Separate dev and prod environments
- Infrastructure as code for reproducibility

**Script:**

> "Everything is automated. Terraform provisions all AWS and Snowflake resources—S3 buckets, Glue crawlers, databases, warehouses. The GitHub Actions pipeline runs on every commit: it lints code, runs tests, validates data quality, and deploys to dev or prod based on the branch. This ensures consistency and enables rapid iteration."

## Advanced Demo Topics

### Historical Tracking

```sql
-- Show how customer status changed over time
SELECT
    h.customer_id,
    s.customer_status,
    s.load_date,
    s.end_date,
    CASE WHEN s.end_date IS NULL THEN 'CURRENT' ELSE 'HISTORICAL' END AS record_type
FROM DATA_LAKE.STAGE.HUB_CUSTOMER h
JOIN DATA_LAKE.STAGE.SAT_CUSTOMER s ON h.customer_hk = s.customer_hk
WHERE h.customer_id = 'CUST000001'
ORDER BY s.load_date DESC;
```

### Performance Metrics

```sql
-- Order fulfillment trends
SELECT
    order_year,
    order_month,
    total_orders,
    fulfillment_rate_pct,
    cancellation_rate_pct
FROM DATA_LAKE.GOLD.GOLD_ORDER_METRICS
WHERE order_year = 2024
ORDER BY order_month DESC;
```

### Transaction Analytics

```sql
-- Identify dormant high-value accounts
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
ORDER BY current_balance DESC;
```

## Q&A Preparation

### Common Questions

**Q: How does this scale?**
A: The architecture is cloud-native and scales horizontally. S3 handles petabytes, Snowflake auto-scales compute, and dbt can process millions of rows efficiently with incremental models.

**Q: How do you handle schema changes?**
A: Data Vault 2.0 makes schema evolution agile. New attributes go into new satellites, new relationships into new links. No need to modify existing structures.

**Q: What about data privacy?**
A: We can implement column-level encryption, dynamic data masking in Snowflake, and role-based access control. PII can be tokenized or hashed.

**Q: How do you monitor data quality over time?**
A: Great Expectations stores validation results with timestamps. We can track quality metrics over time and set up alerts for degradation.

**Q: What's the deployment process?**
A: Push to develop branch → CI runs tests → Auto-deploy to dev. Push to main → CI runs tests → Manual approval → Deploy to prod. All tracked in GitHub.

**Q: How do you handle incremental loads?**
A: dbt supports incremental materializations. We can load only new/changed records based on timestamps or change detection hashes.

## Post-Demo Follow-Up

### Artifacts to Share

1. GitHub repository link
2. dbt documentation (HTML export)
3. Architecture diagrams
4. Data quality reports
5. Sample queries and use cases

### Key Metrics to Highlight

- 7 Hubs, 6 Links, 7 Satellites (Data Vault)
- 4 Bronze, 3 Silver, 4 Gold models (dbt)
- 20+ data quality validations
- 100% infrastructure as code
- Fully automated CI/CD pipeline

### Technical Depth Demonstrated

- Enterprise data modeling (Data Vault 2.0)
- Modern data stack (AWS, Snowflake, dbt)
- Data quality engineering (Great Expectations)
- DevOps practices (Terraform, GitHub Actions)
- SQL expertise (complex transformations)
- Python programming (data generation, utilities)

## Customization for Different Audiences

### For Data Engineers

- Focus on technical implementation
- Show dbt macros and Jinja templating
- Discuss performance optimization
- Explain incremental loading strategies

### For Data Analysts

- Focus on business value
- Show gold layer analytics
- Demonstrate self-service capabilities
- Explain data lineage and trust

### For Leadership

- Focus on business outcomes
- Show ROI metrics
- Discuss scalability and governance
- Highlight automation and efficiency

### For DevOps/Platform Engineers

- Focus on infrastructure
- Show Terraform modules
- Discuss CI/CD pipeline
- Explain monitoring and alerting
