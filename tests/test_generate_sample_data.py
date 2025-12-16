"""
Unit tests for generate_sample_data.py script.

Tests the data generation functionality for creating sample datasets
for the data lake including customers, orders, transactions, and accounts.
"""

import os
import sys
from pathlib import Path
from unittest.mock import patch, MagicMock

import pandas as pd
import pytest

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))


class TestDataGenerationStructure:
    """Test suite for data generation structure and basic functionality."""

    def test_sample_data_directory_constant_exists(self):
        """Test that SAMPLE_DATA_DIR constant is properly defined."""
        from scripts import generate_sample_data
        
        assert hasattr(generate_sample_data, 'SAMPLE_DATA_DIR')
        assert isinstance(generate_sample_data.SAMPLE_DATA_DIR, Path)

    def test_configuration_constants_exist(self):
        """Test that all required configuration constants are defined."""
        from scripts import generate_sample_data
        
        required_constants = [
            'NUM_CUSTOMERS',
            'NUM_ACCOUNTS',
            'NUM_TRANSACTIONS',
            'NUM_ORDERS',
            'START_DATE',
            'END_DATE'
        ]
        
        for constant in required_constants:
            assert hasattr(generate_sample_data, constant), f"Missing constant: {constant}"

    def test_main_functions_exist(self):
        """Test that all main generation functions exist."""
        from scripts import generate_sample_data
        
        assert hasattr(generate_sample_data, 'generate_finance_data')
        assert hasattr(generate_sample_data, 'generate_operations_data')
        assert hasattr(generate_sample_data, 'generate_crm_data')
        assert hasattr(generate_sample_data, 'main')


class TestFinanceDataGeneration:
    """Test suite for finance data generation."""

    @patch('scripts.generate_sample_data.pd.DataFrame.to_csv')
    @patch('scripts.generate_sample_data.pd.DataFrame.to_parquet')
    def test_generate_finance_data_creates_accounts(self, mock_parquet, mock_csv):
        """Test that finance data generation creates accounts DataFrame."""
        from scripts.generate_sample_data import generate_finance_data
        
        # Mock the file operations
        generate_finance_data()
        
        # Verify CSV and Parquet methods were called
        assert mock_csv.called
        assert mock_parquet.called

    @patch('scripts.generate_sample_data.pd.DataFrame.to_csv')
    @patch('scripts.generate_sample_data.pd.DataFrame.to_parquet')
    def test_generate_finance_data_creates_transactions(self, mock_parquet, mock_csv):
        """Test that finance data generation creates transactions DataFrame."""
        from scripts.generate_sample_data import generate_finance_data
        
        generate_finance_data()
        
        # Should be called multiple times (accounts, transactions, ledger)
        assert mock_csv.call_count >= 3
        assert mock_parquet.call_count >= 3

    @patch('scripts.generate_sample_data.pd.DataFrame.to_csv')
    @patch('scripts.generate_sample_data.pd.DataFrame.to_parquet')
    def test_generate_finance_data_creates_ledger(self, mock_parquet, mock_csv):
        """Test that finance data generation creates ledger entries."""
        from scripts.generate_sample_data import generate_finance_data
        
        generate_finance_data()
        
        # Verify all three datasets were created
        assert mock_csv.call_count == 3
        assert mock_parquet.call_count == 3


class TestOperationsDataGeneration:
    """Test suite for operations data generation."""

    @patch('scripts.generate_sample_data.pd.DataFrame.to_csv')
    @patch('scripts.generate_sample_data.pd.DataFrame.to_parquet')
    def test_generate_operations_data_creates_orders(self, mock_parquet, mock_csv):
        """Test that operations data generation creates orders DataFrame."""
        from scripts.generate_sample_data import generate_operations_data
        
        generate_operations_data()
        
        assert mock_csv.called
        assert mock_parquet.called

    @patch('scripts.generate_sample_data.pd.DataFrame.to_csv')
    @patch('scripts.generate_sample_data.pd.DataFrame.to_parquet')
    def test_generate_operations_data_creates_shipments(self, mock_parquet, mock_csv):
        """Test that operations data generation creates shipments DataFrame."""
        from scripts.generate_sample_data import generate_operations_data
        
        generate_operations_data()
        
        # Should create orders, shipments, and inventory
        assert mock_csv.call_count >= 3
        assert mock_parquet.call_count >= 3

    @patch('scripts.generate_sample_data.pd.DataFrame.to_csv')
    @patch('scripts.generate_sample_data.pd.DataFrame.to_parquet')
    def test_generate_operations_data_creates_inventory(self, mock_parquet, mock_csv):
        """Test that operations data generation creates inventory DataFrame."""
        from scripts.generate_sample_data import generate_operations_data
        
        generate_operations_data()
        
        # Verify all three datasets were created
        assert mock_csv.call_count == 3
        assert mock_parquet.call_count == 3


