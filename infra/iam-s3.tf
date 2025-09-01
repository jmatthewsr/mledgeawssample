# ML Edge Project - S3 IAM Configuration
# This file defines IAM policies specifically for S3 bucket access

# Custom policy for S3 access to our specific buckets
data "aws_iam_policy_document" "sagemaker_s3_policy" {
  # S3 bucket access for all our project buckets
  statement {
    effect = "Allow"
    
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectVersion",
      "s3:PutObjectAcl",
      "s3:GetObjectAcl"
    ]
    
    resources = [
      "${aws_s3_bucket.intents_raw.arn}/*",
      "${aws_s3_bucket.intents_processed.arn}/*",
      "${aws_s3_bucket.model_artifacts.arn}/*",
      "${aws_s3_bucket.edge_deployments.arn}/*",
      "${aws_s3_bucket.pipeline_artifacts.arn}/*"
    ]
  }
  
  # S3 bucket listing permissions
  statement {
    effect = "Allow"
    
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:ListBucketVersions"
    ]
    
    resources = [
      aws_s3_bucket.intents_raw.arn,
      aws_s3_bucket.intents_processed.arn,
      aws_s3_bucket.model_artifacts.arn,
      aws_s3_bucket.edge_deployments.arn,
      aws_s3_bucket.pipeline_artifacts.arn
    ]
  }
  
  # KMS permissions for S3 encryption
  dynamic "statement" {
    for_each = var.enable_bucket_encryption ? [1] : []
    
    content {
      effect = "Allow"
      
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey",
        "kms:ReEncrypt*"
      ]
      
      resources = [aws_kms_key.s3_encryption[0].arn]
    }
  }
}

# Create the custom S3 policy
resource "aws_iam_policy" "sagemaker_s3_policy" {
  name        = "${local.name_prefix}-sagemaker-s3-access"
  description = "Custom S3 access policy for SageMaker execution role"
  policy      = data.aws_iam_policy_document.sagemaker_s3_policy.json
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-sagemaker-s3-policy"
    Purpose     = "SageMaker S3 access permissions"
    Service     = "IAM"
  })
}

# Data source for development team S3 access policy
data "aws_iam_policy_document" "dev_team_s3_policy" {
  statement {
    effect = "Allow"
    
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning"
    ]
    
    resources = [
      aws_s3_bucket.intents_raw.arn,
      "${aws_s3_bucket.intents_raw.arn}/*",
      aws_s3_bucket.intents_processed.arn,
      "${aws_s3_bucket.intents_processed.arn}/*",
      aws_s3_bucket.model_artifacts.arn,
      "${aws_s3_bucket.model_artifacts.arn}/*",
      aws_s3_bucket.pipeline_artifacts.arn,
      "${aws_s3_bucket.pipeline_artifacts.arn}/*",
      aws_s3_bucket.edge_deployments.arn,
      "${aws_s3_bucket.edge_deployments.arn}/*"
    ]
  }
  
  # KMS access for development team
  dynamic "statement" {
    for_each = var.enable_bucket_encryption ? [1] : []
    
    content {
      effect = "Allow"
      
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey",
        "kms:ReEncrypt*"
      ]
      
      resources = [aws_kms_key.s3_encryption[0].arn]
    }
  }
}

# S3 policy for development team
resource "aws_iam_policy" "dev_team_s3_policy" {
  name        = "${local.name_prefix}-dev-team-s3-access"
  description = "S3 access policy for development team"
  policy      = data.aws_iam_policy_document.dev_team_s3_policy.json
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-dev-team-s3-policy"
    Purpose     = "Development team S3 access permissions"
    Service     = "IAM"
  })
}
