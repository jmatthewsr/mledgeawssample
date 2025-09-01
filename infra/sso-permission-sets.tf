# ML Edge Project - SSO Permission Sets Configuration
# This file defines AWS SSO (IAM Identity Center) permission sets for team access

# Data source for SSO instances
data "aws_ssoadmin_instances" "main" {}

# Note: aws_caller_identity.current is defined in main.tf

# =============================================================================
# SSO PERMISSION SET FOR ML EDGE DEVELOPERS
# =============================================================================

resource "aws_ssoadmin_permission_set" "ml_edge_developers" {
  count = var.enable_sso_permission_sets ? 1 : 0
  
  name         = "MLEdgeDevelopers"
  description  = "Permission set for ML Edge project developers with full ML workflow access"
  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
  
  # Configurable session duration
  session_duration = var.sso_session_duration
  
  tags = merge(local.common_tags, {
    Name        = "ml-edge-developers-permission-set"
    Purpose     = "Development team access via SSO"
    Service     = "SSO"
  })
}

# =============================================================================
# AWS MANAGED POLICY ATTACHMENTS
# =============================================================================

# Read-only access to AWS services for monitoring and debugging
resource "aws_ssoadmin_managed_policy_attachment" "readonly_access" {
  count = var.enable_sso_permission_sets ? 1 : 0
  
  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.ml_edge_developers[0].arn
}

# =============================================================================
# CUSTOM INLINE POLICY FOR ML DEVELOPMENT
# =============================================================================

# Policy document for ML Edge development access
data "aws_iam_policy_document" "ml_edge_sso_dev_policy" {
  # SageMaker access for ML development
  statement {
    effect = "Allow"
    
    actions = [
      "sagemaker:CreateNotebookInstance",
      "sagemaker:DescribeNotebookInstance",
      "sagemaker:StartNotebookInstance",
      "sagemaker:StopNotebookInstance",
      "sagemaker:UpdateNotebookInstance",
      "sagemaker:CreateTrainingJob",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:StopTrainingJob",
      "sagemaker:CreateModel",
      "sagemaker:DescribeModel",
      "sagemaker:DeleteModel",
      "sagemaker:CreateEndpoint",
      "sagemaker:DescribeEndpoint",
      "sagemaker:UpdateEndpoint",
      "sagemaker:DeleteEndpoint",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:DescribeEndpointConfig",
      "sagemaker:DeleteEndpointConfig",
      "sagemaker:ListTrainingJobs",
      "sagemaker:ListModels",
      "sagemaker:ListEndpoints"
    ]
    
    resources = ["*"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }
  
  # IAM PassRole for SageMaker
  statement {
    effect = "Allow"
    
    actions = [
      "iam:PassRole"
    ]
    
    resources = [aws_iam_role.sagemaker_execution_role.arn]
  }
  
  # CloudWatch Logs access
  statement {
    effect = "Allow"
    
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents"
    ]
    
    resources = [
      "arn:aws:logs:${var.aws_region}:*:log-group:/aws/sagemaker/*",
      "arn:aws:logs:${var.aws_region}:*:log-group:${var.project_name}-*"
    ]
  }
  
  # ECR access for container images
  statement {
    effect = "Allow"
    
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    
    resources = ["*"]
  }
  
  # CloudWatch metrics access for monitoring
  statement {
    effect = "Allow"
    
    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:DescribeAlarms"
    ]
    
    resources = ["*"]
  }
}

# Attach the custom inline policy to the permission set
resource "aws_ssoadmin_permission_set_inline_policy" "ml_edge_dev_policy" {
  count = var.enable_sso_permission_sets ? 1 : 0
  
  inline_policy      = data.aws_iam_policy_document.ml_edge_sso_dev_policy.json
  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.ml_edge_developers[0].arn
}

# Attach the custom S3 policy (from iam-s3.tf) to the permission set
resource "aws_ssoadmin_customer_managed_policy_attachment" "ml_edge_dev_s3_policy" {
  count = var.enable_sso_permission_sets ? 1 : 0
  
  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.ml_edge_developers[0].arn
  
  customer_managed_policy_reference {
    name = aws_iam_policy.dev_team_s3_policy.name
    path = "/"
  }
}

# =============================================================================
# ACCOUNT ASSIGNMENT (OPTIONAL - CAN BE MANAGED MANUALLY)
# =============================================================================

# Uncomment and configure if you want Terraform to manage user assignments
# Note: This requires users/groups to already exist in your identity source

# resource "aws_ssoadmin_account_assignment" "ml_edge_developers_group" {
#   instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
#   permission_set_arn = aws_ssoadmin_permission_set.ml_edge_developers.arn
#   
#   principal_id   = "GROUP_ID_FROM_IDENTITY_SOURCE"  # Replace with actual group ID
#   principal_type = "GROUP"
#   
#   target_id   = data.aws_caller_identity.current.account_id
#   target_type = "AWS_ACCOUNT"
# }

# Individual user assignment example
# resource "aws_ssoadmin_account_assignment" "developer_user" {
#   instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
#   permission_set_arn = aws_ssoadmin_permission_set.ml_edge_developers.arn
#   
#   principal_id   = "USER_ID_FROM_IDENTITY_SOURCE"   # Replace with actual user ID
#   principal_type = "USER"
#   
#   target_id   = data.aws_caller_identity.current.account_id
#   target_type = "AWS_ACCOUNT"
# }
