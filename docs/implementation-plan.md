# Implementation Plan for ML Edge Project with AWS

## Overview
This plan outlines the implementation of an ML edge project that fine-tunes a small language model for intent classification using AWS services. **Following TDD approach and production-level standards.**

## Approval Process
🔒 **IMPORTANT**: Each individual checkbox item throughout this plan requires explicit approval before implementation. No implementation should begin without specific approval for that item.

## Implementation Philosophy
- **Test-First Approach (TDD)**: Write tests before implementation
- **Production Standards**: Code quality, error handling, monitoring
- **Infrastructure as Code**: All resources defined in Terraform
- **CI/CD Ready**: Automated testing and deployment pipelines
- **Granular Approval**: Each item requires individual approval before implementation

## Implementation Phases

### ✅ Pre-Phase 1: Project Foundation Setup - COMPLETED
- [x] Create comprehensive `.gitignore` file for Python/ML/AWS/Terraform project

### ✅ Phase 1: Python Project Setup & Development Environment - COMPLETED
**Project Setup Phase (Foundation First):**
- [x] Create `pyproject.toml` with modern Python project configuration
- [x] Create PowerShell script (`make.ps1`) with targets for:
  - [x] Environment setup (`make.ps1 setup`)
  - [x] Project building (`make.ps1 build`)
  - [x] Running tests (`make.ps1 test`)
  - [x] Code linting with Ruff (`make.ps1 lint`)
  - [x] Type checking with Pyright (`make.ps1 typecheck`)
  - [x] Infrastructure tests (`make.ps1 test-infra`)
  - [x] All checks combined (`make.ps1 all` or `make.ps1`)
- [x] Configure Ruff for linting and code formatting
- [x] Configure Pyright for static type checking
- [x] Create pytest configuration and test structure
- [x] Set up mocked AWS services (using moto) for infrastructure testing
- [x] Set up pre-commit hooks for automated quality checks

### ⏳ Phase 2: Infrastructure Setup with TDD - PENDING
**Infrastructure Testing Phase (Write Tests First):**
- [ ] Create infrastructure tests for Terraform validation
- [ ] Write tests for S3 bucket creation and configuration
- [ ] Write tests for S3 bucket policies and versioning
- [ ] Write tests for S3 encryption and lifecycle policies
- [ ] Write tests for IAM roles and permissions
- [ ] Write tests for resource naming and tagging

**Infrastructure Implementation Phase (After Tests Written):**
- [ ] Create Terraform configuration for S3 buckets
- [ ] Set up S3 bucket for raw data: `s3://slm-intents-raw/`
- [ ] Set up S3 bucket for processed data: `s3://slm-intents-processed/`
- [ ] Set up S3 bucket for model artifacts: `s3://slm-model-artifacts/`
- [ ] Set up S3 bucket for edge deployments: `s3://slm-edge-deployments/`
- [ ] Configure bucket policies and versioning
- [ ] Add encryption and lifecycle policies
- [ ] Create IAM roles for SageMaker pipeline execution
- [ ] Validate Terraform configuration passes all tests
- [ ] Deploy infrastructure and verify tests pass

### ⏳ Phase 3: Data Processing Pipeline (TDD) - PENDING

#### 🧪 3.1 Data Processing (TDD)
**Testing Phase (Write Tests First):**
- [ ] Test data validation functions
- [ ] Test data cleaning and preprocessing
- [ ] Test train/validation/test splitting
- [ ] Test tokenization and feature extraction
- [ ] Test S3 data loading/saving

**Implementation Phase (After Tests Approved):**
- [ ] Implement data validation and cleaning
- [ ] Implement train/validation/test split
- [ ] Implement tokenization and feature extraction
- [ ] Implement error handling and logging
- [ ] Integrate Great Expectations validation

#### 🧪 3.2 Model Training (TDD)
**Testing Phase (Write Tests First):**
- [ ] Test model loading and configuration
- [ ] Test LoRA/QLoRA fine-tuning setup
- [ ] Test training loop and checkpointing
- [ ] Test metrics collection and logging
- [ ] Test model saving and versioning

**Implementation Phase (After Tests Approved):**
- [ ] Implement model loading and configuration
- [ ] Implement fine-tuning loop with LoRA/QLoRA
- [ ] Implement metrics tracking and logging
- [ ] Implement model checkpointing and recovery
- [ ] Integrate with SageMaker

#### 🧪 3.3 Model Evaluation (TDD)
**Testing Phase (Write Tests First):**
- [ ] Test model loading for evaluation
- [ ] Test intent classification metrics calculation
- [ ] Test model quality gates
- [ ] Test evaluation report generation

**Implementation Phase (After Tests Approved):**
- [ ] Implement model performance evaluation
- [ ] Implement intent classification metrics
- [ ] Implement model quality gates
- [ ] Implement evaluation report generation

#### 🧪 3.4 Pipeline Orchestration (TDD)
**Testing Phase (Write Tests First):**
- [ ] Test SageMaker Pipeline step creation
- [ ] Test step dependencies and parameters
- [ ] Test conditional execution logic
- [ ] Test pipeline parameter validation

**Implementation Phase (After Tests Approved):**
- [ ] Implement SageMaker Pipeline orchestration
- [ ] Implement step dependencies and parameters
- [ ] Implement conditional execution logic
- [ ] Implement error handling and retry mechanisms

#### 🔧 3.5 Configuration and Documentation
- [ ] Create environment-specific configs (dev/staging/prod)
- [ ] Create pipeline parameters (`pipelines/params.json`)
- [ ] Create requirements.txt with pinned versions (legacy compatibility)
- [ ] Create setup.py for package management (if needed for SageMaker)
- [ ] Write API documentation
- [ ] Write deployment guides
- [ ] Write troubleshooting guides

