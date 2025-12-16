"""
Generate realistic sample datasets for Finance, Operations, and CRM domains.
This script creates CSV and Parquet files with synthetic data using Faker.
"""

import os
from datetime import datetime, timedelta
from pathlib import Path

import pandas as pd
from faker import Faker

# Initialize Faker for data generation
fake = Faker()
Faker.seed(42)  # For reproducibility

# Configuration
SAMPLE_DATA_DIR = Path(__file__).parent.parent / "sample_data"
NUM_CUSTOMERS = 1000
NUM_ACCOUNTS = 1500
NUM_TRANSACTIONS = 5000
NUM_ORDERS = 2000
NUM_SHIPMENTS = 1800
NUM_INTERACTIONS = 3000
START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2024, 12, 31)


def generate_finance_data():
    """Generate finance domain datasets: accounts, transactions, ledger entries."""
    print("Generating Finance data...")

    # Generate Accounts
    accounts = []
    for i in range(NUM_ACCOUNTS):
        account = {
            "account_id": f"ACC{i+1:06d}",
            "account_number": fake.bban(),
            "account_type": fake.random_element(
                elements=("CHECKING", "SAVINGS", "INVESTMENT", "CREDIT")
            ),
            "account_status": fake.random_element(
                elements=("ACTIVE", "CLOSED", "SUSPENDED")
            ),
            "balance": round(fake.random.uniform(100, 100000), 2),
            "currency": "USD",
            "open_date": fake.date_between(start_date=START_DATE, end_date=END_DATE),
            "customer_id": f"CUST{fake.random_int(min=1, max=NUM_CUSTOMERS):06d}",
            "created_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
            "updated_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
        }
        accounts.append(account)

    accounts_df = pd.DataFrame(accounts)
    accounts_df.to_csv(SAMPLE_DATA_DIR / "finance_accounts.csv", index=False)
    accounts_df.to_parquet(SAMPLE_DATA_DIR / "finance_accounts.parquet", index=False)
    print(f"  ✓ Generated {len(accounts_df)} accounts")

    # Generate Transactions
    transactions = []
    for i in range(NUM_TRANSACTIONS):
        transaction = {
            "transaction_id": f"TXN{i+1:08d}",
            "account_id": f"ACC{fake.random_int(min=1, max=NUM_ACCOUNTS):06d}",
            "transaction_type": fake.random_element(
                elements=("DEPOSIT", "WITHDRAWAL", "TRANSFER", "PAYMENT", "FEE")
            ),
            "amount": round(fake.random.uniform(10, 5000), 2),
            "currency": "USD",
            "transaction_date": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
            "description": fake.sentence(nb_words=6),
            "merchant": fake.company()
            if fake.boolean(chance_of_getting_true=70)
            else None,
            "category": fake.random_element(
                elements=(
                    "RETAIL",
                    "FOOD",
                    "TRAVEL",
                    "UTILITIES",
                    "HEALTHCARE",
                    "OTHER",
                )
            ),
            "status": fake.random_element(elements=("COMPLETED", "PENDING", "FAILED")),
            "created_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
        }
        transactions.append(transaction)

    transactions_df = pd.DataFrame(transactions)
    transactions_df.to_csv(SAMPLE_DATA_DIR / "finance_transactions.csv", index=False)
    transactions_df.to_parquet(
        SAMPLE_DATA_DIR / "finance_transactions.parquet", index=False
    )
    print(f"  ✓ Generated {len(transactions_df)} transactions")

    # Generate Ledger Entries
    ledger_entries = []
    for i in range(NUM_TRANSACTIONS):
        # Create debit and credit entries for each transaction
        transaction_id = f"TXN{i+1:08d}"
        amount = round(fake.random.uniform(10, 5000), 2)
        entry_date = fake.date_time_between(start_date=START_DATE, end_date=END_DATE)

        # Debit entry
        ledger_entries.append(
            {
                "ledger_entry_id": f"LED{i*2+1:08d}",
                "transaction_id": transaction_id,
                "account_id": f"ACC{fake.random_int(min=1, max=NUM_ACCOUNTS):06d}",
                "entry_type": "DEBIT",
                "amount": amount,
                "entry_date": entry_date,
                "description": fake.sentence(nb_words=4),
                "created_at": entry_date,
            }
        )

        # Credit entry
        ledger_entries.append(
            {
                "ledger_entry_id": f"LED{i*2+2:08d}",
                "transaction_id": transaction_id,
                "account_id": f"ACC{fake.random_int(min=1, max=NUM_ACCOUNTS):06d}",
                "entry_type": "CREDIT",
                "amount": amount,
                "entry_date": entry_date,
                "description": fake.sentence(nb_words=4),
                "created_at": entry_date,
            }
        )

    ledger_df = pd.DataFrame(ledger_entries)
    ledger_df.to_csv(SAMPLE_DATA_DIR / "finance_ledger.csv", index=False)
    ledger_df.to_parquet(SAMPLE_DATA_DIR / "finance_ledger.parquet", index=False)
    print(f"  ✓ Generated {len(ledger_df)} ledger entries")


