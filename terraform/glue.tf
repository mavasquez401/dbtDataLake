# AWS Glue Configuration for Data Catalog

# Glue Catalog Database
resource "aws_glue_catalog_database" "data_lake" {
  name        = "${var.project_name}_catalog"
  description = "Data catalog for institutional data lake"

  tags = var.tags
}

# Glue Crawler for Finance data
resource "aws_glue_crawler" "finance_crawler" {
  name          = "${var.project_name}-finance-crawler"
  role          = aws_iam_role.glue_crawler_role.arn
  database_name = aws_glue_catalog_database.data_lake.name
  description   = "Crawler for finance domain data"

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.id}/finance/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
    CrawlerOutput = {
      Partitions = {
        AddOrUpdateBehavior = "InheritFromTable"
      }
    }
  })

  schedule = var.glue_crawler_schedule

  tags = merge(
    var.tags,
    {
      Name   = "${var.project_name}-finance-crawler"
      Domain = "finance"
    }
  )
}

# Glue Crawler for Operations data
resource "aws_glue_crawler" "operations_crawler" {
  name          = "${var.project_name}-operations-crawler"
  role          = aws_iam_role.glue_crawler_role.arn
  database_name = aws_glue_catalog_database.data_lake.name
  description   = "Crawler for operations domain data"

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.id}/operations/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
    CrawlerOutput = {
      Partitions = {
        AddOrUpdateBehavior = "InheritFromTable"
      }
    }
  })

  schedule = var.glue_crawler_schedule

  tags = merge(
    var.tags,
    {
      Name   = "${var.project_name}-operations-crawler"
      Domain = "operations"
    }
  )
}

# Glue Crawler for CRM data
resource "aws_glue_crawler" "crm_crawler" {
  name          = "${var.project_name}-crm-crawler"
  role          = aws_iam_role.glue_crawler_role.arn
  database_name = aws_glue_catalog_database.data_lake.name
  description   = "Crawler for CRM domain data"

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.id}/crm/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
    CrawlerOutput = {
      Partitions = {
        AddOrUpdateBehavior = "InheritFromTable"
      }
    }
  })

  schedule = var.glue_crawler_schedule

  tags = merge(
    var.tags,
    {
      Name   = "${var.project_name}-crm-crawler"
      Domain = "crm"
    }
  )
}

