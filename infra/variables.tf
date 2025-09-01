# ML Edge Project - Variable Definitions
# This file defines all input variables for the Terraform configuration

variable "aws_region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be in the format like 'us-east-1'."
  }
}

variable "project_name" {
  description = "Name of the ML Edge project"
  type        = string
  default     = "slm-edge"
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_name))
    error_message = "Project name must start with a letter, contain only lowercase letters, numbers, and hyphens, and end with a letter or number."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "ml-team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "ML-Research"
}

# S3 Configuration Variables
variable "enable_s3_versioning" {
  description = "Enable versioning for S3 buckets"
  type        = bool
  default     = true
}

variable "s3_lifecycle_days_to_ia" {
  description = "Number of days after which objects transition to IA storage class"
  type        = number
  default     = 30
  
  validation {
    condition     = var.s3_lifecycle_days_to_ia >= 1
    error_message = "Days to IA transition must be at least 1."
  }
}

variable "s3_lifecycle_days_to_glacier" {
  description = "Number of days after which objects transition to Glacier storage class"
  type        = number
  default     = 90
  
  validation {
    condition     = var.s3_lifecycle_days_to_glacier >= var.s3_lifecycle_days_to_ia
    error_message = "Days to Glacier transition must be greater than or equal to days to IA transition."
  }
}

variable "s3_lifecycle_days_to_deep_archive" {
  description = "Number of days after which objects transition to Deep Archive storage class"
  type        = number
  default     = 365
  
  validation {
    condition     = var.s3_lifecycle_days_to_deep_archive >= var.s3_lifecycle_days_to_glacier
    error_message = "Days to Deep Archive transition must be greater than or equal to days to Glacier transition."
  }
}

# IAM Configuration Variables
variable "sagemaker_execution_role_name" {
  description = "Name for the SageMaker execution role"
  type        = string
  default     = "sagemaker-execution-role"
}

variable "enable_cloudtrail_logging" {
  description = "Enable CloudTrail logging for audit trail"
  type        = bool
  default     = true
}

# Security Configuration Variables
variable "enable_bucket_encryption" {
  description = "Enable server-side encryption for S3 buckets"
  type        = bool
  default     = true
}

variable "kms_key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 7
  
  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

# Network Configuration Variables (for future VPC setup)
variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for S3 and SageMaker"
  type        = bool
  default     = false
}

# Monitoring and Logging Variables
variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring and logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
  
  validation {
    condition = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

# =============================================================================
# AWS SSO (IAM Identity Center) Variables
# =============================================================================

variable "enable_sso_permission_sets" {
  description = "Whether to create SSO permission sets for modern authentication"
  type        = bool
  default     = true
}

variable "sso_session_duration" {
  description = "Session duration for SSO permission sets (ISO 8601 format)"
  type        = string
  default     = "PT8H"  # 8 hours
  
  validation {
    condition     = can(regex("^PT[0-9]+H$", var.sso_session_duration))
    error_message = "Session duration must be in ISO 8601 format like 'PT8H' for 8 hours."
  }
}

variable "sso_manage_account_assignments" {
  description = "Whether Terraform should manage SSO account assignments (users/groups)"
  type        = bool
  default     = false
}
