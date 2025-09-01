# ML Edge Project - SageMaker IAM Configuration
# This file defines IAM roles and policies specifically for SageMaker services

# Data source for SageMaker service principal
data "aws_iam_policy_document" "sagemaker_assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

# SageMaker execution role
resource "aws_iam_role" "sagemaker_execution_role" {
  name = "${local.name_prefix}-${var.sagemaker_execution_role_name}"
  
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role.json
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-sagemaker-execution-role"
    Purpose     = "SageMaker pipeline execution"
    Service     = "SageMaker"
  })
}

# Custom policy for CloudWatch logs
data "aws_iam_policy_document" "sagemaker_logs_policy" {
  statement {
    effect = "Allow"
    
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    
    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/sagemaker/*",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:${local.name_prefix}*"
    ]
  }
}

resource "aws_iam_policy" "sagemaker_logs_policy" {
  name        = "${local.name_prefix}-sagemaker-logs-access"
  description = "CloudWatch logs access policy for SageMaker"
  policy      = data.aws_iam_policy_document.sagemaker_logs_policy.json
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-sagemaker-logs-policy"
    Purpose     = "SageMaker CloudWatch logs access"
    Service     = "IAM"
  })
}

# Custom policy for ECR access (for custom containers)
data "aws_iam_policy_document" "sagemaker_ecr_policy" {
  statement {
    effect = "Allow"
    
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetAuthorizationToken"
    ]
    
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sagemaker_ecr_policy" {
  name        = "${local.name_prefix}-sagemaker-ecr-access"
  description = "ECR access policy for SageMaker custom containers"
  policy      = data.aws_iam_policy_document.sagemaker_ecr_policy.json
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-sagemaker-ecr-policy"
    Purpose     = "SageMaker ECR access for custom containers"
    Service     = "IAM"
  })
}

# Policy attachments for SageMaker role
resource "aws_iam_role_policy_attachment" "sagemaker_execution_policy" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_s3_policy" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_logs_policy" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_ecr_policy" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_ecr_policy.arn
}

# CloudWatch log group for SageMaker
resource "aws_cloudwatch_log_group" "sagemaker_logs" {
  count = var.enable_detailed_monitoring ? 1 : 0
  
  name              = "/aws/sagemaker/${local.name_prefix}"
  retention_in_days = var.log_retention_days
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-sagemaker-logs"
    Purpose     = "SageMaker execution logs"
    Service     = "CloudWatch"
  })
}
