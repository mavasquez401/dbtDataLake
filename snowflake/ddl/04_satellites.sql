-- Data Vault 2.0 Satellites
-- Satellites contain descriptive attributes with full history (SCD Type 2)

USE DATABASE DATA_LAKE;
USE SCHEMA STAGE;

-- Satellite: Customer
-- Contains customer descriptive attributes with history
CREATE OR REPLACE TABLE sat_customer (
    customer_hk VARCHAR(32) NOT NULL,           -- FK to hub_customer
    load_date TIMESTAMP_NTZ NOT NULL,           -- Load timestamp (part of PK)
    end_date TIMESTAMP_NTZ,                     -- End of validity (NULL = current)
    hash_diff VARCHAR(32) NOT NULL,             -- Hash of all attributes for change detection
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(50),
    date_of_birth DATE,
    customer_type VARCHAR(50),
    customer_segment VARCHAR(50),
    address VARCHAR(500),
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    country VARCHAR(50),
    registration_date DATE,
    customer_status VARCHAR(50),
    lifetime_value DECIMAL(18,2),
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_sat_customer PRIMARY KEY (customer_hk, load_date),
    CONSTRAINT fk_sat_customer_hub FOREIGN KEY (customer_hk) REFERENCES hub_customer(customer_hk)
)
COMMENT = 'Satellite for customer attributes with full history';

-- Satellite: Account
-- Contains account descriptive attributes with history
CREATE OR REPLACE TABLE sat_account (
    account_hk VARCHAR(32) NOT NULL,            -- FK to hub_account
    load_date TIMESTAMP_NTZ NOT NULL,
    end_date TIMESTAMP_NTZ,
    hash_diff VARCHAR(32) NOT NULL,
    account_number VARCHAR(100),
    account_type VARCHAR(50),
    account_status VARCHAR(50),
    balance DECIMAL(18,2),
    currency VARCHAR(10),
    open_date DATE,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_sat_account PRIMARY KEY (account_hk, load_date),
    CONSTRAINT fk_sat_account_hub FOREIGN KEY (account_hk) REFERENCES hub_account(account_hk)
)
COMMENT = 'Satellite for account attributes with full history';

-- Satellite: Transaction
-- Contains transaction descriptive attributes
CREATE OR REPLACE TABLE sat_transaction (
    transaction_hk VARCHAR(32) NOT NULL,        -- FK to hub_transaction
    load_date TIMESTAMP_NTZ NOT NULL,
    end_date TIMESTAMP_NTZ,
    hash_diff VARCHAR(32) NOT NULL,
    transaction_type VARCHAR(50),
    amount DECIMAL(18,2),
    currency VARCHAR(10),
    transaction_date TIMESTAMP_NTZ,
    description VARCHAR(500),
    merchant VARCHAR(200),
    category VARCHAR(100),
    status VARCHAR(50),
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_sat_transaction PRIMARY KEY (transaction_hk, load_date),
    CONSTRAINT fk_sat_transaction_hub FOREIGN KEY (transaction_hk) REFERENCES hub_transaction(transaction_hk)
)
COMMENT = 'Satellite for transaction attributes';

-- Satellite: Order
-- Contains order descriptive attributes with history
CREATE OR REPLACE TABLE sat_order (
    order_hk VARCHAR(32) NOT NULL,              -- FK to hub_order
    load_date TIMESTAMP_NTZ NOT NULL,
    end_date TIMESTAMP_NTZ,
    hash_diff VARCHAR(32) NOT NULL,
    order_date TIMESTAMP_NTZ,
    order_status VARCHAR(50),
    order_total DECIMAL(18,2),
    currency VARCHAR(10),
    payment_method VARCHAR(50),
    shipping_address VARCHAR(500),
    billing_address VARCHAR(500),
    priority VARCHAR(50),
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_sat_order PRIMARY KEY (order_hk, load_date),
    CONSTRAINT fk_sat_order_hub FOREIGN KEY (order_hk) REFERENCES hub_order(order_hk)
)
COMMENT = 'Satellite for order attributes with full history';

-- Satellite: Product
-- Contains product/inventory descriptive attributes with history
CREATE OR REPLACE TABLE sat_product (
    product_hk VARCHAR(32) NOT NULL,            -- FK to hub_product
    load_date TIMESTAMP_NTZ NOT NULL,
    end_date TIMESTAMP_NTZ,
    hash_diff VARCHAR(32) NOT NULL,
    product_name VARCHAR(200),
    category VARCHAR(100),
    quantity_on_hand INTEGER,
    reorder_level INTEGER,
    unit_cost DECIMAL(18,2),
    unit_price DECIMAL(18,2),
    warehouse_location VARCHAR(100),
    last_restock_date DATE,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_sat_product PRIMARY KEY (product_hk, load_date),
    CONSTRAINT fk_sat_product_hub FOREIGN KEY (product_hk) REFERENCES hub_product(product_hk)
)
COMMENT = 'Satellite for product/inventory attributes with full history';

-- Satellite: Interaction
-- Contains interaction descriptive attributes
CREATE OR REPLACE TABLE sat_interaction (
    interaction_hk VARCHAR(32) NOT NULL,        -- FK to hub_interaction
    load_date TIMESTAMP_NTZ NOT NULL,
    end_date TIMESTAMP_NTZ,
    hash_diff VARCHAR(32) NOT NULL,
    interaction_type VARCHAR(50),
    interaction_date TIMESTAMP_NTZ,
    duration_minutes INTEGER,
    subject VARCHAR(500),
    notes VARCHAR(2000),
    sentiment VARCHAR(50),
    outcome VARCHAR(100),
    assigned_to VARCHAR(200),
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_sat_interaction PRIMARY KEY (interaction_hk, load_date),
    CONSTRAINT fk_sat_interaction_hub FOREIGN KEY (interaction_hk) REFERENCES hub_interaction(interaction_hk)
)
COMMENT = 'Satellite for interaction attributes';

-- Satellite: Opportunity
-- Contains opportunity descriptive attributes with history
CREATE OR REPLACE TABLE sat_opportunity (
    opportunity_hk VARCHAR(32) NOT NULL,        -- FK to hub_opportunity
    load_date TIMESTAMP_NTZ NOT NULL,
    end_date TIMESTAMP_NTZ,
    hash_diff VARCHAR(32) NOT NULL,
    opportunity_name VARCHAR(200),
    opportunity_type VARCHAR(50),
    stage VARCHAR(50),
    probability INTEGER,
    amount DECIMAL(18,2),
    expected_close_date DATE,
    actual_close_date DATE,
    lead_source VARCHAR(100),
    assigned_to VARCHAR(200),
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_sat_opportunity PRIMARY KEY (opportunity_hk, load_date),
    CONSTRAINT fk_sat_opportunity_hub FOREIGN KEY (opportunity_hk) REFERENCES hub_opportunity(opportunity_hk)
)
COMMENT = 'Satellite for opportunity attributes with full history';

