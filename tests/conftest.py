"""
Pytest configuration and global fixtures.

This module configures pytest and provides global fixtures for all tests.
"""

import os
from pathlib import Path

import pytest


# Configure pytest
def pytest_configure(config):
    """Configure pytest with custom settings."""
    # Add custom markers
    config.addinivalue_line(
        "markers", "slow: marks tests as slow (deselect with '-m \"not slow\"')"
    )
    config.addinivalue_line("markers", "integration: marks tests as integration tests")
    config.addinivalue_line("markers", "unit: marks tests as unit tests")
    config.addinivalue_line(
        "markers", "aws: marks tests that require AWS services (mocked or real)"
    )
    config.addinivalue_line("markers", "gpu: marks tests that require GPU")
    config.addinivalue_line("markers", "model: marks tests that require model files")


@pytest.fixture(scope="session", autouse=True)
def setup_test_environment():
    """Set up test environment for the entire test session."""
    # Set test environment variables
    test_env = {
        "AWS_ACCESS_KEY_ID": "testing",
        "AWS_SECRET_ACCESS_KEY": "testing",
        "AWS_SECURITY_TOKEN": "testing",
        "AWS_SESSION_TOKEN": "testing",
        "AWS_DEFAULT_REGION": "us-east-1",
        "PYTHONPATH": str(Path(__file__).parent / "src"),
    }

    # Store original values to restore later
    original_env = {}
    for key, value in test_env.items():
        original_env[key] = os.environ.get(key)
        os.environ[key] = value

    yield

    # Restore original environment
    for key, value in original_env.items():
        if value is None:
            os.environ.pop(key, None)
        else:
            os.environ[key] = value


@pytest.fixture
def project_root():
    """Get the project root directory."""
    return Path(__file__).parent.parent


@pytest.fixture
def src_dir(project_root):
    """Get the src directory."""
    return project_root / "src"


@pytest.fixture
def tests_dir(project_root):
    """Get the tests directory."""
    return project_root / "tests"