def generate_operations_data():
    """Generate operations domain datasets: orders, shipments, inventory."""
    print("Generating Operations data...")

    # Generate Orders
    orders = []
    for i in range(NUM_ORDERS):
        order = {
            "order_id": f"ORD{i+1:08d}",
            "customer_id": f"CUST{fake.random_int(min=1, max=NUM_CUSTOMERS):06d}",
            "order_date": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
            "order_status": fake.random_element(
                elements=(
                    "PENDING",
                    "PROCESSING",
                    "SHIPPED",
                    "DELIVERED",
                    "CANCELLED",
                )
            ),
            "order_total": round(fake.random.uniform(50, 5000), 2),
            "currency": "USD",
            "payment_method": fake.random_element(
                elements=("CREDIT_CARD", "DEBIT_CARD", "BANK_TRANSFER", "PAYPAL")
            ),
            "shipping_address": fake.address().replace("\n", ", "),
            "billing_address": fake.address().replace("\n", ", "),
            "priority": fake.random_element(
                elements=("LOW", "MEDIUM", "HIGH", "URGENT")
            ),
            "created_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
            "updated_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
        }
        orders.append(order)

    orders_df = pd.DataFrame(orders)
    orders_df.to_csv(SAMPLE_DATA_DIR / "operations_orders.csv", index=False)
    orders_df.to_parquet(SAMPLE_DATA_DIR / "operations_orders.parquet", index=False)
    print(f"  ✓ Generated {len(orders_df)} orders")

    # Generate Shipments
    shipments = []
    for i in range(NUM_SHIPMENTS):
        ship_date = fake.date_time_between(start_date=START_DATE, end_date=END_DATE)
        delivery_date = ship_date + timedelta(days=fake.random_int(min=1, max=10))

        shipment = {
            "shipment_id": f"SHIP{i+1:08d}",
            "order_id": f"ORD{fake.random_int(min=1, max=NUM_ORDERS):08d}",
            "carrier": fake.random_element(elements=("UPS", "FedEx", "USPS", "DHL")),
            "tracking_number": fake.bothify(text="??########??"),
            "ship_date": ship_date,
            "estimated_delivery": delivery_date,
            "actual_delivery": delivery_date
            if fake.boolean(chance_of_getting_true=80)
            else None,
            "shipment_status": fake.random_element(
                elements=("IN_TRANSIT", "DELIVERED", "DELAYED", "RETURNED")
            ),
            "weight_kg": round(fake.random.uniform(0.5, 50), 2),
            "shipping_cost": round(fake.random.uniform(5, 100), 2),
            "created_at": ship_date,
            "updated_at": fake.date_time_between(
                start_date=ship_date, end_date=END_DATE
            ),
        }
        shipments.append(shipment)

    shipments_df = pd.DataFrame(shipments)
    shipments_df.to_csv(SAMPLE_DATA_DIR / "operations_shipments.csv", index=False)
    shipments_df.to_parquet(
        SAMPLE_DATA_DIR / "operations_shipments.parquet", index=False
    )
    print(f"  ✓ Generated {len(shipments_df)} shipments")

    # Generate Inventory
    inventory = []
    for i in range(500):
        inventory_item = {
            "inventory_id": f"INV{i+1:06d}",
            "sku": fake.bothify(text="SKU-????-####"),
            "product_name": fake.catch_phrase(),
            "category": fake.random_element(
                elements=(
                    "ELECTRONICS",
                    "CLOTHING",
                    "FOOD",
                    "FURNITURE",
                    "BOOKS",
                    "TOYS",
                )
            ),
            "quantity_on_hand": fake.random_int(min=0, max=1000),
            "reorder_level": fake.random_int(min=10, max=100),
            "unit_cost": round(fake.random.uniform(5, 500), 2),
            "unit_price": round(fake.random.uniform(10, 1000), 2),
            "warehouse_location": (
                f"WH-{fake.random_element(elements=('A', 'B', 'C'))}"
                f"-{fake.random_int(min=1, max=99):02d}"
            ),
            "last_restock_date": fake.date_between(
                start_date=START_DATE, end_date=END_DATE
            ),
            "created_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
            "updated_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
        }
        inventory.append(inventory_item)

    inventory_df = pd.DataFrame(inventory)
    inventory_df.to_csv(SAMPLE_DATA_DIR / "operations_inventory.csv", index=False)
    inventory_df.to_parquet(
        SAMPLE_DATA_DIR / "operations_inventory.parquet", index=False
    )
    print(f"  ✓ Generated {len(inventory_df)} inventory items")


