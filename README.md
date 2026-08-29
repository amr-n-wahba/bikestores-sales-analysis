# BikeStores Sales Analysis with SQL

An end-to-end Microsoft SQL Server analytics project for a multi-store bicycle retailer. It transforms the BikeStores coursework exercises into a clean, reproducible portfolio project with a compact sample database, business KPIs, customer analysis, product analysis, and reusable database objects.

## Business problem

Management needs a single SQL analysis that answers four questions:

1. How are revenue and orders distributed across stores and states?
2. Which products, brands, and categories drive performance?
3. Who are the highest-value customers?
4. Which products have weak sales or low stock?

## Skills demonstrated

- Multi-table joins and subqueries
- CTEs and window functions
- Aggregations, `ROLLUP`, ranking, and segmentation
- Customer, product, store, and geographic analysis
- Views and stored procedures
- Data-quality checks and KPI definitions

## Repository structure

```text
database/
  01_create_and_seed_bikestores.sql
  02_business_analysis.sql
  03_views_and_procedures.sql
docs/
  ANALYSIS_GUIDE.md
```

## How to run

1. Open SQL Server Management Studio.
2. Run the files in numerical order.
3. Use SQL Server 2019 or newer.
4. Review the result sets produced by `02_business_analysis.sql`.

## KPI definitions

- **Net revenue:** `quantity * list_price * (1 - discount)`
- **Completed order:** `order_status = 4`
- **Customer revenue:** completed-order net revenue attributed to the ordering customer
- **Units sold:** sum of quantities on completed orders

## Author

Amr Nader Wahba - Junior Data Analyst  
GitHub: [amr-n-wahba](https://github.com/amr-n-wahba)
