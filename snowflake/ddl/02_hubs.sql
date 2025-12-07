-- Data Vault 2.0 Hubs
-- Hubs contain business keys and metadata

USE DATABASE DATA_LAKE;
USE SCHEMA STAGE;

-- Hub: Customer
-- Contains unique customer business keys
CREATE OR REPLACE TABLE hub_customer (
    customer_hk VARCHAR(32) NOT NULL,           -- Hash key (MD5 of business key)
    customer_id VARCHAR(50) NOT NULL,           -- Business key
    load_date TIMESTAMP_NTZ NOT NULL,           -- Load timestamp
    record_source VARCHAR(100) NOT NULL,        -- Source system
    CONSTRAINT pk_hub_customer PRIMARY KEY (customer_hk)
)
COMMENT = 'Hub table for customers - contains unique customer business keys';

-- Hub: Account
-- Contains unique account business keys
CREATE OR REPLACE TABLE hub_account (
    account_hk VARCHAR(32) NOT NULL,            -- Hash key
    account_id VARCHAR(50) NOT NULL,            -- Business key
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_hub_account PRIMARY KEY (account_hk)
)
COMMENT = 'Hub table for accounts - contains unique account business keys';

-- Hub: Order
-- Contains unique order business keys
CREATE OR REPLACE TABLE hub_order (
    order_hk VARCHAR(32) NOT NULL,              -- Hash key
    order_id VARCHAR(50) NOT NULL,              -- Business key
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_hub_order PRIMARY KEY (order_hk)
)
COMMENT = 'Hub table for orders - contains unique order business keys';

-- Hub: Transaction
-- Contains unique transaction business keys
CREATE OR REPLACE TABLE hub_transaction (
    transaction_hk VARCHAR(32) NOT NULL,        -- Hash key
    transaction_id VARCHAR(50) NOT NULL,        -- Business key
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_hub_transaction PRIMARY KEY (transaction_hk)
)
COMMENT = 'Hub table for transactions - contains unique transaction business keys';

-- Hub: Product/Inventory
-- Contains unique product/SKU business keys
CREATE OR REPLACE TABLE hub_product (
    product_hk VARCHAR(32) NOT NULL,            -- Hash key
    inventory_id VARCHAR(50) NOT NULL,          -- Business key
    sku VARCHAR(50) NOT NULL,                   -- Alternate business key
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_hub_product PRIMARY KEY (product_hk)
)
COMMENT = 'Hub table for products/inventory - contains unique product business keys';

-- Hub: Interaction
-- Contains unique interaction business keys
CREATE OR REPLACE TABLE hub_interaction (
    interaction_hk VARCHAR(32) NOT NULL,        -- Hash key
    interaction_id VARCHAR(50) NOT NULL,        -- Business key
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_hub_interaction PRIMARY KEY (interaction_hk)
)
COMMENT = 'Hub table for interactions - contains unique interaction business keys';

-- Hub: Opportunity
-- Contains unique opportunity business keys
CREATE OR REPLACE TABLE hub_opportunity (
    opportunity_hk VARCHAR(32) NOT NULL,        -- Hash key
    opportunity_id VARCHAR(50) NOT NULL,        -- Business key
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_hub_opportunity PRIMARY KEY (opportunity_hk)
)
COMMENT = 'Hub table for opportunities - contains unique opportunity business keys';

