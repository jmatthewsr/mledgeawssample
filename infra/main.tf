# ML Edge Project - Main Terraform Configuration
# This file defines the core infrastructure for the ML Edge project

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      CreatedBy   = "terraform"
      ManagedBy   = "terraform"
    }
  }
}

# Data source for current AWS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Random suffix for unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Local values for computed names and common tags
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  
  # Unique bucket suffix to avoid naming conflicts
  bucket_suffix = lower(random_id.bucket_suffix.hex)
  
  # Common resource naming
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    CreatedBy   = "terraform"
    ManagedBy   = "terraform"
    Region      = local.region
    AccountId   = local.account_id
  }
}
