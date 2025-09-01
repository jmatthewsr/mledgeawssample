* add items in readme for tools setup (aws cli, terraform)
* adjust copilot-instructions for production grade, TDD and plan+approval+execute process
* keeping the plan high level and iterate is the intended approach, see how this works out, vs spending time on a detailed plan upfront.
* After asking gpt to build a prompt based on the plan created, that would have created a similar plan:

```
I have a project that needs an implementation plan. Please follow the copilot instructions exactly:

**Copilot Instructions:**
* Always plan out any new changes before implementing them. Give the specific changes to be made and a checkbox to track progress.
* After creating the plan, do NOT start the implementation. Ask for feedback and wait for approval for each item within each step that is required to be marked complete.
* Write the plan out to a markdown file in the `docs` directory.
* Follow production level coding standards and best practices.
* Use a test first approach (e.g. TDD) for infra, code and model related training, evaluation and deployment.

**Project Description:**
Create an ML edge project that fine-tunes a small language model for intent classification using AWS services. The project should:

1. Use SageMaker for training and model management
2. Implement proper MLOps practices with pipelines
3. Deploy models to edge devices using AWS IoT Greengrass v2
4. Include data processing, training, evaluation, and deployment phases
5. Use modern Python tooling and infrastructure as code
6. Follow test-driven development principles
7. Target Windows development environment with PowerShell

**Requirements:**
- Modern Python project setup with pyproject.toml
- Terraform for AWS infrastructure
- SageMaker Pipelines for ML workflow
- Edge deployment with IoT Greengrass v2
- Comprehensive testing strategy
- CI/CD pipeline
- Production-level code quality standards

Please create a detailed implementation plan that follows TDD principles and requires individual approval for each task before implementation. The plan should be structured in logical phases and include specific, actionable items with checkboxes for tracking progress.
## Phase 1 Notes
* some errors in the make.ps1 script, were identified and fixed
* need to manually validate all make functions

