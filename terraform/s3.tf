# S3 Bucket Configuration for Data Lake

# Main data lake bucket
resource "aws_s3_bucket" "data_lake" {
  bucket = var.s3_bucket_name

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-bucket"
      Description = "Main data lake storage bucket"
    }
  )
}

# Enable versioning for data protection
resource "aws_s3_bucket_versioning" "data_lake" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.data_lake.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = var.lifecycle_transition_days
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_transition_days
      storage_class   = "GLACIER"
    }
  }

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_expiration_days
    }
  }
}

# Create folder structure using S3 objects
resource "aws_s3_object" "finance_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "finance/"
  content = ""
}

resource "aws_s3_object" "finance_accounts_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "finance/accounts/"
  content = ""
}

resource "aws_s3_object" "finance_transactions_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "finance/transactions/"
  content = ""
}

resource "aws_s3_object" "finance_ledger_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "finance/ledger/"
  content = ""
}

resource "aws_s3_object" "operations_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "operations/"
  content = ""
}

resource "aws_s3_object" "operations_orders_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "operations/orders/"
  content = ""
}

resource "aws_s3_object" "operations_shipments_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "operations/shipments/"
  content = ""
}

resource "aws_s3_object" "operations_inventory_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "operations/inventory/"
  content = ""
}

resource "aws_s3_object" "crm_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "crm/"
  content = ""
}

resource "aws_s3_object" "crm_customers_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "crm/customers/"
  content = ""
}

resource "aws_s3_object" "crm_interactions_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "crm/interactions/"
  content = ""
}

resource "aws_s3_object" "crm_opportunities_folder" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "crm/opportunities/"
  content = ""
}

