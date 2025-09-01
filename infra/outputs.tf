# ML Edge Project - Output Values
# This file defines output values from the Terraform configuration

# S3 Bucket Outputs
output "s3_bucket_intents_raw" {
  description = "Name of the S3 bucket for raw intent data"
  value       = aws_s3_bucket.intents_raw.bucket
}

output "s3_bucket_intents_raw_arn" {
  description = "ARN of the S3 bucket for raw intent data"
  value       = aws_s3_bucket.intents_raw.arn
}

output "s3_bucket_intents_processed" {
  description = "Name of the S3 bucket for processed intent data"
  value       = aws_s3_bucket.intents_processed.bucket
}

output "s3_bucket_intents_processed_arn" {
  description = "ARN of the S3 bucket for processed intent data"
  value       = aws_s3_bucket.intents_processed.arn
}

output "s3_bucket_model_artifacts" {
  description = "Name of the S3 bucket for model artifacts"
  value       = aws_s3_bucket.model_artifacts.bucket
}

output "s3_bucket_model_artifacts_arn" {
  description = "ARN of the S3 bucket for model artifacts"
  value       = aws_s3_bucket.model_artifacts.arn
}

output "s3_bucket_edge_deployments" {
  description = "Name of the S3 bucket for edge deployments"
  value       = aws_s3_bucket.edge_deployments.bucket
}

output "s3_bucket_edge_deployments_arn" {
  description = "ARN of the S3 bucket for edge deployments"
  value       = aws_s3_bucket.edge_deployments.arn
}

output "s3_bucket_pipeline_artifacts" {
  description = "Name of the S3 bucket for pipeline artifacts"
  value       = aws_s3_bucket.pipeline_artifacts.bucket
}

output "s3_bucket_pipeline_artifacts_arn" {
  description = "ARN of the S3 bucket for pipeline artifacts"
  value       = aws_s3_bucket.pipeline_artifacts.arn
}

# IAM Role Outputs
output "sagemaker_execution_role_arn" {
  description = "ARN of the SageMaker execution role"
  value       = aws_iam_role.sagemaker_execution_role.arn
}

output "sagemaker_execution_role_name" {
  description = "Name of the SageMaker execution role"
  value       = aws_iam_role.sagemaker_execution_role.name
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "lambda_execution_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.name
}

# KMS Key Outputs
output "s3_encryption_key_arn" {
  description = "ARN of the KMS key used for S3 encryption"
  value       = var.enable_bucket_encryption ? aws_kms_key.s3_encryption[0].arn : null
}

output "s3_encryption_key_id" {
  description = "ID of the KMS key used for S3 encryption"
  value       = var.enable_bucket_encryption ? aws_kms_key.s3_encryption[0].key_id : null
}

output "s3_encryption_key_alias" {
  description = "Alias of the KMS key used for S3 encryption"
  value       = var.enable_bucket_encryption ? aws_kms_alias.s3_encryption[0].name : null
}

# CloudWatch Log Group Outputs
output "sagemaker_log_group_name" {
  description = "Name of the CloudWatch log group for SageMaker"
  value       = var.enable_detailed_monitoring ? aws_cloudwatch_log_group.sagemaker_logs[0].name : null
}

output "lambda_log_group_name" {
  description = "Name of the CloudWatch log group for Lambda"
  value       = var.enable_detailed_monitoring ? aws_cloudwatch_log_group.lambda_logs[0].name : null
}

# Project Configuration Outputs
output "project_name" {
  description = "Name of the ML Edge project"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "name_prefix" {
  description = "Common name prefix used for all resources"
  value       = local.name_prefix
}

# Resource Summary Outputs
output "bucket_names" {
  description = "List of all S3 bucket names created"
  value = [
    aws_s3_bucket.intents_raw.bucket,
    aws_s3_bucket.intents_processed.bucket,
    aws_s3_bucket.model_artifacts.bucket,
    aws_s3_bucket.edge_deployments.bucket,
    aws_s3_bucket.pipeline_artifacts.bucket
  ]
}

output "bucket_arns" {
  description = "List of all S3 bucket ARNs created"
  value = [
    aws_s3_bucket.intents_raw.arn,
    aws_s3_bucket.intents_processed.arn,
    aws_s3_bucket.model_artifacts.arn,
    aws_s3_bucket.edge_deployments.arn,
    aws_s3_bucket.pipeline_artifacts.arn
  ]
}

output "iam_role_arns" {
  description = "List of all IAM role ARNs created"
  value = [
    aws_iam_role.sagemaker_execution_role.arn,
    aws_iam_role.lambda_execution_role.arn
  ]
}

# Configuration Summary for Other Tools
output "ml_pipeline_config" {
  description = "Configuration values for ML pipeline tools"
  value = {
    s3_buckets = {
      raw_data       = aws_s3_bucket.intents_raw.bucket
      processed_data = aws_s3_bucket.intents_processed.bucket
      model_artifacts = aws_s3_bucket.model_artifacts.bucket
      edge_deployments = aws_s3_bucket.edge_deployments.bucket
      pipeline_artifacts = aws_s3_bucket.pipeline_artifacts.bucket
    }
    iam_roles = {
      sagemaker_execution = aws_iam_role.sagemaker_execution_role.arn
      lambda_execution    = aws_iam_role.lambda_execution_role.arn
    }
    encryption = {
      kms_key_arn = var.enable_bucket_encryption ? aws_kms_key.s3_encryption[0].arn : null
      enabled     = var.enable_bucket_encryption
    }
    logging = {
      sagemaker_log_group = var.enable_detailed_monitoring ? aws_cloudwatch_log_group.sagemaker_logs[0].name : null
      lambda_log_group    = var.enable_detailed_monitoring ? aws_cloudwatch_log_group.lambda_logs[0].name : null
      retention_days      = var.log_retention_days
    }
    project = {
      name        = var.project_name
      environment = var.environment
      region      = var.aws_region
      name_prefix = local.name_prefix
    }
  }
  sensitive = false
}

# =============================================================================
# AWS SSO (IAM Identity Center) Outputs
# =============================================================================

output "sso_instance_arn" {
  description = "ARN of the AWS SSO instance"
  value       = var.enable_sso_permission_sets ? data.aws_ssoadmin_instances.main.arns[0] : null
}

output "sso_permission_set_arn" {
  description = "ARN of the ML Edge Developers SSO permission set"
  value       = var.enable_sso_permission_sets ? aws_ssoadmin_permission_set.ml_edge_developers[0].arn : null
}

output "sso_permission_set_name" {
  description = "Name of the ML Edge Developers SSO permission set"
  value       = var.enable_sso_permission_sets ? aws_ssoadmin_permission_set.ml_edge_developers[0].name : null
}

output "sso_start_url" {
  description = "AWS SSO start URL for user login (retrieve manually from console)"
  value       = "https://d-xxxxxxxxxx.awsapps.com/start (Configure in AWS Console)"
}

output "sso_onboarding_instructions" {
  description = "Instructions for setting up SSO access"
  value = <<-EOT
    SSO Setup Instructions:
    
    1. Administrator: Enable IAM Identity Center in AWS Console
    2. Administrator: Configure identity source and assign users
    3. Developer setup:
       aws configure sso
       # SSO start URL: [Get from AWS Console]
       # SSO region: ${var.aws_region}
       # Account: ${data.aws_caller_identity.current.account_id}
       # Role: MLEdgeDevelopers
       
    4. Login:
       aws sso login --profile my-dev-profile
       
    5. Use:
       aws sts get-caller-identity --profile my-dev-profile
  EOT
}
