USE BikeStoresPortfolioDB;
GO

-- 1. Executive KPIs for completed orders.
SELECT
    COUNT(DISTINCT o.order_id) AS CompletedOrders,
    COUNT(DISTINCT o.customer_id) AS ActiveCustomers,
    SUM(oi.quantity) AS UnitsSold,
    CAST(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(14,2)) AS NetRevenue,
    CAST(AVG(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(12,2)) AS AverageLineRevenue,
    CAST(MAX(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(12,2)) AS MaximumLineRevenue,
    CAST(MIN(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(12,2)) AS MinimumLineRevenue
FROM sales.orders AS o
INNER JOIN sales.order_items AS oi ON o.order_id = oi.order_id
WHERE o.order_status = 4;

-- 2. Order status distribution.
SELECT
    CASE order_status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Rejected'
        WHEN 4 THEN 'Completed'
    END AS OrderStatus,
    COUNT(*) AS NumberOfOrders
FROM sales.orders
GROUP BY order_status
ORDER BY order_status;

-- 3. Monthly revenue and running revenue.
WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS RevenueMonth,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS NetRevenue
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
)
SELECT
    RevenueMonth,
    CAST(NetRevenue AS DECIMAL(14,2)) AS NetRevenue,
    CAST(SUM(NetRevenue) OVER (ORDER BY RevenueMonth) AS DECIMAL(14,2)) AS RunningRevenue
FROM MonthlyRevenue
ORDER BY RevenueMonth;

-- 4. Store performance.
SELECT
    s.store_name,
    COUNT(DISTINCT o.order_id) AS Orders,
    SUM(oi.quantity) AS UnitsSold,
    CAST(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(14,2)) AS NetRevenue,
    CAST(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) / COUNT(DISTINCT o.order_id) AS DECIMAL(12,2)) AS AverageOrderValue
FROM sales.stores AS s
INNER JOIN sales.orders AS o ON s.store_id = o.store_id
INNER JOIN sales.order_items AS oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY s.store_name
ORDER BY NetRevenue DESC;

-- 5. Revenue and orders by customer state, including a grand total.
SELECT
    COALESCE(c.state, 'ALL') AS CustomerState,
    COUNT(DISTINCT o.order_id) AS Orders,
    CAST(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(14,2)) AS NetRevenue
FROM sales.customers AS c
INNER JOIN sales.orders AS o ON c.customer_id = o.customer_id
INNER JOIN sales.order_items AS oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY ROLLUP(c.state)
ORDER BY GROUPING(c.state), NetRevenue DESC;

-- 6. Top two brands by revenue.
SELECT TOP (2)
    b.brand_name,
    SUM(oi.quantity) AS UnitsSold,
    CAST(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(14,2)) AS NetRevenue
FROM production.brands AS b
INNER JOIN production.products AS p ON b.brand_id = p.brand_id
INNER JOIN sales.order_items AS oi ON p.product_id = oi.product_id
INNER JOIN sales.orders AS o ON oi.order_id = o.order_id
WHERE o.order_status = 4
GROUP BY b.brand_name
ORDER BY NetRevenue DESC;

-- 7. Category performance.
SELECT
    c.category_name,
    SUM(oi.quantity) AS UnitsSold,
    CAST(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(14,2)) AS NetRevenue,
    DENSE_RANK() OVER (ORDER BY SUM(oi.quantity) DESC) AS UnitSalesRank
FROM production.categories AS c
INNER JOIN production.products AS p ON c.category_id = p.category_id
INNER JOIN sales.order_items AS oi ON p.product_id = oi.product_id
INNER JOIN sales.orders AS o ON oi.order_id = o.order_id
WHERE o.order_status = 4
GROUP BY c.category_name
ORDER BY UnitSalesRank, NetRevenue DESC;

-- 8. Revenue and units by product.
SELECT
    p.product_name,
    b.brand_name,
    c.category_name,
    SUM(oi.quantity) AS UnitsSold,
    CAST(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(14,2)) AS NetRevenue
FROM production.products AS p
INNER JOIN production.brands AS b ON p.brand_id = b.brand_id
INNER JOIN production.categories AS c ON p.category_id = c.category_id
INNER JOIN sales.order_items AS oi ON p.product_id = oi.product_id
INNER JOIN sales.orders AS o ON oi.order_id = o.order_id
WHERE o.order_status = 4
GROUP BY p.product_name, b.brand_name, c.category_name
ORDER BY NetRevenue DESC;

-- 9. Bottom five products by revenue, including products with no completed sales.
SELECT TOP (5)
    p.product_name,
    COALESCE(SUM(CASE WHEN o.order_status = 4 THEN oi.quantity ELSE 0 END), 0) AS UnitsSold,
    CAST(COALESCE(SUM(CASE WHEN o.order_status = 4 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END), 0) AS DECIMAL(14,2)) AS NetRevenue
FROM production.products AS p
LEFT JOIN sales.order_items AS oi ON p.product_id = oi.product_id
LEFT JOIN sales.orders AS o ON oi.order_id = o.order_id
GROUP BY p.product_name
ORDER BY NetRevenue, p.product_name;

-- 10. Top customers by revenue, orders, and products purchased.
SELECT TOP (10)
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS CustomerName,
    c.state,
    COUNT(DISTINCT o.order_id) AS Orders,
    COUNT(DISTINCT oi.product_id) AS DistinctProducts,
    SUM(oi.quantity) AS UnitsPurchased,
    CAST(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(14,2)) AS NetRevenue
FROM sales.customers AS c
INNER JOIN sales.orders AS o ON c.customer_id = o.customer_id
INNER JOIN sales.order_items AS oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY c.customer_id, c.first_name, c.last_name, c.state
ORDER BY NetRevenue DESC;

-- 11. Top three customers within every state.
WITH CustomerRevenue AS
(
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS CustomerName,
        c.state,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS NetRevenue
    FROM sales.customers AS c
    INNER JOIN sales.orders AS o ON c.customer_id = o.customer_id
    INNER JOIN sales.order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY c.customer_id, c.first_name, c.last_name, c.state
), RankedCustomers AS
(
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY state ORDER BY NetRevenue DESC) AS StateRank
    FROM CustomerRevenue
)
SELECT
    state,
    StateRank,
    customer_id,
    CustomerName,
    CAST(NetRevenue AS DECIMAL(14,2)) AS NetRevenue
