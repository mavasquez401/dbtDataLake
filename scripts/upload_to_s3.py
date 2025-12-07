"""
Upload sample datasets to AWS S3 following the data lake folder structure.
Organizes data by producer: finance/, operations/, crm/
"""

import os
from pathlib import Path

import boto3
from botocore.exceptions import ClientError
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
SAMPLE_DATA_DIR = Path(__file__).parent.parent / "sample_data"
S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME", "institutional-data-lake")
AWS_REGION = os.getenv("AWS_DEFAULT_REGION", "us-east-1")

# Define file mappings: local file -> S3 path
FILE_MAPPINGS = {
    # Finance files
    "finance_accounts.parquet": "finance/accounts/finance_accounts.parquet",
    "finance_transactions.parquet": "finance/transactions/finance_transactions.parquet",
    "finance_ledger.parquet": "finance/ledger/finance_ledger.parquet",
    # Operations files
    "operations_orders.parquet": "operations/orders/operations_orders.parquet",
    "operations_shipments.parquet": "operations/shipments/operations_shipments.parquet",
    "operations_inventory.parquet": "operations/inventory/operations_inventory.parquet",
    # CRM files
    "crm_customers.parquet": "crm/customers/crm_customers.parquet",
    "crm_interactions.parquet": "crm/interactions/crm_interactions.parquet",
    "crm_opportunities.parquet": "crm/opportunities/crm_opportunities.parquet",
}


def create_s3_client():
    """Create and return an S3 client."""
    try:
        s3_client = boto3.client("s3", region_name=AWS_REGION)
        return s3_client
    except Exception as e:
        print(f"Error creating S3 client: {e}")
        raise


def check_bucket_exists(s3_client, bucket_name):
    """Check if S3 bucket exists."""
    try:
        s3_client.head_bucket(Bucket=bucket_name)
        return True
    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        if error_code == "404":
            return False
        else:
            raise


def create_bucket(s3_client, bucket_name, region):
    """Create S3 bucket if it doesn't exist."""
    try:
        if region == "us-east-1":
            s3_client.create_bucket(Bucket=bucket_name)
        else:
            s3_client.create_bucket(
                Bucket=bucket_name, CreateBucketConfiguration={"LocationConstraint": region}
            )
        print(f"✓ Created bucket: {bucket_name}")
        return True
    except ClientError as e:
        print(f"Error creating bucket: {e}")
        return False


def upload_file(s3_client, local_file, bucket_name, s3_key):
    """Upload a file to S3."""
    try:
        s3_client.upload_file(str(local_file), bucket_name, s3_key)
        print(f"  ✓ Uploaded: {local_file.name} -> s3://{bucket_name}/{s3_key}")
        return True
    except ClientError as e:
        print(f"  ✗ Error uploading {local_file.name}: {e}")
        return False


def upload_all_files(s3_client, bucket_name):
    """Upload all sample data files to S3."""
    success_count = 0
    fail_count = 0

    for local_filename, s3_key in FILE_MAPPINGS.items():
        local_file = SAMPLE_DATA_DIR / local_filename

        if not local_file.exists():
            print(f"  ⚠ Warning: File not found: {local_file}")
            fail_count += 1
            continue

        if upload_file(s3_client, local_file, bucket_name, s3_key):
            success_count += 1
        else:
            fail_count += 1

    return success_count, fail_count


def main():
    """Main function to upload data to S3."""
    print("=" * 60)
    print("S3 Data Upload")
    print("=" * 60)
    print(f"Bucket: {S3_BUCKET_NAME}")
    print(f"Region: {AWS_REGION}")
    print()

    # Create S3 client
    try:
        s3_client = create_s3_client()
    except Exception as e:
        print(f"Failed to create S3 client: {e}")
        return

    # Check if bucket exists, create if not
    if not check_bucket_exists(s3_client, S3_BUCKET_NAME):
        print(f"Bucket '{S3_BUCKET_NAME}' does not exist. Creating...")
        if not create_bucket(s3_client, S3_BUCKET_NAME, AWS_REGION):
            print("Failed to create bucket. Exiting.")
            return
    else:
        print(f"✓ Bucket '{S3_BUCKET_NAME}' exists")

    print()
    print("Uploading files...")
    print("-" * 60)

    # Upload all files
    success_count, fail_count = upload_all_files(s3_client, S3_BUCKET_NAME)

    print("-" * 60)
    print()
    print("=" * 60)
    print("Upload Summary")
    print("=" * 60)
    print(f"Successfully uploaded: {success_count} files")
    print(f"Failed uploads: {fail_count} files")
    print()
    print("S3 Folder Structure:")
    print(f"  s3://{S3_BUCKET_NAME}/finance/")
    print(f"  s3://{S3_BUCKET_NAME}/operations/")
    print(f"  s3://{S3_BUCKET_NAME}/crm/")
    print("=" * 60)


if __name__ == "__main__":
    main()

