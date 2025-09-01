# Local Training Dependencies - Cost Optimized Setup
# Add these to your pyproject.toml [project.optional-dependencies]

local-training = [
    # Core ML libraries
    "torch>=2.0.0",
    "transformers>=4.30.0", 
    "datasets>=2.12.0",
    "peft>=0.4.0",  # For LoRA/QLoRA
    "bitsandbytes>=0.39.0",  # For quantization
    
    # Local MLflow tracking (free)
    "mlflow>=2.5.0",
    
    # AWS integration (minimal usage)
    "boto3>=1.28.0",
    "botocore>=1.31.0",
    
    # Data processing
    "pandas>=2.0.0",
    "numpy>=1.24.0",
    "scikit-learn>=1.3.0",
    
    # Monitoring (local)
    "wandb>=0.15.0",  # Optional: alternative to MLflow
    "tensorboard>=2.13.0",  # Optional: visualization
    
    # Development tools
    "jupyter>=1.0.0",
    "notebook>=6.5.0",
    "ipykernel>=6.25.0",
]

# Estimated local setup:
# - Hardware: Your existing computer (free)
# - Software: Open source libraries (free)
# - Storage: Local disk (free)
# - Cloud sync: Only final models and essential metrics

# Cost comparison:
# Local training: $0-5/month (cloud storage only)
# vs
# SageMaker training: $50-200/month (compute instances)
