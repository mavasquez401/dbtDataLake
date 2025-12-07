# Terraform Outputs

# S3 Outputs
output "s3_bucket_name" {
  description = "Name of the S3 data lake bucket"
  value       = aws_s3_bucket.data_lake.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 data lake bucket"
  value       = aws_s3_bucket.data_lake.arn
}

output "s3_bucket_region" {
  description = "Region of the S3 data lake bucket"
  value       = aws_s3_bucket.data_lake.region
}

# Glue Outputs
output "glue_catalog_database_name" {
  description = "Name of the Glue catalog database"
  value       = aws_glue_catalog_database.data_lake.name
}

output "glue_finance_crawler_name" {
  description = "Name of the finance Glue crawler"
  value       = aws_glue_crawler.finance_crawler.name
}

output "glue_operations_crawler_name" {
  description = "Name of the operations Glue crawler"
  value       = aws_glue_crawler.operations_crawler.name
}

output "glue_crm_crawler_name" {
  description = "Name of the CRM Glue crawler"
  value       = aws_glue_crawler.crm_crawler.name
}

# IAM Outputs
output "glue_crawler_role_arn" {
  description = "ARN of the Glue crawler IAM role"
  value       = aws_iam_role.glue_crawler_role.arn
}

output "snowflake_s3_role_arn" {
  description = "ARN of the Snowflake S3 access IAM role"
  value       = aws_iam_role.snowflake_s3_role.arn
}

# Snowflake Outputs
output "snowflake_warehouse_name" {
  description = "Name of the Snowflake warehouse"
  value       = snowflake_warehouse.data_lake_wh.name
}

output "snowflake_database_name" {
  description = "Name of the Snowflake database"
  value       = snowflake_database.data_lake_db.name
}

output "snowflake_raw_schema_name" {
  description = "Name of the Snowflake raw schema"
  value       = snowflake_schema.raw.name
}

output "snowflake_stage_schema_name" {
  description = "Name of the Snowflake stage schema"
  value       = snowflake_schema.stage.name
}

output "snowflake_bronze_schema_name" {
  description = "Name of the Snowflake bronze schema"
  value       = snowflake_schema.bronze.name
}

output "snowflake_silver_schema_name" {
  description = "Name of the Snowflake silver schema"
  value       = snowflake_schema.silver.name
}

output "snowflake_gold_schema_name" {
  description = "Name of the Snowflake gold schema"
  value       = snowflake_schema.gold.name
}

