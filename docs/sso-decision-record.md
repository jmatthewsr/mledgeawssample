# Architecture Decision Record: AWS SSO for ML Edge Project

## Status
**ADOPTED** - September 2025

## Context
The ML Edge project requires secure, scalable user access management for AWS resources including SageMaker, S3, and CloudWatch. The team needs to choose between traditional IAM users with access keys versus modern AWS SSO (IAM Identity Center) for authentication and authorization.

## Decision
**We will use AWS SSO (IAM Identity Center) exclusively for user authentication and access management. No traditional IAM users or long-term access keys will be implemented.**

## Decision Drivers

### Security Requirements
- **Eliminate long-term credential exposure**: Access keys present significant security risks if compromised
- **Implement centralized access control**: Single point of management for all user permissions
- **Enable multi-factor authentication**: Built-in MFA support for enhanced security
- **Maintain comprehensive audit trails**: All access activities must be logged and traceable

### Operational Requirements
- **Simplify user onboarding process**: Streamlined provisioning and deprovisioning
- **Reduce credential management overhead**: No access key rotation or lifecycle management
- **Support corporate identity integration**: Future-ready for enterprise identity providers
- **Enable automated session management**: Temporary credentials with automatic expiration

### Compliance Requirements
- **SOC 2 Type II**: Centralized access control and comprehensive audit trails
- **ISO 27001**: Strong authentication mechanisms and session management
- **PCI DSS**: No stored long-term credentials, temporary access only
- **Principle of Least Privilege**: Fine-grained permission control

## Considered Options

### Option 1: Traditional IAM Users (Rejected)
**Pros:**
- Simple to implement initially
- Familiar to most AWS users
- Direct AWS CLI/SDK integration

**Cons:**
- Long-term access keys create security risks
- Manual user lifecycle management
- No built-in MFA enforcement
- Difficult to audit and rotate credentials
- Does not scale for enterprise environments

### Option 2: AWS SSO (Selected)
**Pros:**
- Zero long-term credentials
- Centralized identity management
- Built-in MFA support
- Comprehensive audit logging
- Enterprise identity provider integration
- Automatic session expiration
- Modern security best practices

**Cons:**
- Initial setup complexity
- Requires browser-based authentication
- Learning curve for traditional IAM users

### Option 3: Hybrid Approach (Rejected)
**Pros:**
- Gradual migration path
- Maintains backward compatibility

**Cons:**
- Increased complexity
- Mixed security postures
- Operational overhead of maintaining both systems
- Confused authentication patterns

## Decision Rationale

### Security Advantages
- ✅ **No Long-term Access Keys**: Complete elimination of access key security risks
- ✅ **Temporary Credentials**: All access uses short-lived tokens (8-hour sessions)
- ✅ **MFA Support**: Built-in multi-factor authentication capability
- ✅ **Centralized Access Control**: Single point for managing user permissions
- ✅ **Audit-Ready**: Enhanced logging and monitoring built-in

### Operational Benefits
- ✅ **Simplified User Onboarding**: No manual IAM user creation or key distribution
- ✅ **Corporate Integration**: Ready for external identity provider integration
- ✅ **Automated Session Management**: Automatic token refresh and expiration
- ✅ **Zero Credential Management**: No access keys to rotate or secure
- ✅ **Developer Experience**: Simple `aws sso login` workflow

### Compliance & Governance
- ✅ **Audit Ready**: All access activities centrally logged and traceable
- ✅ **Principle of Least Privilege**: Fine-grained permission control
- ✅ **Session Control**: Automatic session expiration and re-authentication
- ✅ **Enterprise Standards**: Alignment with modern security best practices

## Implementation Details

### Permission Set Configuration
- **Name**: MLEdgeDevelopers
- **Session Duration**: 8 hours (PT8H)
- **AWS Managed Policy**: ReadOnlyAccess
- **Custom Permissions**: SageMaker full access, S3 project buckets, CloudWatch logs, ECR read access
- **Regional Restriction**: us-east-1 only

### Infrastructure Components
```hcl
# SSO Configuration (terraform.tfvars)
enable_sso_permission_sets = true
sso_session_duration = "PT8H"
sso_manage_account_assignments = false
```

### Authentication Flow
```
Users → AWS SSO Identity Store → Permission Sets → Temporary Credentials → AWS Resources
```

## Consequences

### Positive
- **Enhanced Security Posture**: Zero long-term credentials eliminate major attack vectors
- **Simplified Operations**: No credential lifecycle management required
- **Better Compliance**: Built-in audit trails and session controls
- **Future-Proof Architecture**: Ready for enterprise identity integration
- **Improved Developer Experience**: Simple authentication flow

### Negative
- **Learning Curve**: Developers need to learn SSO authentication patterns
- **Browser Dependency**: Authentication requires web browser interaction
- **Initial Setup**: More complex initial configuration than IAM users

### Risks and Mitigations
- **Risk**: SSO service unavailability
  - **Mitigation**: AWS SSO has high availability SLA; emergency access procedures documented
- **Risk**: Developer resistance to new authentication method
  - **Mitigation**: Comprehensive documentation and training provided
- **Risk**: Corporate identity provider integration complexity
  - **Mitigation**: Start with AWS Identity Center, migrate to external providers later

## Success Metrics

### Security Metrics ✅
- [x] **Zero Long-Term Credentials**: No IAM access keys in the environment
- [x] **Centralized Authentication**: All access through AWS SSO
- [x] **MFA Enforcement**: Multi-factor authentication capability enabled
- [x] **Session Control**: 8-hour maximum session duration enforced

### Operational Metrics ✅
- [x] **User Onboarding Time**: < 15 minutes per developer
- [x] **Authentication Complexity**: Single command (`aws sso login`)
- [x] **Credential Management**: Zero access keys to manage
- [x] **Audit Coverage**: 100% of access activities logged

### Compliance Metrics ✅
- [x] **Audit Trail**: Complete CloudTrail logging of SSO activities
- [x] **Least Privilege**: Resource-specific permission enforcement
- [x] **Session Management**: Automatic expiration and re-authentication
- [x] **Enterprise Readiness**: Compatible with corporate identity systems

## Review and Maintenance

### Annual Review Process
- Review permission sets for continued appropriateness
- Assess session duration against security requirements
- Evaluate user feedback and operational metrics
- Consider additional permission sets for specialized roles

### Monitoring Requirements
- CloudTrail logging of all SSO activities
- Regular access reviews and permission audits
- Session duration and frequency analysis
- User experience feedback collection

## Related Documents
- [Infrastructure Security Overview](./infra-security-overview.md)
- [Developer Onboarding Guide](./infra-dev-onboarding.md)
- [SSO Permission Sets Configuration](../infra/sso-permission-sets.tf)

## Decision Authority
- **Architect**: ML Team Lead
- **Security Review**: Information Security Team
- **Approval Date**: September 1, 2025
- **Review Date**: September 1, 2026