### ⏳ Phase 4: Model Registry & Compilation (TDD Approach) - PENDING
- [ ] **Write tests first** for model registry components:
  - [ ] Test SageMaker Model Registry integration
  - [ ] Test model approval workflow
  - [ ] Test model versioning and lineage tracking
  - [ ] Test Neo compilation process
- [ ] **Then implement** model registry and compilation:
  - [ ] Set up SageMaker Model Registry
  - [ ] Implement model approval workflow
  - [ ] Configure AWS SageMaker Neo compilation
  - [ ] Set up model versioning and lineage tracking

### ⏳ Phase 5: Edge Deployment Infrastructure (TDD Approach) - PENDING
- [ ] **Write tests first** for edge deployment:
  - [ ] Test IoT Greengrass v2 component creation
  - [ ] Test edge inference application
  - [ ] Test deployment recipes
  - [ ] Test device fleet management
- [ ] **Then implement** edge deployment:
  - [ ] Create IoT Greengrass v2 components
  - [ ] Implement edge inference application
  - [ ] Configure deployment recipes
  - [ ] Set up device fleet management

### ⏳ Phase 6: End-to-End Testing & CI/CD - PENDING
- [ ] **Integration Testing**:
  - [ ] End-to-end pipeline tests
  - [ ] Infrastructure tests (Terraform)
  - [ ] Model performance regression tests
  - [ ] Edge deployment smoke tests
- [ ] **CI/CD Pipeline**:
  - [ ] GitHub Actions workflows
  - [ ] Automated testing on PR
  - [ ] Automated deployment to staging
  - [ ] Manual promotion to production
- [ ] **Monitoring & Observability**:
  - [ ] CloudWatch metrics and alarms
  - [ ] Model drift detection
  - [ ] Performance monitoring dashboards

## Current Status & Next Steps

### 📊 Progress Summary
- **Pre-Phase 1**: ✅ **COMPLETED** - Project foundation with `.gitignore`
- **Phase 1**: ✅ **COMPLETED** - Python project setup with development environment
  - ✅ `pyproject.toml` created and refined with tooling-focused configuration
  - ✅ `make.ps1` PowerShell script created for development workflow
  - ✅ Ruff, Pyright, pytest configuration completed
  - ✅ Mocked AWS services setup completed
  - ✅ Pre-commit hooks configured
- **Phase 2-6**: ⏳ **PENDING** - Ready to begin Phase 2

### 🔍 Current Assessment
**What's Working:**
- Clean project structure established
- Modern Python project configuration (`pyproject.toml`) with dev dependencies
- Comprehensive `.gitignore` covering Python/ML/AWS/Terraform patterns
- TDD methodology clearly defined with granular approval process

**What Needs Attention:**
- No Terraform infrastructure files exist yet (despite earlier conversation references)
- Development workflow automation missing (`make.ps1` script)
- Testing infrastructure not yet established
- CI/CD pipeline not configured

**Critical Dependencies:**
- `make.ps1` script is foundation for all subsequent development workflows
- Infrastructure tests must be written before any Terraform implementation
- Mocked AWS services required for TDD approach validation

### 🎯 Immediate Next Action Required

**PHASE 1 COMPLETED SUCCESSFULLY! 🎉**

All Phase 1 items have been implemented:
- ✅ PowerShell development workflow script (`make.ps1`)
- ✅ Ruff linting and formatting configuration
- ✅ Pyright type checking configuration  
- ✅ Pytest test structure with fixtures and AWS mocking
- ✅ Pre-commit hooks for automated quality checks

**SEEKING APPROVAL FOR PHASE 2:**

**Phase 2**: Infrastructure Setup with TDD

The next phase focuses on creating Terraform infrastructure using a test-first approach. This includes:

1. **Infrastructure Testing Phase (Write Tests First)**:
   - Create infrastructure tests for Terraform validation
   - Write tests for S3 bucket creation and configuration
   - Write tests for S3 bucket policies and versioning
   - Write tests for S3 encryption and lifecycle policies
   - Write tests for IAM roles and permissions
   - Write tests for resource naming and tagging

2. **Infrastructure Implementation Phase (After Tests Written)**:
   - Create Terraform configuration for S3 buckets
   - Set up S3 buckets for data and artifacts
   - Configure bucket policies and versioning
   - Add encryption and lifecycle policies
   - Create IAM roles for SageMaker pipeline execution
   - Validate Terraform configuration passes all tests
   - Deploy infrastructure and verify tests pass

**Dependencies:** 
- ✅ Phase 1 (completed)
- ✅ Development environment ready
- ✅ Testing infrastructure in place

**Estimated Effort:** 3-4 hours
**Risk Level:** Medium (AWS infrastructure changes)
**Impact:** High (enables all subsequent ML pipeline development)

**Do you approve proceeding with Phase 2: Infrastructure Setup with TDD?**

---

## Notes on Copilot Instructions Compliance

✅ **Planning**: Detailed plan created with specific changes and checkboxes
✅ **No Implementation Without Approval**: Awaiting explicit approval for each item
✅ **Markdown Documentation**: Plan maintained in `docs/implementation-plan.md`
✅ **Production Standards**: TDD approach and best practices defined
✅ **Test-First Approach**: All phases structured with tests before implementation
✅ **Status Tracking**: Checkboxes updated inline as items complete

**Next Update**: Will mark `make.ps1` checkbox complete once approved and implemented.
