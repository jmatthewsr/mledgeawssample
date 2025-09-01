# ML Edge Project - S3 Security Configuration
# This file defines security configurations for S3 buckets including:
# - Versioning (data protection)
# - Server-side encryption
# - Public access blocking

# =============================================================================
# S3 BUCKET VERSIONING (Data Protection)
# =============================================================================

resource "aws_s3_bucket_versioning" "intents_raw" {
  bucket = aws_s3_bucket.intents_raw.id
  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_versioning" "intents_processed" {
  bucket = aws_s3_bucket.intents_processed.id
  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_versioning" "model_artifacts" {
  bucket = aws_s3_bucket.model_artifacts.id
  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_versioning" "edge_deployments" {
  bucket = aws_s3_bucket.edge_deployments.id
  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_versioning" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Disabled"
  }
}

# =============================================================================
# S3 BUCKET SERVER-SIDE ENCRYPTION
# =============================================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "intents_raw" {
  count = var.enable_bucket_encryption ? 1 : 0
  
  bucket = aws_s3_bucket.intents_raw.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_encryption[0].arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "intents_processed" {
  count = var.enable_bucket_encryption ? 1 : 0
  
  bucket = aws_s3_bucket.intents_processed.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_encryption[0].arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "model_artifacts" {
  count = var.enable_bucket_encryption ? 1 : 0
  
  bucket = aws_s3_bucket.model_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_encryption[0].arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "edge_deployments" {
  count = var.enable_bucket_encryption ? 1 : 0
  
  bucket = aws_s3_bucket.edge_deployments.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_encryption[0].arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_artifacts" {
  count = var.enable_bucket_encryption ? 1 : 0
  
  bucket = aws_s3_bucket.pipeline_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_encryption[0].arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# =============================================================================
# S3 BUCKET PUBLIC ACCESS BLOCKING (Security)
# =============================================================================

resource "aws_s3_bucket_public_access_block" "intents_raw" {
  bucket = aws_s3_bucket.intents_raw.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "intents_processed" {
  bucket = aws_s3_bucket.intents_processed.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "model_artifacts" {
  bucket = aws_s3_bucket.model_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "edge_deployments" {
  bucket = aws_s3_bucket.edge_deployments.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
