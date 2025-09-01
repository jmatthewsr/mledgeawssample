# Infrastructure Security Overview - ML Edge Project

## Overview
This document outlines the comprehensive security architecture implemented for the ML Edge project, focusing on defense-in-depth principles, zero-trust networking, and modern cloud security practices.

## Security Architecture

### Core Security Principles
- **Zero Long-Term Credentials**: No permanent access keys or passwords
- **Least Privilege Access**: Minimal permissions required for each role
- **Defense in Depth**: Multiple layers of security controls
- **Encryption Everywhere**: Data protection at rest and in transit
- **Comprehensive Auditing**: All activities logged and monitored

### Authentication & Authorization

#### AWS SSO (IAM Identity Center)
```
Identity Store → Permission Sets → Account Assignment → Temporary Credentials
```

**Components:**
- **Identity Store**: Centralized user directory (AWS managed or external SAML/OIDC)
- **Permission Sets**: Role-like containers defining AWS permissions
- **Account Assignment**: Links users/groups to permission sets in specific accounts
- **Temporary Credentials**: Short-lived AWS credentials (8-hour maximum sessions)

#### Permission Model
```
AWS SSO Instance
└── MLEdgeDevelopers Permission Set
    ├── AWS ReadOnlyAccess (managed policy)
    └── Custom Inline Policies:
        ├── SageMaker ML workflow access (region-restricted)
        ├── S3 project bucket access (resource-specific)
        ├── CloudWatch logging access (service-specific)
        └── ECR container access (read-only)
```

### Data Protection

#### Encryption at Rest
- **S3 Buckets**: Server-side encryption with customer-managed KMS keys
- **KMS Key Management**: Automatic key rotation enabled
- **Key Policies**: Least privilege access to encryption keys
- **Cross-Service Encryption**: Consistent encryption across all services

```hcl
# KMS Encryption Configuration
resource "aws_kms_key" "s3_encryption" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
```

#### Encryption in Transit
- **TLS 1.2+**: All API communications encrypted
- **HTTPS Enforcement**: S3 bucket policies require secure transport
- **VPC Endpoints**: Future implementation for private connectivity

#### S3 Security Configuration
- **Versioning**: Enabled on all buckets for data protection
- **Public Access Blocking**: Complete prevention of accidental public exposure
- **Lifecycle Policies**: Automated data archival for cost optimization
- **Access Logging**: Comprehensive audit trail of all S3 activities

