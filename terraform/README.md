# Terraform Infrastructure

This directory contains Terraform configurations for provisioning the data lake infrastructure.

## Prerequisites

1. Install Terraform (>= 1.0)
2. Configure AWS credentials
3. Configure Snowflake credentials

## AWS Configuration

Set up AWS credentials using one of these methods:

```bash
# Option 1: Environment variables
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_DEFAULT_REGION="us-east-1"

# Option 2: AWS CLI configuration
aws configure
```

## Snowflake Configuration

Set up Snowflake credentials:

```bash
export SNOWFLAKE_ACCOUNT="your_account.region"
export SNOWFLAKE_USER="your_username"
export SNOWFLAKE_PASSWORD="your_password"
export SNOWFLAKE_ROLE="ACCOUNTADMIN"
```

## Usage

### Initialize Terraform

```bash
terraform init
```

### Plan Changes

```bash
terraform plan
```

### Apply Changes

```bash
terraform apply
```

### Destroy Resources

```bash
terraform destroy
```

## Resources Created

### AWS Resources

- **S3 Bucket**: Data lake storage with versioning and encryption
- **Glue Catalog Database**: Metadata catalog
- **Glue Crawlers**: Three crawlers for finance, operations, and CRM data
- **IAM Roles**: Roles for Glue crawlers and Snowflake S3 access

### Snowflake Resources

- **Warehouse**: XSMALL warehouse with auto-suspend
- **Database**: DATA_LAKE database
- **Schemas**: RAW, STAGE, BRONZE, SILVER, GOLD
- **Roles**: DATA_ENGINEER and ANALYST roles with appropriate permissions

## Variables

Key variables can be customized in `terraform.tfvars`:

```hcl
aws_region              = "us-east-1"
project_name            = "institutional-data-lake"
environment             = "dev"
s3_bucket_name          = "your-bucket-name"
glue_crawler_schedule   = "cron(0 2 * * ? *)"
```

## Outputs

After applying, Terraform will output:

- S3 bucket name and ARN
- Glue catalog database and crawler names
- IAM role ARNs
- Snowflake warehouse, database, and schema names

## State Management

For production use, configure remote state backend in `provider.tf`:

```hcl
backend "s3" {
  bucket         = "terraform-state-bucket"
  key            = "data-lake/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