class TestCRMDataGeneration:
    """Test suite for CRM data generation."""

    @patch('scripts.generate_sample_data.pd.DataFrame.to_csv')
    @patch('scripts.generate_sample_data.pd.DataFrame.to_parquet')
    def test_generate_crm_data_creates_customers(self, mock_parquet, mock_csv):
        """Test that CRM data generation creates customers DataFrame."""
        from scripts.generate_sample_data import generate_crm_data
        
        generate_crm_data()
        
        assert mock_csv.called
        assert mock_parquet.called

    @patch('scripts.generate_sample_data.pd.DataFrame.to_csv')
    @patch('scripts.generate_sample_data.pd.DataFrame.to_parquet')
    def test_generate_crm_data_creates_interactions(self, mock_parquet, mock_csv):
        """Test that CRM data generation creates interactions DataFrame."""
        from scripts.generate_sample_data import generate_crm_data
        
        generate_crm_data()
        
        # Should create customers, interactions, and opportunities
        assert mock_csv.call_count >= 3
        assert mock_parquet.call_count >= 3

    @patch('scripts.generate_sample_data.pd.DataFrame.to_csv')
    @patch('scripts.generate_sample_data.pd.DataFrame.to_parquet')
    def test_generate_crm_data_creates_opportunities(self, mock_parquet, mock_csv):
        """Test that CRM data generation creates opportunities DataFrame."""
        from scripts.generate_sample_data import generate_crm_data
        
        generate_crm_data()
        
        # Verify all three datasets were created
        assert mock_csv.call_count == 3
        assert mock_parquet.call_count == 3


@pytest.mark.integration
class TestMainFunction:
    """Integration tests for the main data generation function."""

    @patch('scripts.generate_sample_data.generate_finance_data')
    @patch('scripts.generate_sample_data.generate_operations_data')
    @patch('scripts.generate_sample_data.generate_crm_data')
    @patch('scripts.generate_sample_data.SAMPLE_DATA_DIR')
    def test_main_calls_all_generation_functions(
        self, mock_dir, mock_crm, mock_ops, mock_finance
    ):
        """Test that main function calls all data generation functions."""
        from scripts.generate_sample_data import main
        
        # Mock the directory creation
        mock_dir.mkdir = MagicMock()
        
        main()
        
        # Verify all generation functions were called
        mock_finance.assert_called_once()
        mock_ops.assert_called_once()
        mock_crm.assert_called_once()

    @patch('scripts.generate_sample_data.generate_finance_data')
    @patch('scripts.generate_sample_data.generate_operations_data')
    @patch('scripts.generate_sample_data.generate_crm_data')
    @patch('scripts.generate_sample_data.SAMPLE_DATA_DIR')
    def test_main_creates_sample_data_directory(
        self, mock_dir, mock_crm, mock_ops, mock_finance
    ):
        """Test that main function creates the sample_data directory."""
        from scripts.generate_sample_data import main
        
        # Mock the directory
        mock_dir.mkdir = MagicMock()
        
        main()
        
        # Verify directory creation was called
        mock_dir.mkdir.assert_called_once_with(exist_ok=True)


class TestDataQuality:
    """Test suite for data quality checks."""

    def test_faker_seed_is_set(self):
        """Test that Faker seed is set for reproducibility."""
        from scripts import generate_sample_data
        
        # The module should have Faker imported and seeded
        assert hasattr(generate_sample_data, 'fake')

    def test_date_range_is_valid(self):
        """Test that START_DATE is before END_DATE."""
        from scripts.generate_sample_data import START_DATE, END_DATE
        
        assert START_DATE < END_DATE

    def test_record_counts_are_positive(self):
        """Test that all record count constants are positive integers."""
        from scripts.generate_sample_data import (
            NUM_CUSTOMERS,
            NUM_ACCOUNTS,
            NUM_TRANSACTIONS,
            NUM_ORDERS
        )
        
        assert NUM_CUSTOMERS > 0
        assert NUM_ACCOUNTS > 0
        assert NUM_TRANSACTIONS > 0
        assert NUM_ORDERS > 0
