USE BikeStoresPortfolioDB;
GO

CREATE OR ALTER VIEW sales.vw_OrderRevenue
AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.customer_id,
    o.store_id,
    o.staff_id,
    SUM(oi.quantity) AS Units,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS NetRevenue
FROM sales.orders AS o
INNER JOIN sales.order_items AS oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, o.order_status, o.customer_id, o.store_id, o.staff_id;
GO

CREATE OR ALTER VIEW sales.vw_ProductPerformance
AS
SELECT
    p.product_id,
    p.product_name,
    b.brand_name,
    c.category_name,
    SUM(CASE WHEN o.order_status = 4 THEN oi.quantity ELSE 0 END) AS UnitsSold,
    SUM(CASE WHEN o.order_status = 4 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS NetRevenue
FROM production.products AS p
INNER JOIN production.brands AS b ON p.brand_id = b.brand_id
INNER JOIN production.categories AS c ON p.category_id = c.category_id
LEFT JOIN sales.order_items AS oi ON p.product_id = oi.product_id
LEFT JOIN sales.orders AS o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name, b.brand_name, c.category_name;
GO

CREATE OR ALTER PROCEDURE sales.GetStorePerformance
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @EndDate < @StartDate
        THROW 50001, 'End date must not be earlier than start date.', 1;

    SELECT
        s.store_id,
        s.store_name,
        COUNT(DISTINCT o.order_id) AS CompletedOrders,
        CAST(COALESCE(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 0) AS DECIMAL(14,2)) AS NetRevenue
    FROM sales.stores AS s
    LEFT JOIN sales.orders AS o
        ON s.store_id = o.store_id
       AND o.order_status = 4
       AND o.order_date BETWEEN @StartDate AND @EndDate
    LEFT JOIN sales.order_items AS oi ON o.order_id = oi.order_id
    GROUP BY s.store_id, s.store_name
    ORDER BY NetRevenue DESC;
END;
GO

CREATE OR ALTER PROCEDURE sales.GetCustomerHistory
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM sales.customers WHERE customer_id = @CustomerID)
        THROW 50002, 'Customer does not exist.', 1;

    SELECT
        o.order_id,
        o.order_date,
        CASE o.order_status WHEN 1 THEN 'Pending' WHEN 2 THEN 'Processing' WHEN 3 THEN 'Rejected' WHEN 4 THEN 'Completed' END AS OrderStatus,
        p.product_name,
        oi.quantity,
        CAST(oi.quantity * oi.list_price * (1 - oi.discount) AS DECIMAL(12,2)) AS LineRevenue
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi ON o.order_id = oi.order_id
    INNER JOIN production.products AS p ON oi.product_id = p.product_id
    WHERE o.customer_id = @CustomerID
    ORDER BY o.order_date, o.order_id, oi.item_id;
END;
GO

EXEC sales.GetStorePerformance @StartDate = '2025-01-01', @EndDate = '2025-12-31';
EXEC sales.GetCustomerHistory @CustomerID = 101;
GO
