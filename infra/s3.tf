# ML Edge Project - S3 Bucket Configuration
# This file defines S3 buckets for data storage and model artifacts
# Security configurations are in s3-security.tf
# KMS encryption keys are in kms.tf
# Random bucket suffix is defined in main.tf

# S3 bucket for raw intent data
resource "aws_s3_bucket" "intents_raw" {
  bucket = "${var.project_name}-intents-raw-${var.environment}-${local.bucket_suffix}"

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-intents-raw"
    Purpose     = "Raw intent data storage"
    DataType    = "raw"
    Service     = "S3"
  })
}

# S3 bucket for processed intent data
resource "aws_s3_bucket" "intents_processed" {
  bucket = "${var.project_name}-intents-processed-${var.environment}-${local.bucket_suffix}"

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-intents-processed"
    Purpose     = "Processed intent data storage"
    DataType    = "processed"
    Service     = "S3"
  })
}

# S3 bucket for model artifacts
resource "aws_s3_bucket" "model_artifacts" {
  bucket = "${var.project_name}-model-artifacts-${var.environment}-${local.bucket_suffix}"

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-model-artifacts"
    Purpose     = "Model artifacts and checkpoints storage"
    DataType    = "models"
    Service     = "S3"
  })
}

# S3 bucket for edge deployments
resource "aws_s3_bucket" "edge_deployments" {
  bucket = "${var.project_name}-edge-deployments-${var.environment}-${local.bucket_suffix}"

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-edge-deployments"
    Purpose     = "Edge deployment packages storage"
    DataType    = "deployments"
    Service     = "S3"
  })
}

# S3 bucket for pipeline artifacts
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "${var.project_name}-pipeline-artifacts-${var.environment}-${local.bucket_suffix}"

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-pipeline-artifacts"
    Purpose     = "ML pipeline artifacts and logs"
    DataType    = "pipeline"
    Service     = "S3"
  })
}

# S3 bucket lifecycle configuration (cost optimization - not security)
resource "aws_s3_bucket_lifecycle_configuration" "intents_raw" {
  bucket = aws_s3_bucket.intents_raw.id

  rule {
    id     = "intents_raw_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = var.s3_lifecycle_days_to_ia
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.s3_lifecycle_days_to_glacier
      storage_class = "GLACIER"
    }

    transition {
      days          = var.s3_lifecycle_days_to_deep_archive
      storage_class = "DEEP_ARCHIVE"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "intents_processed" {
  bucket = aws_s3_bucket.intents_processed.id

  rule {
    id     = "intents_processed_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = var.s3_lifecycle_days_to_ia
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.s3_lifecycle_days_to_glacier
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "model_artifacts" {
  bucket = aws_s3_bucket.model_artifacts.id

  rule {
    id     = "model_artifacts_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = var.s3_lifecycle_days_to_ia
      storage_class = "STANDARD_IA"
    }

    # Keep model artifacts accessible, so only transition to IA
    # Don't move to Glacier to ensure quick access for deployments

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 180  # Keep model versions longer
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "edge_deployments" {
  bucket = aws_s3_bucket.edge_deployments.id

  rule {
    id     = "edge_deployments_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = var.s3_lifecycle_days_to_ia
      storage_class = "STANDARD_IA"
    }

    # Keep deployment packages accessible
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  rule {
    id     = "pipeline_artifacts_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = var.s3_lifecycle_days_to_ia
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.s3_lifecycle_days_to_glacier
      storage_class = "GLACIER"
    }

    # Pipeline artifacts can be archived aggressively
    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
