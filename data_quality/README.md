# Data Quality Framework

This directory contains the data quality validation framework using Great Expectations.

## Overview

Great Expectations is used to validate data quality across all layers of the data lake:
- **Bronze Layer**: Raw data validation (nulls, uniqueness, formats)
- **Silver Layer**: Cleansed data validation (ranges, accepted values)
- **Gold Layer**: Business metrics validation (aggregations, relationships)

## Setup

### Initialize Great Expectations

```bash
cd data_quality
great_expectations init
```

### Configure Snowflake Connection

Update the `great_expectations.yml` file with your Snowflake credentials or use environment variables.

## Expectation Suites

### Bronze Layer Validations

**bronze_customers_suite**
- Primary key uniqueness and not null
- Email format validation
- Customer status in accepted values

**bronze_accounts_suite**
- Account ID uniqueness
- Balance not null
- Account type in accepted values

**bronze_transactions_suite**
- Transaction ID uniqueness
- Amount and date not null
- Transaction status validation

### Silver Layer Validations

**silver_customers_suite**
- Age between 18 and 120
- Standardized status values
- Lifetime value non-negative
- Email format compliance

**silver_transactions_suite**
- Amount non-negative
- Transaction date within valid range
- Status standardization
- Currency code validation

**silver_orders_suite**
- Order total non-negative
- Priority in accepted values
- Status standardization
- Date consistency

### Gold Layer Validations

**gold_customer_summary_suite**
- Customer ID uniqueness
- Total orders non-negative
- Lifecycle stage in accepted values
- Value tier validation

**gold_transaction_summary_suite**
- Account ID uniqueness
- Transaction counts non-negative
- Balance consistency
- Activity flag validation

## Running Validations

### Run All Validations

```bash
python scripts/run_data_quality.py
```

### Run Specific Suite

```bash
great_expectations checkpoint run bronze_customers_checkpoint
```

### View Results

```bash
great_expectations docs build
```

This will open the data docs in your browser showing validation results.

## Validation Rules

### Null Checks
- Critical columns must not contain null values
- Optional columns flagged when null

### Primary Key Consistency
- All primary keys must be unique
- No duplicate business keys

### Foreign Key Consistency
- All foreign keys must reference valid parent records
- Orphaned records flagged

### Value Range Validations
- Numeric fields within expected ranges
- Dates within valid periods
- Amounts non-negative where applicable

### SLA Thresholds
- Row counts meet minimum thresholds
- Data freshness within acceptable limits
- Processing time within SLA

## Integration with CI/CD

Data quality checks are integrated into the GitHub Actions pipeline:

1. **Pre-deployment**: Validate bronze layer data
2. **Post-transformation**: Validate silver and gold layers
3. **Continuous**: Scheduled validation runs

## Monitoring and Alerting

- Validation results stored in `uncommitted/validations/`
- Failed validations trigger alerts
- Metrics tracked over time for trend analysis

## Best Practices

1. **Start Simple**: Begin with basic null and uniqueness checks
2. **Iterate**: Add more sophisticated validations as understanding grows
3. **Document**: Clearly document business rules behind expectations
4. **Review**: Regularly review and update expectations
5. **Collaborate**: Work with data producers to improve quality at source

