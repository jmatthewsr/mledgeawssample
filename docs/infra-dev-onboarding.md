# Developer Onboarding Guide - ML Edge Project

## Overview
This guide provides step-by-step instructions for developers to gain secure access to AWS resources for the ML Edge project using AWS SSO (IAM Identity Center).

## Prerequisites
- AWS account access (provided by administrator)
- AWS CLI v2 installed on your local machine
- Web browser for SSO authentication
- Basic familiarity with AWS services

## Access Model
The ML Edge project uses **AWS SSO exclusively** for user authentication. No traditional IAM users or access keys are used, ensuring maximum security through temporary credentials.

### What You Get Access To
- **SageMaker**: Full ML workflow capabilities (notebooks, training jobs, models, endpoints)
- **S3 Buckets**: Project-specific data storage (raw data, processed data, model artifacts)
- **CloudWatch**: Logging and monitoring for your ML workflows
- **ECR**: Container registry for custom ML containers (read access)

### Access Restrictions
- **Region**: Limited to us-east-1 only
- **Session Duration**: 8 hours maximum (automatic re-authentication required)
- **Resources**: Access only to project-specific resources, not entire AWS account

## Getting Started

### Step 1: Receive Your SSO Invitation
1. Check your email for an invitation from AWS SSO
2. The email will come from `no-reply@signin.aws` with subject "You're invited to access AWS resources"
3. Click **"Accept invitation"** in the email

### Step 2: Set Up Your SSO Account
1. **Create Password**: Set a strong, unique password for your SSO account
2. **Configure MFA** (Strongly Recommended):
   - Click on your profile → Security → Register MFA device
   - Use Google Authenticator, Authy, or similar TOTP app
   - Scan the QR code and enter the verification code
3. **Note Your SSO Portal URL**: Save the SSO start URL (e.g., `https://d-xxxxxxxxxx.awsapps.com/start`)

### Step 3: Install and Configure AWS CLI

#### Install AWS CLI v2
```powershell
# Windows (PowerShell)
# Download from: https://awscli.amazonaws.com/AWSCLIV2.msi
# Or use winget:
winget install Amazon.AWSCLI

# Verify installation
aws --version
```

#### Configure SSO Profile
```powershell
# Start SSO configuration
aws configure sso

# You'll be prompted for the following information:
```

**SSO Configuration Prompts:**
```
SSO session name (Recommended: ml-edge-dev): ml-edge-dev
SSO start URL [None]: https://d-xxxxxxxxxx.awsapps.com/start
SSO region [None]: us-east-1
SSO registration scopes [sso:account:access]:  [Press Enter]
```

This will open your browser for authentication. After logging in:

```
There are 1 AWS accounts available to you.
Using the account ID 846505724811
The only role available to you is: MLEdgeDevelopers
Using the role name "MLEdgeDevelopers"
CLI default client Region [None]: us-east-1
CLI default output format [None]: json
CLI profile name [MLEdgeDevelopers-846505724811]: ml-edge-dev

To use this profile, specify the profile name using --profile, as shown:
aws s3 ls --profile ml-edge-dev
```

### Step 4: Verify Your Access

#### Test Authentication
```powershell
# Login to SSO (this will open your browser)
aws sso login --profile ml-edge-dev

# Verify your identity
aws sts get-caller-identity --profile ml-edge-dev
```

Expected output:
```json
{
    "UserId": "AROABC123DEFGHIJKLMN:john.developer@company.com",
    "Account": "846505724811",
    "Arn": "arn:aws:sts::846505724811:assumed-role/MLEdgeDevelopers/john.developer@company.com"
}
```

#### Test S3 Access
```powershell
# List project S3 buckets
aws s3 ls --profile ml-edge-dev

# Expected buckets:
# slm-edge-dev-intents-raw
# slm-edge-dev-intents-processed  
# slm-edge-dev-model-artifacts
# slm-edge-dev-edge-deployments
# slm-edge-dev-pipeline-artifacts
```

#### Test SageMaker Access
```powershell
# List SageMaker training jobs
aws sagemaker list-training-jobs --profile ml-edge-dev

# List SageMaker notebook instances
aws sagemaker list-notebook-instances --profile ml-edge-dev
```

