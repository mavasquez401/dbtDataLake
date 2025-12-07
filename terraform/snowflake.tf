# Snowflake Resources Configuration

# Snowflake Warehouse
resource "snowflake_warehouse" "data_lake_wh" {
  name           = "DATA_LAKE_WH"
  warehouse_size = "XSMALL"
  auto_suspend   = 60
  auto_resume    = true
  comment        = "Warehouse for data lake transformations"

  warehouse_type = "STANDARD"
}

# Snowflake Database
resource "snowflake_database" "data_lake_db" {
  name    = "DATA_LAKE"
  comment = "Institutional data lake database"
}

# Schema for raw/stage layer
resource "snowflake_schema" "raw" {
  database = snowflake_database.data_lake_db.name
  name     = "RAW"
  comment  = "Raw data layer - external stages"
}

resource "snowflake_schema" "stage" {
  database = snowflake_database.data_lake_db.name
  name     = "STAGE"
  comment  = "Stage layer - Data Vault 2.0 structures"
}

# Schema for bronze layer (dbt)
resource "snowflake_schema" "bronze" {
  database = snowflake_database.data_lake_db.name
  name     = "BRONZE"
  comment  = "Bronze layer - raw ingestion"
}

# Schema for silver layer (dbt)
resource "snowflake_schema" "silver" {
  database = snowflake_database.data_lake_db.name
  name     = "SILVER"
  comment  = "Silver layer - cleansed and conformed"
}

# Schema for gold layer (dbt)
resource "snowflake_schema" "gold" {
  database = snowflake_database.data_lake_db.name
  name     = "GOLD"
  comment  = "Gold layer - business-ready aggregates"
}

# Role for data engineers
resource "snowflake_role" "data_engineer" {
  name    = "DATA_ENGINEER"
  comment = "Role for data engineers with full access"
}

# Role for analysts
resource "snowflake_role" "analyst" {
  name    = "ANALYST"
  comment = "Role for analysts with read-only access"
}

# Grant warehouse usage to data engineer role
resource "snowflake_warehouse_grant" "data_engineer_wh_grant" {
  warehouse_name = snowflake_warehouse.data_lake_wh.name
  privilege      = "USAGE"
  roles          = [snowflake_role.data_engineer.name]
}

# Grant database usage to data engineer role
resource "snowflake_database_grant" "data_engineer_db_grant" {
  database_name = snowflake_database.data_lake_db.name
  privilege     = "USAGE"
  roles         = [snowflake_role.data_engineer.name]
}

# Grant schema privileges to data engineer role
resource "snowflake_schema_grant" "data_engineer_schema_grants" {
  for_each = toset([
    snowflake_schema.raw.name,
    snowflake_schema.stage.name,
    snowflake_schema.bronze.name,
    snowflake_schema.silver.name,
    snowflake_schema.gold.name
  ])

  database_name = snowflake_database.data_lake_db.name
  schema_name   = each.value
  privilege     = "ALL"
  roles         = [snowflake_role.data_engineer.name]
}

# Grant read-only access to analyst role
resource "snowflake_database_grant" "analyst_db_grant" {
  database_name = snowflake_database.data_lake_db.name
  privilege     = "USAGE"
  roles         = [snowflake_role.analyst.name]
}

resource "snowflake_schema_grant" "analyst_schema_grants" {
  for_each = toset([
    snowflake_schema.silver.name,
    snowflake_schema.gold.name
  ])

  database_name = snowflake_database.data_lake_db.name
  schema_name   = each.value
  privilege     = "USAGE"
  roles         = [snowflake_role.analyst.name]
}

