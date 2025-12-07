-- External Stages for S3 Data Access
-- These stages connect Snowflake to S3 data lake

USE DATABASE DATA_LAKE;
USE SCHEMA RAW;

-- Storage integration for S3 access
CREATE OR REPLACE STORAGE INTEGRATION s3_data_lake_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::ACCOUNT_ID:role/institutional-data-lake-snowflake-s3-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://institutional-data-lake/');

-- External stage for Finance data
CREATE OR REPLACE STAGE finance_stage
  STORAGE_INTEGRATION = s3_data_lake_integration
  URL = 's3://institutional-data-lake/finance/'
  FILE_FORMAT = (
    TYPE = PARQUET
    COMPRESSION = AUTO
  )
  COMMENT = 'External stage for finance domain data';

-- External stage for Operations data
CREATE OR REPLACE STAGE operations_stage
  STORAGE_INTEGRATION = s3_data_lake_integration
  URL = 's3://institutional-data-lake/operations/'
  FILE_FORMAT = (
    TYPE = PARQUET
    COMPRESSION = AUTO
  )
  COMMENT = 'External stage for operations domain data';

-- External stage for CRM data
CREATE OR REPLACE STAGE crm_stage
  STORAGE_INTEGRATION = s3_data_lake_integration
  URL = 's3://institutional-data-lake/crm/'
  FILE_FORMAT = (
    TYPE = PARQUET
    COMPRESSION = AUTO
  )
  COMMENT = 'External stage for CRM domain data';

-- List files in stages to verify connectivity
LIST @finance_stage;
LIST @operations_stage;
LIST @crm_stage;