## Daily Workflow

### Starting Your Work Session
```powershell
# Login (browser will open for authentication)
aws sso login --profile ml-edge-dev

# Your credentials are now active for 8 hours
```

### Working with AWS Resources

#### Upload Data to S3
```powershell
# Upload training data
aws s3 sync ./data s3://slm-edge-dev-intents-raw/ --profile ml-edge-dev

# Copy model artifacts
aws s3 cp model.tar.gz s3://slm-edge-dev-model-artifacts/ --profile ml-edge-dev
```

#### Create SageMaker Training Job
```powershell
# Create training job using AWS CLI
aws sagemaker create-training-job \
  --training-job-name "intent-classifier-$(date +%Y%m%d%H%M%S)" \
  --role-arn "arn:aws:iam::846505724811:role/slm-edge-dev-sagemaker-execution-role" \
  --algorithm-specification TrainingImage=382416733822.dkr.ecr.us-east-1.amazonaws.com/sklearn_pandas:latest,TrainingInputMode=File \
  --input-data-config file://training-config.json \
  --output-data-config S3OutputPath=s3://slm-edge-dev-model-artifacts/models/ \
  --resource-config InstanceType=ml.m5.large,InstanceCount=1,VolumeSizeInGB=10 \
  --stopping-condition MaxRuntimeInSeconds=3600 \
  --profile ml-edge-dev
```

#### Monitor CloudWatch Logs
```powershell
# List log groups
aws logs describe-log-groups --profile ml-edge-dev

# Get log events for training job
aws logs get-log-events \
  --log-group-name "/aws/sagemaker/TrainingJobs" \
  --log-stream-name "intent-classifier-20250901120000/algo-1-1693566000" \
  --profile ml-edge-dev
```

### Session Management
- **Session Duration**: 8 hours maximum
- **Re-authentication**: When your session expires, simply run `aws sso login --profile ml-edge-dev`
- **Multiple Sessions**: You can have active sessions on multiple devices
- **Logout**: `aws sso logout` (optional, sessions expire automatically)

## Development Environment Setup

### Environment Variables
```powershell
# Set default profile (optional)
$env:AWS_PROFILE = "ml-edge-dev"

# Verify environment
aws sts get-caller-identity
```

### IDE Configuration

#### VS Code with AWS Toolkit
1. Install the AWS Toolkit extension
2. Configure to use your SSO profile:
   - Open Command Palette (Ctrl+Shift+P)
   - Type "AWS: Connect to AWS"
   - Select your SSO profile: `ml-edge-dev`

#### Jupyter Notebooks
```python
# For boto3 in Jupyter notebooks
import boto3

# Create session with profile
session = boto3.Session(profile_name='ml-edge-dev')
s3 = session.client('s3')
sagemaker = session.client('sagemaker')
```

#### Python Scripts
```python
# Use profile in Python scripts
import boto3

# Method 1: Specify profile explicitly
session = boto3.Session(profile_name='ml-edge-dev')
s3 = session.client('s3')

# Method 2: Set environment variable
import os
os.environ['AWS_PROFILE'] = 'ml-edge-dev'
s3 = boto3.client('s3')
```

## Available Resources

### S3 Buckets and Their Purposes

| Bucket Name | Purpose | Access Level |
|-------------|---------|--------------|
| `slm-edge-dev-intents-raw` | Raw intent data uploads | Read/Write |
| `slm-edge-dev-intents-processed` | Processed/cleaned data | Read/Write |
| `slm-edge-dev-model-artifacts` | Trained models and outputs | Read/Write |
| `slm-edge-dev-edge-deployments` | Edge deployment packages | Read/Write |
| `slm-edge-dev-pipeline-artifacts` | CI/CD and pipeline outputs | Read/Write |

### SageMaker Resources
- **Execution Role**: `slm-edge-dev-sagemaker-execution-role`
- **Instance Types**: `ml.t3.medium`, `ml.m5.large`, `ml.m5.xlarge` (training)
- **Notebook Instances**: `ml.t3.medium` (development)
- **Endpoints**: `ml.t2.medium` (inference)

