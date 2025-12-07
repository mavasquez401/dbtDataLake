# Data Vault 2.0 Design

## Overview

This document describes the Data Vault 2.0 modeling approach used in the institutional data lake. Data Vault 2.0 is an enterprise data warehouse methodology that provides agility, scalability, and auditability.

## Core Concepts

### Hubs

Hubs contain unique business keys and represent core business entities. They are immutable and contain:
- **Hash Key (HK)**: MD5 hash of the business key
- **Business Key**: Natural key from source system
- **Load Date**: When the record was first loaded
- **Record Source**: Source system identifier

### Links

Links represent relationships between hubs. They contain:
- **Link Hash Key (LK)**: MD5 hash of all participating hub keys
- **Hub Hash Keys**: Foreign keys to related hubs
- **Load Date**: When the relationship was first observed
- **Record Source**: Source system identifier

### Satellites

Satellites contain descriptive attributes and maintain full history (SCD Type 2). They contain:
- **Hub/Link Hash Key**: Foreign key to parent hub or link
- **Load Date**: When this version was loaded (part of PK)
- **End Date**: When this version became inactive (NULL = current)
- **Hash Diff**: MD5 hash of all attributes for change detection
- **Descriptive Attributes**: All business attributes
- **Record Source**: Source system identifier

## Data Model

### Hubs

1. **hub_customer**: Customer business keys
2. **hub_account**: Account business keys
3. **hub_order**: Order business keys
4. **hub_transaction**: Transaction business keys
5. **hub_product**: Product/inventory business keys
6. **hub_interaction**: Customer interaction business keys
7. **hub_opportunity**: Sales opportunity business keys

### Links

1. **link_customer_account**: Customer owns accounts
2. **link_account_transaction**: Transactions belong to accounts
3. **link_customer_order**: Customers place orders
4. **link_order_product**: Orders contain products
5. **link_customer_interaction**: Customers have interactions
6. **link_customer_opportunity**: Customers have opportunities

### Satellites

1. **sat_customer**: Customer attributes (name, contact, segment, etc.)
2. **sat_account**: Account attributes (type, status, balance, etc.)
3. **sat_transaction**: Transaction attributes (amount, type, status, etc.)
4. **sat_order**: Order attributes (status, total, payment, etc.)
5. **sat_product**: Product attributes (name, price, quantity, etc.)
6. **sat_interaction**: Interaction attributes (type, notes, sentiment, etc.)
7. **sat_opportunity**: Opportunity attributes (stage, amount, probability, etc.)

## Benefits

### Auditability
- Full history of all changes
- Track when data was loaded and from which source
- No data is ever deleted, only end-dated

### Agility
- New sources can be added without changing existing structures
- Schema changes are additive (new satellites)
- Parallel loading of different entities

### Scalability
- Normalized structure reduces data redundancy
- Hash keys enable efficient partitioning
- Independent loading of hubs, links, and satellites

### Data Quality
- Business keys are preserved from source
- Hash keys ensure uniqueness
- Hash diff enables efficient change detection

## Loading Pattern

### Initial Load
1. Load Hubs (unique business keys)
2. Load Links (relationships)
3. Load Satellites (attributes)

### Incremental Load
1. Check if business key exists in Hub
   - If new: Insert into Hub
   - If exists: Skip
2. Check if relationship exists in Link
   - If new: Insert into Link
   - If exists: Skip
3. Check if attributes changed in Satellite
   - Calculate hash_diff of new attributes
   - Compare with current record
   - If different: End-date current record and insert new record
   - If same: Skip

## Example Queries

### Get Current Customer Information
```sql
SELECT
    h.customer_id,
    s.first_name,
    s.last_name,
    s.email,
    s.customer_status
FROM hub_customer h
JOIN sat_customer s ON h.customer_hk = s.customer_hk
WHERE s.end_date IS NULL;
```

### Get Customer History
```sql
SELECT
    h.customer_id,
    s.customer_status,
    s.load_date,
    s.end_date
FROM hub_customer h
JOIN sat_customer s ON h.customer_hk = s.customer_hk
WHERE h.customer_id = 'CUST000001'
ORDER BY s.load_date;
```

### Get Customer with Accounts
```sql
SELECT
    hc.customer_id,
    sc.first_name,
    sc.last_name,
    ha.account_id,
    sa.account_type,
    sa.balance
FROM hub_customer hc
JOIN sat_customer sc ON hc.customer_hk = sc.customer_hk AND sc.end_date IS NULL
JOIN link_customer_account lca ON hc.customer_hk = lca.customer_hk
JOIN hub_account ha ON lca.account_hk = ha.account_hk
JOIN sat_account sa ON ha.account_hk = sa.account_hk AND sa.end_date IS NULL;
```

## Best Practices

1. **Hash Keys**: Use MD5 for hash keys (32 characters)
2. **Load Date**: Use TIMESTAMP_NTZ for consistency
3. **End Date**: NULL indicates current record
4. **Hash Diff**: Calculate on all descriptive attributes
5. **Record Source**: Use consistent naming convention
6. **Naming**: Use prefixes (hub_, link_, sat_) for clarity

## References

- Data Vault 2.0 by Dan Linstedt
- [Data Vault Alliance](https://datavaultalliance.com/)

