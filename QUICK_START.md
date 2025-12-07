# Quick Start Guide

Get up and running with the Institutional Data Lake platform in minutes.

## Prerequisites Checklist

- [ ] Python 3.11+ installed
- [ ] AWS account with credentials
- [ ] Snowflake account with credentials
- [ ] Git installed
- [ ] (Optional) Terraform 1.0+ for infrastructure deployment

## 5-Minute Setup

### 1. Clone and Install (2 minutes)

```bash
# Navigate to project
cd /Users/manny/Documents/Coding/JobSearch/dbtDataLake

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Configure Credentials (1 minute)

Create a `.env` file in the project root:

```bash
# AWS Configuration
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_DEFAULT_REGION=us-east-1
S3_BUCKET_NAME=your-bucket-name

# Snowflake Configuration
SNOWFLAKE_ACCOUNT=your_account.region
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_ROLE=ACCOUNTADMIN
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
```

### 3. Generate Sample Data (2 minutes)

```bash
# Generate sample datasets
python scripts/generate_sample_data.py

# This creates:
# - Finance data (accounts, transactions, ledger)
# - Operations data (orders, shipments, inventory)
# - CRM data (customers, interactions, opportunities)
```

## Common Commands

### Data Generation & Upload

```bash
# Generate fresh sample data
make generate-data

# Upload to S3
make upload-data
```

### Infrastructure Deployment

```bash
# Deploy with Terraform
cd terraform
terraform init
terraform plan
terraform apply

# Or use Makefile
make terraform-init
make terraform-apply
```

### Snowflake Setup

```bash
# Create Data Vault schema
python scripts/setup_snowflake.py
```

### dbt Operations

```bash
cd dbt_project

# Install dbt packages
dbt deps

# Run all models
dbt run

# Run specific layer
dbt run --select bronze.*
dbt run --select silver.*
dbt run --select gold.*

# Run tests
dbt test

# Generate and view documentation
dbt docs generate
dbt docs serve
```

### Data Quality

```bash
# Run all data quality checks
python scripts/run_data_quality.py

# Or use Makefile
make quality
```

### Code Quality

```bash
# Format Python code
make format

# Run linters
make lint

# Run tests
make test
```

## Project Structure at a Glance

```
dbtDataLake/
├── scripts/              # Python utilities
├── terraform/            # Infrastructure as Code
├── snowflake/ddl/        # Data Vault DDL scripts
├── dbt_project/          # dbt transformations
│   ├── models/bronze/    # Raw data layer
│   ├── models/silver/    # Cleansed layer
│   └── models/gold/      # Business layer
├── data_quality/         # Great Expectations
├── docs/                 # Documentation
└── .github/workflows/    # CI/CD pipelines
```

## Troubleshooting

### Issue: Python dependencies fail to install
**Solution**: Ensure you're using Python 3.11+
```bash
python --version
```

### Issue: AWS credentials not found
**Solution**: Verify .env file or set environment variables
```bash
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
```

### Issue: Snowflake connection fails
**Solution**: Check credentials and network access
```bash
# Test connection
python -c "import snowflake.connector; print('OK')"
```

### Issue: dbt models fail
**Solution**: Ensure Snowflake schema exists
```bash
python scripts/setup_snowflake.py
```

## Demo Preparation

### For a Quick Demo (5 minutes)

1. **Show Architecture**: Open `README.md` and scroll to architecture section
2. **Show Code**: Open `dbt_project/models/gold/gold_customer_summary.sql`
3. **Show Tests**: Open `dbt_project/models/gold/schema.yml`
4. **Show CI/CD**: Open `.github/workflows/ci_cd.yml`
5. **Show Queries**: Open `docs/sample_queries.sql`

### For a Full Demo (15 minutes)

Follow the guide in `docs/demo_walkthrough.md`

## Key Files to Review

| File | Purpose |
|------|---------|
| `README.md` | Comprehensive project overview |
| `PROJECT_SUMMARY.md` | Complete deliverables checklist |
| `docs/demo_walkthrough.md` | Step-by-step demo script |
| `docs/presentation_outline.md` | Interview presentation |
| `docs/sample_queries.sql` | 20 example queries |
| `docs/data_vault_design.md` | Data Vault 2.0 explanation |

## Next Steps

1. ✅ Review `README.md` for full documentation
2. ✅ Generate sample data
3. ✅ Deploy infrastructure (if using real AWS/Snowflake)
4. ✅ Run dbt transformations
5. ✅ Review `docs/demo_walkthrough.md` for interview prep
6. ✅ Practice with `docs/sample_queries.sql`

## Getting Help

- **Architecture Questions**: See `README.md` and `docs/data_vault_design.md`
- **Demo Preparation**: See `docs/demo_walkthrough.md`
- **Technical Details**: See inline code comments
- **CI/CD**: See `.github/workflows/` directory

## Interview Talking Points (30 seconds)

> "I built an enterprise data lake platform that ingests data from Finance, Operations, and CRM into AWS S3, catalogs it with Glue, and loads it into Snowflake. I implemented Data Vault 2.0 for historical tracking and a medallion architecture with bronze, silver, and gold layers for data quality. The entire platform is automated with Terraform for infrastructure and GitHub Actions for CI/CD, with comprehensive testing using dbt and Great Expectations. It demonstrates end-to-end data engineering from raw data ingestion to business-ready analytics."

---

**You're ready to demonstrate a production-grade data lake platform!** 🚀