### CloudWatch Log Groups
- `/aws/sagemaker/TrainingJobs` - Training job logs
- `/aws/sagemaker/NotebookInstances` - Notebook instance logs
- `/aws/lambda/data-processing` - Lambda function logs
- `slm-edge-*` - Application-specific logs

## Troubleshooting

### Common Issues

#### "No SSO instances found"
**Problem**: CLI can't find SSO configuration
**Solution**: 
```powershell
# Ensure IAM Identity Center is enabled in your account
# Verify you're using the correct region (us-east-1)
aws configure list-profiles
```

#### "Session expired" or "Token has expired"
**Problem**: Your 8-hour session has expired
**Solution**:
```powershell
# Simply login again
aws sso login --profile ml-edge-dev
```

#### "Access Denied" errors
**Problem**: Trying to access resources outside your permissions
**Solutions**:
- Verify you're using the correct profile: `--profile ml-edge-dev`
- Check you're in the correct region (us-east-1)
- Ensure the resource is part of the ML Edge project
- Contact your administrator if you need additional permissions

#### "Unable to locate credentials"
**Problem**: AWS CLI can't find your credentials
**Solution**:
```powershell
# Check your profiles
aws configure list-profiles

# Verify SSO login status
aws sts get-caller-identity --profile ml-edge-dev

# Re-login if necessary
aws sso login --profile ml-edge-dev
```

#### Browser doesn't open for SSO login
**Problem**: SSO authentication fails to open browser
**Solutions**:
```powershell
# Try manual browser opening
aws sso login --profile ml-edge-dev

# Copy the URL from the output and open manually in browser
# Complete authentication and return to terminal
```

### Getting Help

#### Check Your Access
```powershell
# Verify current identity
aws sts get-caller-identity --profile ml-edge-dev

# List accessible S3 buckets
aws s3 ls --profile ml-edge-dev

# Check SageMaker permissions
aws sagemaker list-training-jobs --profile ml-edge-dev --max-items 5
```

#### Useful Commands
```powershell
# List all configured profiles
aws configure list-profiles

# Show current configuration
aws configure list --profile ml-edge-dev

# Check SSO session status
aws sso list-accounts --profile ml-edge-dev
```

## Security Best Practices

### Do's ✅
- **Always use your SSO profile**: Specify `--profile ml-edge-dev` in commands
- **Enable MFA**: Use multi-factor authentication on your SSO account
- **Keep sessions secure**: Don't share your browser session or leave it unattended
- **Use HTTPS**: All AWS API calls are automatically encrypted in transit
- **Regular re-authentication**: Don't be surprised by 8-hour session expiration

### Don'ts ❌
- **Never share credentials**: Your SSO session is personal and non-transferable
- **Don't use access keys**: This project doesn't use traditional IAM access keys
- **Don't hardcode credentials**: Use profiles and environment variables
- **Don't bypass SSO**: All access must go through AWS SSO
- **Don't use root account**: Use your assigned SSO user account only

### Incident Reporting
If you suspect a security issue:
1. **Immediately logout**: `aws sso logout`
2. **Change your SSO password**: Via the SSO portal
3. **Report the incident**: Contact your team lead or security team
4. **Document the issue**: Note what happened and when

## Support and Resources

### Getting Help
- **Technical Issues**: Contact your team lead or AWS administrator
- **Account Access**: Contact your organization's AWS administrator
- **AWS Documentation**: [AWS SSO User Guide](https://docs.aws.amazon.com/singlesignon/)
- **CLI Documentation**: [AWS CLI SSO Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)

### Additional Resources
- [Infrastructure Security Overview](./infra-security-overview.md)
- [SSO Decision Record](./sso-decision-record.md)
- [SageMaker Developer Guide](https://docs.aws.amazon.com/sagemaker/)
- [S3 User Guide](https://docs.aws.amazon.com/s3/)

### Quick Reference Card
```powershell
# Essential Commands
aws sso login --profile ml-edge-dev          # Login
aws sts get-caller-identity --profile ml-edge-dev  # Check identity
aws s3 ls --profile ml-edge-dev              # List buckets
aws sagemaker list-training-jobs --profile ml-edge-dev  # List training jobs
aws sso logout                               # Logout (optional)

# Profile: ml-edge-dev
# Region: us-east-1
# Session Duration: 8 hours
# Account: 846505724811
```
