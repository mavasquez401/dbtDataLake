# Institutional Client Data Lake + Governance Platform

A production-ready data lake platform showcasing enterprise data engineering best practices with AWS, Snowflake, dbt, and comprehensive data governance.

## Overview

This project implements a modern data lake architecture for institutional clients, featuring:

- **Data Vault 2.0** modeling for enterprise data warehousing
- **Medallion Architecture** (Bronze/Silver/Gold) for data quality layers
- **AWS S3 + Glue** for scalable data lake storage and cataloging
- **Snowflake** as the cloud data warehouse
- **dbt** for SQL-based transformations and testing
- **Great Expectations** for data quality validation
- **Terraform** for infrastructure as code
- **GitHub Actions** for CI/CD automation

## Architecture

### High-Level Architecture

```
Data Producers (Finance/Operations/CRM)
    ↓
AWS S3 Data Lake
    ↓
AWS Glue Catalog
    ↓
Snowflake Data Vault 2.0 (Hubs/Links/Satellites)
    ↓
dbt Transformations (Bronze → Silver → Gold)
    ↓
Business Intelligence & Analytics
```

### Technology Stack

| Layer          | Technology         | Purpose                   |
| -------------- | ------------------ | ------------------------- |
| Storage        | AWS S3             | Data lake storage         |
| Catalog        | AWS Glue           | Metadata management       |
| Warehouse      | Snowflake          | Cloud data warehouse      |
| Transformation | dbt                | SQL-based transformations |
| Data Quality   | Great Expectations | Validation & testing      |
| Infrastructure | Terraform          | IaC provisioning          |
| CI/CD          | GitHub Actions     | Automated deployment      |
| Modeling       | Data Vault 2.0     | Enterprise data modeling  |

## Project Structure

```
dbtDataLake/
├── .github/
│   └── workflows/          # CI/CD pipelines
├── config/
│   └── glue_crawlers/      # Glue crawler configurations
├── data_quality/
│   └── great_expectations/ # Data quality suites
├── dbt_project/
│   ├── models/
│   │   ├── bronze/         # Raw data ingestion
│   │   ├── silver/         # Cleansed data
│   │   └── gold/           # Business aggregates
│   ├── dbt_project.yml
│   └── profiles.yml
├── docs/                   # Documentation & diagrams
├── sample_data/            # Generated sample datasets
├── scripts/                # Python utilities
│   ├── generate_sample_data.py
│   ├── upload_to_s3.py
│   ├── setup_snowflake.py
│   └── run_data_quality.py
├── snowflake/
│   └── ddl/               # Data Vault DDL scripts
├── terraform/             # Infrastructure as Code
│   ├── s3.tf
│   ├── glue.tf
│   ├── snowflake.tf
│   └── iam.tf
├── requirements.txt
├── Makefile
└── README.md
```

## Data Model

### Data Vault 2.0 Components

**Hubs** (Business Keys)

- `hub_customer` - Customer identifiers
- `hub_account` - Account identifiers
- `hub_transaction` - Transaction identifiers
- `hub_order` - Order identifiers
- `hub_product` - Product identifiers
- `hub_interaction` - Interaction identifiers
- `hub_opportunity` - Opportunity identifiers

**Links** (Relationships)

- `link_customer_account` - Customer-Account relationships
- `link_account_transaction` - Account-Transaction relationships
- `link_customer_order` - Customer-Order relationships
- `link_order_product` - Order-Product relationships
- `link_customer_interaction` - Customer-Interaction relationships
- `link_customer_opportunity` - Customer-Opportunity relationships

**Satellites** (Attributes with History)

- `sat_customer` - Customer descriptive attributes
- `sat_account` - Account descriptive attributes
- `sat_transaction` - Transaction descriptive attributes
- `sat_order` - Order descriptive attributes
- `sat_product` - Product descriptive attributes
- `sat_interaction` - Interaction descriptive attributes
- `sat_opportunity` - Opportunity descriptive attributes

### Medallion Architecture

**Bronze Layer** - Raw data ingestion from Data Vault

- `bronze_customers`
- `bronze_accounts`
- `bronze_transactions`
- `bronze_orders`

**Silver Layer** - Cleansed and conformed data

- `silver_customers` - Standardized customer data
- `silver_transactions` - Validated transactions
- `silver_orders` - Cleansed orders

**Gold Layer** - Business-ready aggregates

