"""
Pytest configuration and shared fixtures for the test suite.

This module contains shared fixtures and configuration used across
all test modules in the dbtDataLake project.
"""

import os
import sys
from pathlib import Path

import pytest


# Add the project root to the Python path for imports
@pytest.fixture(scope="session", autouse=True)
def add_project_to_path():
    """Add the project root directory to sys.path for imports."""
    project_root = Path(__file__).parent.parent
    sys.path.insert(0, str(project_root))
    yield
    # Cleanup
    sys.path.remove(str(project_root))


@pytest.fixture(scope="session")
def project_root():
    """Provide the project root directory path."""
    return Path(__file__).parent.parent


@pytest.fixture(scope="session")
def sample_data_dir(project_root):
    """Provide the sample_data directory path."""
    return project_root / "sample_data"


@pytest.fixture(scope="session")
def scripts_dir(project_root):
    """Provide the scripts directory path."""
    return project_root / "scripts"


@pytest.fixture
def mock_env_vars(monkeypatch):
    """Provide mock environment variables for testing."""
    test_env_vars = {
        "SNOWFLAKE_ACCOUNT": "test_account",
        "SNOWFLAKE_USER": "test_user",
        "SNOWFLAKE_PASSWORD": "test_password",
        "SNOWFLAKE_ROLE": "test_role",
        "AWS_ACCESS_KEY_ID": "test_aws_key",
        "AWS_SECRET_ACCESS_KEY": "test_aws_secret",
        "S3_BUCKET_NAME": "test-bucket",
    }
    
    for key, value in test_env_vars.items():
        monkeypatch.setenv(key, value)
    
    return test_env_vars


@pytest.fixture
def temp_output_dir(tmp_path):
    """Provide a temporary directory for test output files."""
    output_dir = tmp_path / "test_output"
    output_dir.mkdir(exist_ok=True)
    return output_dir

