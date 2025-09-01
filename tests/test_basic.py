"""
Test configuration and basic functionality.

This module contains basic tests to validate the test setup and configuration.
"""

import sys
from pathlib import Path


def test_project_structure():
    """Test that the project structure is properly set up."""
    project_root = Path(__file__).parent.parent

    # Check that key directories exist
    assert (project_root / "src").exists(), "src directory should exist"
    assert (project_root / "tests").exists(), "tests directory should exist"
    assert (project_root / "docs").exists(), "docs directory should exist"
    assert (project_root / "infra").exists(), "infra directory should exist"

    # Check that key files exist
    assert (project_root / "pyproject.toml").exists(), "pyproject.toml should exist"
    assert (project_root / "make.ps1").exists(), "make.ps1 should exist"
    assert (project_root / ".gitignore").exists(), ".gitignore should exist"


def test_python_version():
    """Test that Python version meets requirements."""
    assert sys.version_info >= (3, 9), "Python 3.9+ is required"


def test_imports():
    """Test that basic imports work."""
    import tempfile
    from pathlib import Path
    from unittest.mock import Mock

    # Basic functionality test
    mock = Mock()
    mock.test_method.return_value = "test"
    assert mock.test_method() == "test"

    # Path operations
    test_path = Path(tempfile.gettempdir())
    assert test_path.exists()


if __name__ == "__main__":
    test_project_structure()
    test_python_version()
    test_imports()
    print("✅ All basic tests passed!")
