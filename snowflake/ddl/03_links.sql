-- Data Vault 2.0 Links
-- Links represent relationships between hubs

USE DATABASE DATA_LAKE;
USE SCHEMA STAGE;

-- Link: Customer-Account
-- Represents the relationship between customers and accounts
CREATE OR REPLACE TABLE link_customer_account (
    customer_account_lk VARCHAR(32) NOT NULL,   -- Link hash key
    customer_hk VARCHAR(32) NOT NULL,           -- FK to hub_customer
    account_hk VARCHAR(32) NOT NULL,            -- FK to hub_account
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_link_customer_account PRIMARY KEY (customer_account_lk),
    CONSTRAINT fk_link_ca_customer FOREIGN KEY (customer_hk) REFERENCES hub_customer(customer_hk),
    CONSTRAINT fk_link_ca_account FOREIGN KEY (account_hk) REFERENCES hub_account(account_hk)
)
COMMENT = 'Link between customers and accounts';

-- Link: Account-Transaction
-- Represents the relationship between accounts and transactions
CREATE OR REPLACE TABLE link_account_transaction (
    account_transaction_lk VARCHAR(32) NOT NULL, -- Link hash key
    account_hk VARCHAR(32) NOT NULL,             -- FK to hub_account
    transaction_hk VARCHAR(32) NOT NULL,         -- FK to hub_transaction
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_link_account_transaction PRIMARY KEY (account_transaction_lk),
    CONSTRAINT fk_link_at_account FOREIGN KEY (account_hk) REFERENCES hub_account(account_hk),
    CONSTRAINT fk_link_at_transaction FOREIGN KEY (transaction_hk) REFERENCES hub_transaction(transaction_hk)
)
COMMENT = 'Link between accounts and transactions';

-- Link: Customer-Order
-- Represents the relationship between customers and orders
CREATE OR REPLACE TABLE link_customer_order (
    customer_order_lk VARCHAR(32) NOT NULL,     -- Link hash key
    customer_hk VARCHAR(32) NOT NULL,           -- FK to hub_customer
    order_hk VARCHAR(32) NOT NULL,              -- FK to hub_order
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_link_customer_order PRIMARY KEY (customer_order_lk),
    CONSTRAINT fk_link_co_customer FOREIGN KEY (customer_hk) REFERENCES hub_customer(customer_hk),
    CONSTRAINT fk_link_co_order FOREIGN KEY (order_hk) REFERENCES hub_order(order_hk)
)
COMMENT = 'Link between customers and orders';

-- Link: Order-Product
-- Represents the relationship between orders and products
CREATE OR REPLACE TABLE link_order_product (
    order_product_lk VARCHAR(32) NOT NULL,      -- Link hash key
    order_hk VARCHAR(32) NOT NULL,              -- FK to hub_order
    product_hk VARCHAR(32) NOT NULL,            -- FK to hub_product
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_link_order_product PRIMARY KEY (order_product_lk),
    CONSTRAINT fk_link_op_order FOREIGN KEY (order_hk) REFERENCES hub_order(order_hk),
    CONSTRAINT fk_link_op_product FOREIGN KEY (product_hk) REFERENCES hub_product(product_hk)
)
COMMENT = 'Link between orders and products';

-- Link: Customer-Interaction
-- Represents the relationship between customers and interactions
CREATE OR REPLACE TABLE link_customer_interaction (
    customer_interaction_lk VARCHAR(32) NOT NULL, -- Link hash key
    customer_hk VARCHAR(32) NOT NULL,             -- FK to hub_customer
    interaction_hk VARCHAR(32) NOT NULL,          -- FK to hub_interaction
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_link_customer_interaction PRIMARY KEY (customer_interaction_lk),
    CONSTRAINT fk_link_ci_customer FOREIGN KEY (customer_hk) REFERENCES hub_customer(customer_hk),
    CONSTRAINT fk_link_ci_interaction FOREIGN KEY (interaction_hk) REFERENCES hub_interaction(interaction_hk)
)
COMMENT = 'Link between customers and interactions';

-- Link: Customer-Opportunity
-- Represents the relationship between customers and opportunities
CREATE OR REPLACE TABLE link_customer_opportunity (
    customer_opportunity_lk VARCHAR(32) NOT NULL, -- Link hash key
    customer_hk VARCHAR(32) NOT NULL,             -- FK to hub_customer
    opportunity_hk VARCHAR(32) NOT NULL,          -- FK to hub_opportunity
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT pk_link_customer_opportunity PRIMARY KEY (customer_opportunity_lk),
    CONSTRAINT fk_link_cop_customer FOREIGN KEY (customer_hk) REFERENCES hub_customer(customer_hk),
    CONSTRAINT fk_link_cop_opportunity FOREIGN KEY (opportunity_hk) REFERENCES hub_opportunity(opportunity_hk)
)
COMMENT = 'Link between customers and opportunities';

