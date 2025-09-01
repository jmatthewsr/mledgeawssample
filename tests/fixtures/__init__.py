"""
Shared test fixtures and utilities for the ML Edge MLOps project.

This module provides common fixtures, mock objects, and utility functions
used across different test modules.
"""

import os
import tempfile
from collections.abc import Generator
from pathlib import Path
from typing import Any
from unittest.mock import Mock

import pytest


@pytest.fixture
def temp_dir() -> Generator[Path, None, None]:
    """Create a temporary directory for test files."""
    with tempfile.TemporaryDirectory() as tmp_dir:
        yield Path(tmp_dir)


@pytest.fixture
def sample_config() -> dict[str, Any]:
    """Sample configuration for tests."""
    return {
        "model": {"name": "test-model", "version": "1.0.0", "type": "classification"},
        "training": {"batch_size": 16, "learning_rate": 0.001, "epochs": 5},
        "aws": {"region": "us-east-1", "s3_bucket": "test-bucket"},
    }


@pytest.fixture
def mock_s3_client():
    """Mock S3 client for testing."""
    mock_client = Mock()
    mock_client.upload_file.return_value = None
    mock_client.download_file.return_value = None
    mock_client.list_objects_v2.return_value = {
        "Contents": [{"Key": "test-file.json", "Size": 1024}]
    }
    return mock_client


@pytest.fixture
def mock_sagemaker_client():
    """Mock SageMaker client for testing."""
    mock_client = Mock()
    mock_client.create_training_job.return_value = {
        "TrainingJobArn": "arn:aws:sagemaker:us-east-1:123456789012:training-job/test-job"
    }
    mock_client.describe_training_job.return_value = {"TrainingJobStatus": "Completed"}
    return mock_client


@pytest.fixture(autouse=True)
def setup_test_environment(monkeypatch):
    """Set up test environment variables."""
    test_env = {
        "AWS_ACCESS_KEY_ID": "test_access_key",
        "AWS_SECRET_ACCESS_KEY": "test_secret_key",
        "AWS_DEFAULT_REGION": "us-east-1",
        "PYTHONPATH": os.pathsep.join(
            [
                str(Path(__file__).parent.parent / "src"),
                os.environ.get("PYTHONPATH", ""),
            ]
        ),
    }

    for key, value in test_env.items():
        monkeypatch.setenv(key, value)


class MockModel:
    """Mock model class for testing."""

    def __init__(self, name: str = "test-model"):
        self.name = name
        self.is_trained = False

    def train(self, _data):
        """Mock training method."""
        self.is_trained = True
        return {"loss": 0.1, "accuracy": 0.95}

    def predict(self, _data):
        """Mock prediction method."""
        if not self.is_trained:
            raise ValueError("Model must be trained before prediction")
        return ["intent_1", "intent_2", "intent_3"]

    def save(self, path: str):
        """Mock save method."""
        Path(path).mkdir(parents=True, exist_ok=True)
        (Path(path) / "model.pkl").touch()


@pytest.fixture
def mock_model():
    """Fixture providing a mock model."""
    return MockModel()
