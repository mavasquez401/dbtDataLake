# Terraform Provider Configuration

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.94"
    }
  }

  # Backend configuration for state management
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket         = "terraform-state-bucket"
  #   key            = "data-lake/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

provider "snowflake" {
  # Configure via environment variables:
  # SNOWFLAKE_ACCOUNT
  # SNOWFLAKE_USER
  # SNOWFLAKE_PASSWORD
  # SNOWFLAKE_ROLE
}

