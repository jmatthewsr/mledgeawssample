# ML Edge Project - Lambda IAM Configuration
# This file defines IAM roles and policies specifically for Lambda functions

# IAM role for Lambda functions (for future pipeline orchestration)
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.name_prefix}-lambda-execution-role"
  
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-lambda-execution-role"
    Purpose     = "Lambda function execution for ML pipeline"
    Service     = "Lambda"
  })
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for Lambda to interact with SageMaker
data "aws_iam_policy_document" "lambda_sagemaker_policy" {
  statement {
    effect = "Allow"
    
    actions = [
      "sagemaker:CreateTrainingJob",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:StopTrainingJob",
      "sagemaker:CreateProcessingJob",
      "sagemaker:DescribeProcessingJob",
      "sagemaker:StopProcessingJob",
      "sagemaker:CreateModel",
      "sagemaker:DescribeModel",
      "sagemaker:DeleteModel",
      "sagemaker:CreateEndpoint",
      "sagemaker:DescribeEndpoint",
      "sagemaker:UpdateEndpoint",
      "sagemaker:DeleteEndpoint",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:DescribeEndpointConfig",
      "sagemaker:DeleteEndpointConfig"
    ]
    
    resources = [
      "arn:aws:sagemaker:${local.region}:${local.account_id}:*/${local.name_prefix}*"
    ]
  }
  
  statement {
    effect = "Allow"
    
    actions = [
      "iam:PassRole"
    ]
    
    resources = [aws_iam_role.sagemaker_execution_role.arn]
    
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_sagemaker_policy" {
  name        = "${local.name_prefix}-lambda-sagemaker-access"
  description = "Lambda access to SageMaker services"
  policy      = data.aws_iam_policy_document.lambda_sagemaker_policy.json
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-lambda-sagemaker-policy"
    Purpose     = "Lambda SageMaker access permissions"
    Service     = "IAM"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sagemaker_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_sagemaker_policy.arn
}

# CloudWatch log group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  count = var.enable_detailed_monitoring ? 1 : 0
  
  name              = "/aws/lambda/${local.name_prefix}"
  retention_in_days = var.log_retention_days
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-lambda-logs"
    Purpose     = "Lambda execution logs"
    Service     = "CloudWatch"
  })
}
