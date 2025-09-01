# ML Edge Project - KMS Configuration
# This file defines KMS keys and aliases for encryption across all services

# KMS key for S3 bucket encryption
resource "aws_kms_key" "s3_encryption" {
  count = var.enable_bucket_encryption ? 1 : 0
  
  description             = "KMS key for S3 bucket encryption - ${var.project_name}"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-s3-encryption-key"
    Purpose     = "S3 bucket encryption"
    Service     = "KMS"
  })
}

# KMS key alias for S3 encryption
resource "aws_kms_alias" "s3_encryption" {
  count = var.enable_bucket_encryption ? 1 : 0
  
  name          = "alias/${local.name_prefix}-s3-encryption"
  target_key_id = aws_kms_key.s3_encryption[0].key_id
}

# Future KMS keys can be added here:
# - SageMaker encryption key
# - Lambda environment variable encryption
# - EBS volume encryption
# - RDS encryption (if database is added)