- `gold_customer_summary` - Customer analytics with segmentation
- `gold_transaction_summary` - Transaction metrics by account
- `gold_order_metrics` - Order performance metrics
- `gold_cross_domain_analytics` - Combined finance + CRM insights

## Getting Started

### Prerequisites

- Python 3.11+
- AWS Account with credentials configured
- Snowflake Account
- Terraform 1.0+
- Git

### Installation

1. **Clone the repository**

```bash
git clone <repository-url>
cd dbtDataLake
```

2. **Create virtual environment**

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**

```bash
pip install -r requirements.txt
```

4. **Configure environment variables**

```bash
cp .env.example .env
# Edit .env with your credentials
```

5. **Generate sample data**

```bash
make generate-data
```

### Infrastructure Setup

#### Deploy with Terraform

```bash
# Initialize Terraform
cd terraform
terraform init

# Review planned changes
terraform plan

# Apply infrastructure
terraform apply
```

This creates:

- S3 bucket with folder structure
- Glue catalog and crawlers
- Snowflake warehouse, database, and schemas
- IAM roles and policies

#### Upload Data to S3

```bash
make upload-data
```

#### Setup Snowflake Schema

```bash
python scripts/setup_snowflake.py
```

This creates the Data Vault 2.0 schema (Hubs, Links, Satellites).

### dbt Transformations

#### Install dbt dependencies

```bash
cd dbt_project
dbt deps
```

#### Run transformations

```bash
# Run all models
dbt run

# Run specific layer
dbt run --select bronze.*
dbt run --select silver.*
dbt run --select gold.*

# Run with tests
dbt build
```

#### Generate documentation

```bash
dbt docs generate
dbt docs serve
```

### Data Quality Validation

```bash
# Run all data quality checks
make quality

# Or directly
python scripts/run_data_quality.py
```

### Testing

The project includes comprehensive unit and integration tests using pytest.

#### Run all tests

```bash
# Run all tests with coverage
make test

# Or directly with pytest
pytest

# Run with verbose output
pytest -v

# Run with coverage report
pytest --cov=scripts --cov-report=html
```

#### Run specific test files

```bash
# Test data generation
pytest tests/test_generate_sample_data.py

# Run only unit tests
pytest -m unit

# Run only integration tests
pytest -m integration
```

#### Test Structure

```
tests/
├── __init__.py              # Test package initialization
├── conftest.py              # Shared fixtures and configuration
└── test_generate_sample_data.py  # Data generation tests
```

**Test Coverage:**

- Data generation functions (finance, operations, CRM)
- Data quality validation
- Configuration and constants
- File I/O operations
- Mock testing for external dependencies

## CI/CD Pipeline

The project includes comprehensive GitHub Actions workflows:

### Main CI/CD Pipeline (`.github/workflows/ci_cd.yml`)

**On Pull Request:**

- Lint Python and SQL code
- Run Python tests
- Run dbt tests
- Execute data quality validations
- Terraform plan

**On Push to `develop`:**

- Deploy to development environment
- Run dbt models
- Execute tests

**On Push to `main`:**

- Deploy to production environment
- Run dbt models with full testing
- Generate and publish dbt docs
- Apply Terraform changes

### Data Generation Pipeline (`.github/workflows/data_generation.yml`)

**On Schedule (Weekly):**

- Generate fresh sample data
- Upload to S3
- Trigger Glue crawlers

### Required Secrets