def generate_crm_data():
    """Generate CRM domain datasets: customers, interactions, opportunities."""
    print("Generating CRM data...")

    # Generate Customers
    customers = []
    for i in range(NUM_CUSTOMERS):
        customer = {
            "customer_id": f"CUST{i+1:06d}",
            "first_name": fake.first_name(),
            "last_name": fake.last_name(),
            "email": fake.email(),
            "phone": fake.phone_number(),
            "date_of_birth": fake.date_of_birth(minimum_age=18, maximum_age=80),
            "customer_type": fake.random_element(
                elements=("INDIVIDUAL", "BUSINESS", "INSTITUTIONAL")
            ),
            "customer_segment": fake.random_element(
                elements=("RETAIL", "PREMIUM", "ENTERPRISE", "VIP")
            ),
            "address": fake.address().replace("\n", ", "),
            "city": fake.city(),
            "state": fake.state_abbr(),
            "zip_code": fake.zipcode(),
            "country": "USA",
            "registration_date": fake.date_between(
                start_date=START_DATE, end_date=END_DATE
            ),
            "customer_status": fake.random_element(
                elements=("ACTIVE", "INACTIVE", "CHURNED")
            ),
            "lifetime_value": round(fake.random.uniform(1000, 100000), 2),
            "created_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
            "updated_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
        }
        customers.append(customer)

    customers_df = pd.DataFrame(customers)
    customers_df.to_csv(SAMPLE_DATA_DIR / "crm_customers.csv", index=False)
    customers_df.to_parquet(SAMPLE_DATA_DIR / "crm_customers.parquet", index=False)
    print(f"  ✓ Generated {len(customers_df)} customers")

    # Generate Interactions
    interactions = []
    for i in range(NUM_INTERACTIONS):
        interaction = {
            "interaction_id": f"INT{i+1:08d}",
            "customer_id": f"CUST{fake.random_int(min=1, max=NUM_CUSTOMERS):06d}",
            "interaction_type": fake.random_element(
                elements=("CALL", "EMAIL", "CHAT", "MEETING", "SOCIAL_MEDIA")
            ),
            "interaction_date": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
            "duration_minutes": fake.random_int(min=1, max=120),
            "subject": fake.sentence(nb_words=5),
            "notes": fake.text(max_nb_chars=200),
            "sentiment": fake.random_element(
                elements=("POSITIVE", "NEUTRAL", "NEGATIVE")
            ),
            "outcome": fake.random_element(
                elements=("RESOLVED", "FOLLOW_UP_NEEDED", "ESCALATED", "CLOSED")
            ),
            "assigned_to": fake.name(),
            "created_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
        }
        interactions.append(interaction)

    interactions_df = pd.DataFrame(interactions)
    interactions_df.to_csv(SAMPLE_DATA_DIR / "crm_interactions.csv", index=False)
    interactions_df.to_parquet(
        SAMPLE_DATA_DIR / "crm_interactions.parquet", index=False
    )
    print(f"  ✓ Generated {len(interactions_df)} interactions")

    # Generate Opportunities
    opportunities = []
    for i in range(800):
        opportunity = {
            "opportunity_id": f"OPP{i+1:06d}",
            "customer_id": f"CUST{fake.random_int(min=1, max=NUM_CUSTOMERS):06d}",
            "opportunity_name": fake.bs().title(),
            "opportunity_type": fake.random_element(
                elements=("NEW_BUSINESS", "UPSELL", "RENEWAL", "CROSS_SELL")
            ),
            "stage": fake.random_element(
                elements=(
                    "PROSPECTING",
                    "QUALIFICATION",
                    "PROPOSAL",
                    "NEGOTIATION",
                    "CLOSED_WON",
                    "CLOSED_LOST",
                )
            ),
            "probability": fake.random_int(min=0, max=100),
            "amount": round(fake.random.uniform(5000, 500000), 2),
            "expected_close_date": fake.date_between(
                start_date=START_DATE, end_date=END_DATE
            ),
            "actual_close_date": fake.date_between(
                start_date=START_DATE, end_date=END_DATE
            )
            if fake.boolean(chance_of_getting_true=50)
            else None,
            "lead_source": fake.random_element(
                elements=("WEBSITE", "REFERRAL", "COLD_CALL", "TRADE_SHOW", "PARTNER")
            ),
            "assigned_to": fake.name(),
            "created_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
            "updated_at": fake.date_time_between(
                start_date=START_DATE, end_date=END_DATE
            ),
        }
        opportunities.append(opportunity)

    opportunities_df = pd.DataFrame(opportunities)
    opportunities_df.to_csv(SAMPLE_DATA_DIR / "crm_opportunities.csv", index=False)
    opportunities_df.to_parquet(
        SAMPLE_DATA_DIR / "crm_opportunities.parquet", index=False
    )
    print(f"  ✓ Generated {len(opportunities_df)} opportunities")


def main():
    """Main function to generate all sample datasets."""
    # Create sample_data directory if it doesn't exist
    SAMPLE_DATA_DIR.mkdir(exist_ok=True)

    print("=" * 60)
    print("Starting Sample Data Generation")
    print("=" * 60)

    # Generate data for each domain
    generate_finance_data()
    print()
    generate_operations_data()
    print()
    generate_crm_data()

    print()
    print("=" * 60)
    print("Sample Data Generation Complete!")
    print(f"Data saved to: {SAMPLE_DATA_DIR}")
    print("=" * 60)


if __name__ == "__main__":
    main()

