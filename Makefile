.PHONY: help setup install clean test lint format dbt-run dbt-test quality upload-data terraform-init terraform-plan terraform-apply

help:
	@echo "Available commands:"
	@echo "  make setup          - Create virtual environment and install dependencies"
	@echo "  make install        - Install Python dependencies"
	@echo "  make clean          - Remove generated files and caches"
	@echo "  make test           - Run Python tests"
	@echo "  make lint           - Run linters (flake8, sqlfluff)"
	@echo "  make format         - Format code (black, isort)"
	@echo "  make generate-data  - Generate sample datasets"
	@echo "  make upload-data    - Upload data to S3"
	@echo "  make dbt-deps       - Install dbt dependencies"
	@echo "  make dbt-run        - Run dbt models"
	@echo "  make dbt-test       - Run dbt tests"
	@echo "  make dbt-docs       - Generate dbt documentation"
	@echo "  make quality        - Run data quality checks"
	@echo "  make terraform-init - Initialize Terraform"
	@echo "  make terraform-plan - Plan Terraform changes"
	@echo "  make terraform-apply- Apply Terraform changes"

setup:
	python3 -m venv venv
	. venv/bin/activate && pip install --upgrade pip
	. venv/bin/activate && pip install -r requirements.txt

install:
	pip install -r requirements.txt

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	rm -rf dbt_project/target/
	rm -rf dbt_project/logs/
	rm -rf .pytest_cache/
	rm -rf htmlcov/
	rm -rf sample_data/*.csv sample_data/*.parquet

test:
	pytest

lint:
	flake8 scripts/ --max-line-length=100
	sqlfluff lint dbt_project/models/

format:
	black scripts/
	isort scripts/

generate-data:
	python scripts/generate_sample_data.py

upload-data:
	python scripts/upload_to_s3.py

dbt-deps:
	cd dbt_project && dbt deps

dbt-run:
	cd dbt_project && dbt run

dbt-test:
	cd dbt_project && dbt test

dbt-docs:
	cd dbt_project && dbt docs generate
	cd dbt_project && dbt docs serve

quality:
	python scripts/run_data_quality.py

terraform-init:
	cd terraform && terraform init

terraform-plan:
	cd terraform && terraform plan

terraform-apply:
	cd terraform && terraform apply

