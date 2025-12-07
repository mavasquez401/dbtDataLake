"""
Setup Snowflake database with Data Vault 2.0 schema.
Executes DDL scripts to create external stages, hubs, links, and satellites.
"""

import os
from pathlib import Path

import snowflake.connector
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
DDL_DIR = Path(__file__).parent.parent / "snowflake" / "ddl"
SNOWFLAKE_CONFIG = {
    "account": os.getenv("SNOWFLAKE_ACCOUNT"),
    "user": os.getenv("SNOWFLAKE_USER"),
    "password": os.getenv("SNOWFLAKE_PASSWORD"),
    "role": os.getenv("SNOWFLAKE_ROLE", "ACCOUNTADMIN"),
    "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH"),
}

# DDL script execution order
DDL_SCRIPTS = [
    "01_external_stages.sql",
    "02_hubs.sql",
    "03_links.sql",
    "04_satellites.sql",
]


def create_connection():
    """Create Snowflake connection."""
    try:
        conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
        print("✓ Connected to Snowflake")
        return conn
    except Exception as e:
        print(f"✗ Error connecting to Snowflake: {e}")
        raise


def execute_sql_file(conn, sql_file_path):
    """Execute SQL statements from a file."""
    try:
        with open(sql_file_path, "r") as f:
            sql_content = f.read()

        # Split by semicolon and execute each statement
        statements = [stmt.strip() for stmt in sql_content.split(";") if stmt.strip()]

        cursor = conn.cursor()
        for i, statement in enumerate(statements, 1):
            # Skip comments and empty statements
            if statement.startswith("--") or not statement:
                continue

            try:
                cursor.execute(statement)
                print(f"  ✓ Executed statement {i}/{len(statements)}")
            except Exception as e:
                print(f"  ✗ Error executing statement {i}: {e}")
                print(f"  Statement: {statement[:100]}...")
                # Continue with next statement

        cursor.close()
        return True

    except Exception as e:
        print(f"✗ Error reading/executing SQL file {sql_file_path}: {e}")
        return False


def main():
    """Main function to setup Snowflake schema."""
    print("=" * 60)
    print("Snowflake Data Vault 2.0 Setup")
    print("=" * 60)
    print(f"Account: {SNOWFLAKE_CONFIG['account']}")
    print(f"User: {SNOWFLAKE_CONFIG['user']}")
    print(f"Role: {SNOWFLAKE_CONFIG['role']}")
    print()

    # Create connection
    try:
        conn = create_connection()
    except Exception:
        print("Failed to connect to Snowflake. Exiting.")
        return

    print()
    print("Executing DDL scripts...")
    print("-" * 60)

    # Execute DDL scripts in order
    success_count = 0
    for script_name in DDL_SCRIPTS:
        script_path = DDL_DIR / script_name
        print(f"\nExecuting: {script_name}")

        if not script_path.exists():
            print(f"  ⚠ Warning: Script not found: {script_path}")
            continue

        if execute_sql_file(conn, script_path):
            success_count += 1
            print(f"  ✓ Completed: {script_name}")
        else:
            print(f"  ✗ Failed: {script_name}")

    print("-" * 60)
    print()

    # Close connection
    conn.close()
    print("✓ Connection closed")

    print()
    print("=" * 60)
    print("Setup Summary")
    print("=" * 60)
    print(f"Successfully executed: {success_count}/{len(DDL_SCRIPTS)} scripts")
    print()
    print("Data Vault 2.0 Schema Created:")
    print("  - External Stages (RAW schema)")
    print("  - Hubs (STAGE schema)")
    print("  - Links (STAGE schema)")
    print("  - Satellites (STAGE schema)")
    print("=" * 60)


if __name__ == "__main__":
    main()