```hcl
# S3 Security Controls
resource "aws_s3_bucket_public_access_block" "bucket_pab" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### Network Security

#### Current Implementation
- **Regional Restriction**: All access limited to us-east-1 region
- **Service-Specific Access**: Policies restrict access to specific AWS services
- **No VPC**: Current implementation uses public AWS endpoints with IAM controls

#### Future Enhancements
- **VPC Implementation**: Private networking for enhanced isolation
- **VPC Endpoints**: Private connectivity to AWS services
- **Security Groups**: Application-level network controls
- **NACLs**: Network-level access controls

### Access Control

#### IAM Service Roles
- **SageMaker Execution Role**: ML workflow permissions with cross-service access
- **Lambda Execution Roles**: Data processing with minimal required permissions
- **Cross-Service Policies**: Secure service-to-service communication

#### Resource-Level Permissions
```hcl
# Example: S3 bucket-specific access
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject"
  ],
  "Resource": [
    "arn:aws:s3:::slm-edge-dev-intents-raw/*",
    "arn:aws:s3:::slm-edge-dev-model-artifacts/*"
  ]
}
```

#### Conditional Access
- **Regional Restrictions**: API calls limited to us-east-1
- **Time-Based Access**: 8-hour maximum session duration
- **MFA Enforcement**: Multi-factor authentication capability
- **Source IP Restrictions**: (Available for future implementation)

## Security Features

### ✅ Zero Long-Term Credentials
- **No IAM Access Keys**: Complete elimination of permanent credentials
- **Temporary Tokens**: All access via short-lived SSO tokens
- **Automatic Expiration**: 8-hour session duration with automatic refresh
- **MFA Support**: Built-in multi-factor authentication capability

### ✅ Least Privilege Access
- **Resource-Specific Permissions**: Access limited to specific S3 buckets and services
- **Regional Restrictions**: API calls restricted to us-east-1 region only
- **Service-Specific Roles**: Separate IAM roles for different AWS services
- **Conditional Policies**: Additional restrictions based on request context

### ✅ Encryption Everywhere
- **S3 Server-Side Encryption**: Customer-managed KMS keys for all buckets
- **KMS Key Rotation**: Automatic annual key rotation enabled
- **Encryption in Transit**: TLS 1.2+ for all API communications
- **Future CloudTrail Encryption**: Planned implementation for audit logs

### ✅ Comprehensive Monitoring
- **CloudTrail Logging**: All API calls logged and monitored
- **CloudWatch Integration**: Service-specific logging and metrics
- **SSO Access Logging**: User authentication and session activities
- **Budget Monitoring**: Cost alerts and spending controls ($10/month limit)

### ✅ Data Lifecycle Management
- **S3 Versioning**: Protection against accidental deletion or modification
- **Lifecycle Policies**: Automated transition to cost-effective storage classes
  - **30 days**: Standard → Infrequent Access
  - **90 days**: Infrequent Access → Glacier
  - **365 days**: Glacier → Deep Archive
- **Public Access Prevention**: Complete blocking of public bucket access

## Security Testing & Validation

### ✅ Infrastructure Security Tests
- **Terraform Validation**: Syntax and configuration validation
- **Policy Validation**: IAM policy syntax and permission verification
- **Resource Configuration**: S3 security settings and encryption validation
- **SSO Permission Sets**: Permission set configuration and assignment testing

### ✅ Access Control Tests
- **Authentication Flow**: SSO login and token acquisition testing
- **Permission Verification**: Resource access with correct and incorrect permissions
- **Session Management**: Token expiration and refresh testing
- **MFA Testing**: Multi-factor authentication flow validation

### ✅ Encryption Tests
- **KMS Key Configuration**: Key policy and rotation settings validation
- **S3 Encryption**: Server-side encryption verification for all buckets
- **Transit Encryption**: TLS enforcement and certificate validation
- **Key Access**: Proper IAM permissions for encryption key usage

### ✅ Network Security Tests
- **Public Access Blocking**: S3 bucket public access prevention verification
- **Regional Restrictions**: API call limitation to us-east-1 testing
- **Service Boundaries**: Cross-service access control validation
- **Endpoint Security**: HTTPS enforcement and certificate validation

### ✅ Audit & Compliance Tests
- **CloudTrail Configuration**: Logging enablement and log integrity verification
- **Log Retention**: Proper log retention policy implementation
- **Access Logging**: S3 access logging configuration and functionality
- **Budget Alerts**: Cost monitoring and alert configuration testing

## Compliance Framework

### SOC 2 Type II Alignment
- **Access Controls**: Centralized authentication and authorization
- **Logical Access**: Role-based access control with least privilege
- **System Operations**: Comprehensive logging and monitoring
- **Change Management**: Infrastructure as Code with version control

### ISO 27001 Alignment
- **Information Security Management**: Documented security policies and procedures
- **Access Control**: Strong authentication and authorization mechanisms
- **Cryptography**: Encryption at rest and in transit
- **Incident Management**: Monitoring and alerting capabilities

### PCI DSS Considerations
- **No Stored Credentials**: Zero long-term credentials eliminate major risks
- **Encryption Requirements**: Strong encryption for data protection
- **Access Controls**: Strict role-based access control
- **Monitoring**: Comprehensive audit trails and monitoring

## Risk Assessment

### Security Risks & Mitigations

#### High Risk: Compromised SSO Session
- **Risk**: Unauthorized access if SSO session is compromised
- **Mitigation**: 8-hour session expiration, MFA enforcement capability
- **Detection**: CloudTrail monitoring for unusual access patterns

#### Medium Risk: Overprivileged Permissions
- **Risk**: Users gaining more access than required for their role
- **Mitigation**: Least privilege principle, regular permission reviews
- **Detection**: AWS Access Analyzer for unused permissions

#### Medium Risk: Data Exposure
- **Risk**: Accidental exposure of sensitive data
- **Mitigation**: S3 public access blocking, encryption at rest
- **Detection**: AWS Config rules for compliance monitoring

#### Low Risk: Service Availability
- **Risk**: AWS service outages affecting access
- **Mitigation**: Multi-region strategy (future), emergency procedures
- **Detection**: AWS service health monitoring

### Security Monitoring

#### Real-Time Monitoring
- **CloudTrail**: API call monitoring and alerting
- **CloudWatch**: Service-specific metrics and logs
- **Budget Alerts**: Cost-based anomaly detection
- **SSO Logs**: Authentication and session monitoring

#### Periodic Reviews
- **Monthly**: Access reviews and permission audits
- **Quarterly**: Security configuration assessments
- **Annually**: Complete security architecture review
- **As-needed**: Incident response and remediation

## Future Security Enhancements

### Planned Improvements
- [ ] **VPC Implementation**: Private networking with VPC endpoints
- [ ] **AWS Config**: Configuration compliance monitoring
- [ ] **GuardDuty**: Threat detection and security monitoring
- [ ] **Security Hub**: Centralized security findings management
- [ ] **CloudFormation Drift Detection**: Infrastructure compliance monitoring

### Advanced Security Features
- [ ] **AWS WAF**: Web application firewall for API protection
- [ ] **AWS Shield**: DDoS protection for public-facing resources
- [ ] **KMS Multi-Region Keys**: Cross-region encryption key management
- [ ] **Cross-Account Access**: Secure multi-account architecture
- [ ] **Zero Trust Networking**: Complete network segmentation and controls

## Security Documentation

### Required Documentation
- [SSO Decision Record](./sso-decision-record.md) - Authentication architecture decisions
- [Developer Onboarding Guide](./infra-dev-onboarding.md) - Secure access procedures
- [Incident Response Plan](./incident-response-plan.md) - Security incident procedures (planned)
- [Security Runbook](./security-runbook.md) - Operational security procedures (planned)

### Compliance Documentation
- Security policies and procedures
- Risk assessment and treatment plans
- Audit trails and access logs
- Security training and awareness materials

## Contact Information

### Security Team
- **Security Architect**: ML Team Lead
- **Cloud Security**: Information Security Team
- **Incident Response**: 24/7 Security Operations Center
- **Compliance**: Risk and Compliance Team