FROM RankedCustomers
WHERE StateRank <= 3
ORDER BY state, StateRank, CustomerName;

-- 12. Customer value segments.
WITH CustomerRevenue AS
(
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS CustomerName,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS NetRevenue
    FROM sales.customers AS c
    INNER JOIN sales.orders AS o ON c.customer_id = o.customer_id
    INNER JOIN sales.order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY c.customer_id, c.first_name, c.last_name
), Segmented AS
(
    SELECT *, NTILE(3) OVER (ORDER BY NetRevenue DESC) AS ValueTier
    FROM CustomerRevenue
)
SELECT
    customer_id,
    CustomerName,
    CAST(NetRevenue AS DECIMAL(14,2)) AS NetRevenue,
    CASE ValueTier WHEN 1 THEN 'High Value' WHEN 2 THEN 'Medium Value' ELSE 'Developing' END AS CustomerSegment
FROM Segmented
ORDER BY NetRevenue DESC;

-- 13. Sales staff performance.
SELECT
    CONCAT(st.first_name, ' ', st.last_name) AS StaffName,
    s.store_name,
    COUNT(DISTINCT o.order_id) AS CompletedOrders,
    CAST(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(14,2)) AS NetRevenue
FROM sales.staffs AS st
INNER JOIN sales.stores AS s ON st.store_id = s.store_id
INNER JOIN sales.orders AS o ON st.staff_id = o.staff_id
INNER JOIN sales.order_items AS oi ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY st.staff_id, st.first_name, st.last_name, s.store_name
ORDER BY NetRevenue DESC;

-- 14. Rejected orders by category.
SELECT
    c.category_name,
    COUNT(DISTINCT o.order_id) AS RejectedOrders,
    SUM(oi.quantity) AS RejectedUnits
FROM production.categories AS c
INNER JOIN production.products AS p ON c.category_id = p.category_id
INNER JOIN sales.order_items AS oi ON p.product_id = oi.product_id
INNER JOIN sales.orders AS o ON oi.order_id = o.order_id
WHERE o.order_status = 3
GROUP BY c.category_name
ORDER BY RejectedOrders DESC, RejectedUnits DESC;

-- 15. Current stock for the highest-revenue brand.
WITH BrandRevenue AS
(
    SELECT
        p.brand_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS NetRevenue,
        DENSE_RANK() OVER (ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC) AS RevenueRank
    FROM production.products AS p
    INNER JOIN sales.order_items AS oi ON p.product_id = oi.product_id
    INNER JOIN sales.orders AS o ON oi.order_id = o.order_id
    WHERE o.order_status = 4
    GROUP BY p.brand_id
)
SELECT
    s.store_name,
    b.brand_name,
    SUM(st.quantity) AS UnitsInStock
FROM BrandRevenue AS br
INNER JOIN production.brands AS b ON br.brand_id = b.brand_id
INNER JOIN production.products AS p ON b.brand_id = p.brand_id
INNER JOIN production.stocks AS st ON p.product_id = st.product_id
INNER JOIN sales.stores AS s ON st.store_id = s.store_id
WHERE br.RevenueRank = 1
GROUP BY s.store_name, b.brand_name
ORDER BY UnitsInStock DESC;
GO
