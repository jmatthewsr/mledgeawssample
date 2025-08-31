# ML Edge Project with AWS
## 📌 Project Goal

Fine-tune a small language model (SLM) for intent classification, then build an AWS-based pipeline that:

Trains & evaluates the model,

Registers versions with a Model Registry,

Compiles the model for the edge with AWS Neo,

Deploys to a device using AWS IoT Greengrass v2.

## 🗂️ Repo Layout
```bash
slm-edge-mlops/
├─ pipelines/
│  ├─ build_pipeline.py
│  └─ params.json
├─ src/
│  ├─ processing/prepare_data.py
│  ├─ training/train.py
│  ├─ evaluation/evaluate.py
│  └─ inference/handler.py
├─ edge/
│  ├─ app/greengrass_infer.py
│  ├─ recipe.yaml
│  └─ requirements.txt
├─ tests/
│  ├─ test_processing.py
│  ├─ test_training.py
│  ├─ test_evaluation.py
│  └─ test_edge_smoke.py
├─ gx/        # Great Expectations project
├─ infra/     # S3, IAM templates
└─ README.md
```
## 🛠️ Step 1 — Data Preparation & Validation

Choose a small dataset (e.g., SNIPS intents).

Format as CSV: text,intent.

Add Great Expectations checks:

No missing rows.

Labels in whitelist.

Train/val/test split ratios.

Store in S3:

s3://slm-intents/raw/

s3://slm-intents/processed/

## 🛠️ Step 2 — Build the Pipeline

Use SageMaker Pipelines:

ProcessingStep → run prepare_data.py

TrainingStep → run train.py (fine-tunes a MiniLM/TinyBERT)

ProcessingStep (Evaluation) → run evaluate.py and save metrics.json

ConditionStep → only continue if F1 ≥ threshold

RegisterModel → push model to Model Registry (stage = “Staging”)

CompilationStep (Neo) → compile for linux_arm64 (edge target)

## 🛠️ Step 3 — Model Registry & Promotion

Approve “Staging” models into “Prod” once metrics look good.

Registry tracks lineage, metrics, artifacts.

Store Neo-compiled artifact in S3 under /edge/.

## 🛠️ Step 4 — Edge Deployment

Configure AWS IoT Greengrass v2 core device.

Create two components:

Model component: Neo-compiled model artifact.

App component: greengrass_infer.py for inference.

Deploy via Greengrass console/CLI to the edge device.

## 🛠️ Step 5 — Testing

Data tests: Great Expectations checks run in ProcessingStep.

Unit tests: pytest for prepare_data.py, tokenization correctness.

Eval tests: metrics ≥ threshold, validated by ConditionStep.

Edge smoke tests: run inference on-device; check latency & RAM.

## 🛠️ Step 6 — CI/CD Integration

Option 1: Pure SageMaker Pipelines for end-to-end orchestration.

Option 2: CodePipeline + CodeBuild → trigger pipeline, run tests, approve promotion.

## 🌟 Stretch Goals

Add quantization (INT8) for faster inference.

Collect edge telemetry (confidence scores, drift signals).

Run a shadow deployment (compare cloud vs edge outputs).

Staged rollouts across fleets with Greengrass deployment groups.

## ⚡ With this plan, you cover:

ML basics (train/test split, metrics, overfitting),

AWS ML stack (SageMaker Pipelines, Registry, Neo),

Edge deployment (Greengrass),

MLOps practices (tests, promotion gates).