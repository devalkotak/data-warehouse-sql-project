# Data Warehouse — SQL Server (Medallion Architecture)

A fully structured data warehouse built on SQL Server, implementing the Bronze/Silver/Gold medallion architecture to consolidate and transform data from two operational source systems (CRM and ERP) into a clean, analytics-ready star schema.

---

## Project Overview

This project demonstrates the end-to-end construction of a relational data warehouse — from raw ingestion through transformation to a dimensional model suitable for business reporting and analytics. It covers ETL pipeline design, data quality enforcement, and dimensional modeling, all implemented in T-SQL.

**Source systems:** CRM (customer and product data) + ERP (location, demographics, product categories)  
**Destination:** Star schema with two dimension tables and one fact table, exposed as views in the Gold layer  
**Platform:** Microsoft SQL Server (compatible with SQL Server Express + SSMS)

---

## Architecture

```
CSV Files (CRM + ERP)
        │
        ▼
┌───────────────┐
│    BRONZE     │  Raw ingestion — BULK INSERT, no transformation
│  (Schema: bronze) │
└──────┬────────┘
       │
       ▼
┌───────────────┐
│    SILVER     │  Cleansed & standardised — stored procedures
│  (Schema: silver) │
└──────┬────────┘
       │
       ▼
┌───────────────┐
│     GOLD      │  Star schema — SQL views, analytics-ready
│  (Schema: gold)   │
└───────────────┘
```

### Bronze Layer
Raw data is loaded as-is from CSV files into staging tables using `BULK INSERT`. No business logic is applied at this stage — the intent is to preserve the exact state of the source data for auditability and reprocessing.

### Silver Layer
A stored procedure (`proc_load_silver`) applies standardisation and cleansing rules before writing to Silver tables:
- String trimming and whitespace normalisation
- Date format conversion (integer `YYYYMMDD` fields cast to `DATE`)
- Gender and marital status code normalisation
- Duplicate elimination (most recent record per customer ID retained)
- Referential integrity alignment between CRM and ERP keys
- Derivation of `cat_id` from product keys for downstream joins
- A `dwh_create_date` audit column (populated via `DEFAULT GETDATE()`) is added to every Silver table

### Gold Layer
Three SQL views constitute the presentation layer, implementing a star schema:

| Object | Type | Description |
|---|---|---|
| `gold.dim_customers` | View | Unified customer dimension — joins CRM customer info with ERP demographics and location |
| `gold.dim_products` | View | Product dimension — joins CRM product records with ERP category hierarchy; excludes expired products (`prd_end_dt IS NULL`) |
| `gold.fact_sales` | View | Sales fact table — resolves surrogate keys from both dimensions |

Surrogate keys (`customer_key`, `product_key`) are generated using `ROW_NUMBER() OVER (ORDER BY ...)` within the views.

---

## Tech Stack

| Component | Technology |
|---|---|
| Database Engine | Microsoft SQL Server |
| Query Language | T-SQL |
| ETL Mechanism | Stored Procedures + BULK INSERT |
| Data Modelling | Star Schema (Kimball-style) |
| Client Tool | SQL Server Management Studio (SSMS) |
| Source Data | Flat CSV files (CRM + ERP) |

---

## Data Quality Testing

SQL-based quality checks are run against both the Silver and Gold layers.

**Silver layer checks (`tests/quality_checks_silver.sql`):**
- Duplicate primary key detection across all six source tables
- Whitespace validation on string columns
- Negative or null value checks on cost and price fields
- Date logic assertions — order date must precede ship and due dates
- Sales consistency check: `sls_sales = sls_quantity × sls_price`
- Invalid date range detection (birth dates, order/due dates out of realistic bounds)
- Distinct value audits on categorical fields (gender, marital status, product line, country)

**Gold layer checks (`tests/quality_checks_gold.sql`):**
- Surrogate key uniqueness in `dim_customers` and `dim_products`
- Referential integrity validation — confirms every row in `fact_sales` resolves to a valid customer and product in the dimension views

All checks are written as diagnostic `SELECT` queries — a result set with rows indicates a data quality issue.

---

## How to Run

> Prerequisites: SQL Server (Express or higher) and SSMS.

1. **Initialise the database**
   ```sql
   -- Run: scripts/init_database.sql
   -- Creates the DataWarehouse database and bronze/silver/gold schemas
   ```

2. **Create Bronze and Silver tables**
   ```sql
   -- Run: scripts/bronze/ddl_bronze.sql
   -- Run: scripts/silver/ddl_silver.sql
   ```

3. **Update file paths**  
   Open `scripts/bronze/proc_load_bronze.sql` and update the `BULK INSERT` file paths to match your local `datasets/` directory.

4. **Load the stored procedures and execute them**
   ```sql
   -- Run: scripts/bronze/proc_load_bronze.sql
   EXEC bronze.load_bronze;

   -- Run: scripts/silver/proc_load_silver.sql
   EXEC silver.load_silver;
   ```

5. **Create Gold views**
   ```sql
   -- Run: scripts/gold/ddl_gold.sql
   ```

6. **Run data quality checks**
   ```sql
   -- Run: tests/quality_checks_silver.sql
   -- Run: tests/quality_checks_gold.sql
   -- Any query returning rows indicates a data issue
   ```

---

## Repository Structure

```
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv          # Customer master data
│   │   ├── prd_info.csv           # Product catalogue
│   │   └── sales_details.csv      # Transactional sales records
│   └── source_erp/
│       ├── CUST_AZ12.csv          # Customer demographics (DOB, gender)
│       ├── LOC_A101.csv           # Customer location/country
│       └── PX_CAT_G1V2.csv        # Product category hierarchy
├── scripts/
│   ├── init_database.sql          # Database and schema initialisation
│   ├── bronze/
│   │   ├── ddl_bronze.sql         # Bronze table definitions
│   │   └── proc_load_bronze.sql   # BULK INSERT stored procedure
│   ├── silver/
│   │   ├── ddl_silver.sql         # Silver table definitions
│   │   └── proc_load_silver.sql   # Cleansing and transformation procedure
│   └── gold/
│       └── ddl_gold.sql           # Dimension and fact view definitions
└── tests/
    ├── quality_checks_silver.sql  # Silver layer data quality assertions
    └── quality_checks_gold.sql    # Gold layer referential integrity checks
```
