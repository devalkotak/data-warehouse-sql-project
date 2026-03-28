# SQL Data Warehouse Project

Built a small data warehouse in SQL Server to practice ETL and data modeling.
Data comes from two fake source systems (CRM + ERP) as CSV files and flows through three layers before it's ready for analysis.

---

## How it works

```
CSV files  →  Bronze (raw)  →  Silver (cleaned)  →  Gold (star schema)
```

- **Bronze** — raw data, loaded as-is from CSVs using BULK INSERT
- **Silver** — cleaned up: trimmed strings, normalized codes, fixed bad dates, removed duplicates
- **Gold** — three views (dim_customers, dim_products, fact_sales) joined and ready to query

---

## How to run it

> You'll need SQL Server (Express works) and SSMS.

1. Run `scripts/init_database.sql` — creates the DB and schemas
2. Run the DDL scripts in `bronze/` and `silver/` to create the tables
3. Update the file paths in `proc_load_bronze.sql` to point to your local datasets folder
4. Execute the stored procedures: `EXEC bronze.load_bronze` then `EXEC silver.load_silver`
5. Run `scripts/gold/ddl_gold.sql` to create the final views
6. Use the scripts in `/tests` to check data quality

---

## Structure

```
├── datasets/
│   ├── source_crm/
│   └── source_erp/
├── scripts/
│   ├── init_database.sql
│   ├── bronze/
│   ├── silver/
│   └── gold/
└── tests/
```
