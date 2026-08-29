# Analysis guide

## Scope

The project uses a compact, reproducible SQL Server database with three stores, three customer states, multiple bicycle categories, and a full year of order activity. The data includes completed, pending, processing, and rejected orders so that operational questions can be tested realistically.

## Analytical flow

1. Validate record counts and order-status values.
2. Calculate completed-order revenue using the agreed net-revenue definition.
3. Compare stores and states using both revenue and order counts.
4. rank brands, categories, products, customers, and staff.
5. Investigate weak-selling products and current stock.
6. Publish reusable views and parameterized procedures.

## Important interpretation notes

- Rejected orders are excluded from realized revenue.
- Revenue rankings can differ from unit rankings because premium products sell fewer units at higher prices.
- Customer comparisons use net revenue after discount.
- Low sales do not automatically mean a product should be removed; inventory, model year, and strategic assortment should also be reviewed.

## Recommended screenshots for GitHub

After running the project in SSMS, capture:

1. Executive KPI result set.
2. Monthly revenue and running revenue.
3. Store-performance result set.
4. Top-customer ranking.
5. Product-performance view.