Configure these secrets in GitHub repository settings:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
S3_BUCKET_NAME
SNOWFLAKE_ACCOUNT
SNOWFLAKE_USER
SNOWFLAKE_PASSWORD
SNOWFLAKE_ROLE
```

## Data Governance

### Data Quality Framework

**Bronze Layer Validations:**

- Primary key uniqueness
- Not null constraints
- Email format validation
- Status value checks

**Silver Layer Validations:**

- Age range validation (18-120)
- Amount non-negative checks
- Standardized value sets
- Data type consistency

**Gold Layer Validations:**

- Metric non-negativity
- Lifecycle stage validation
- Value tier consistency
- Aggregation accuracy

### Data Lineage

dbt provides automatic lineage tracking:

- Source to bronze layer
- Bronze to silver transformations
- Silver to gold aggregations
- Cross-domain relationships

View lineage in dbt docs: `dbt docs serve`

## Key Features

### 1. Data Vault 2.0 Modeling

- Separates business keys (Hubs) from relationships (Links) and attributes (Satellites)
- Full historical tracking with SCD Type 2
- Auditability with load dates and record sources
- Agile schema evolution

### 2. Medallion Architecture

- **Bronze**: Raw data, minimal transformation
- **Silver**: Cleansed, conformed, validated
- **Gold**: Business-ready aggregates and metrics

### 3. Data Quality at Every Layer

- Automated validation with Great Expectations
- dbt tests for referential integrity
- Custom business rule validations
- SLA monitoring and alerting

### 4. Infrastructure as Code

- Fully automated provisioning with Terraform
- Version-controlled infrastructure
- Reproducible environments
- Easy disaster recovery

### 5. CI/CD Automation

- Automated testing on every commit
- Deployment to dev/prod environments
- Data quality gates
- Documentation generation

## Use Cases

### Customer 360 View

Combine CRM and finance data for comprehensive customer insights:

```sql
SELECT * FROM gold_cross_domain_analytics
WHERE engagement_level = 'HIGHLY_ENGAGED'
  AND churn_risk = 'LOW_RISK';
```

### Transaction Analytics

Analyze transaction patterns and account behavior:

```sql
SELECT * FROM gold_transaction_summary
WHERE is_dormant = TRUE
  AND current_balance > 10000;
```

### Order Performance

Track order fulfillment and operational metrics:

```sql
SELECT
    order_year,
    order_month,
    fulfillment_rate_pct,
    cancellation_rate_pct
FROM gold_order_metrics
ORDER BY order_year DESC, order_month DESC;
```

## Best Practices Demonstrated

1. **Separation of Concerns**: Clear layers (storage, catalog, warehouse, transformation)
2. **Data Modeling**: Enterprise-grade Data Vault 2.0 patterns
3. **Testing**: Comprehensive unit and integration tests with pytest
4. **Documentation**: Auto-generated docs with dbt and inline code comments
5. **Version Control**: All code and configuration in Git
6. **Automation**: CI/CD for continuous delivery with GitHub Actions
7. **Monitoring**: Data quality metrics and validation with Great Expectations
8. **Security**: IAM roles, encryption, access controls
9. **Code Quality**: Linting with flake8, black, isort, and sqlfluff
10. **Reproducibility**: Faker seed for consistent test data generation

## Performance Optimization

- **Snowflake Clustering**: Tables clustered on frequently filtered columns
- **Incremental Models**: dbt incremental materializations for large tables
- **Partitioning**: S3 data partitioned by producer and date
- **Caching**: Query result caching in Snowflake
- **Warehouse Sizing**: Auto-scaling warehouses based on load

## Monitoring & Observability

- **dbt Test Results**: Track test pass/fail rates
- **Great Expectations Reports**: Data quality dashboards
- **Snowflake Query History**: Performance monitoring
- **AWS CloudWatch**: Infrastructure metrics
- **GitHub Actions Logs**: Pipeline execution history

## Interview Talking Points

### Technical Depth

- Implemented Data Vault 2.0 with 7 hubs, 6 links, and 7 satellites
- Built medallion architecture with bronze/silver/gold layers
- Created 10+ dbt models with comprehensive testing
- Configured Great Expectations with 20+ validation rules

### Business Value

- Enables 360-degree customer view across finance and CRM
- Provides historical tracking for audit and compliance
- Reduces data quality issues through automated validation
- Accelerates analytics with pre-aggregated gold layer

### DevOps & Automation

- Fully automated infrastructure provisioning with Terraform
- CI/CD pipeline with 8 workflow jobs
- Automated data quality gates
- Self-service documentation with dbt docs

### Scalability & Governance

- Cloud-native architecture scales with data volume
- Data Vault 2.0 enables agile schema evolution
- Role-based access control in Snowflake
- Comprehensive data lineage tracking

## Future Enhancements

- [ ] Add real-time streaming with Kafka/Kinesis
- [ ] Implement data masking for PII
- [ ] Add machine learning models for churn prediction
- [ ] Create Tableau/Power BI dashboards
- [ ] Implement data retention policies
- [ ] Add anomaly detection
- [ ] Create data catalog with metadata management
- [ ] Implement cost optimization recommendations

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests: `make test`
4. Run linters: `make lint`
5. Submit a pull request

## License

This project is created for portfolio and demonstration purposes.

## Contact

For questions or opportunities, please reach out via [your contact method].

---

**Built with ❤️ using modern data engineering best practices**
