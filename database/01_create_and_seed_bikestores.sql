/*
  Project: BikeStores Sales Analysis
  Author: Amr Nader Wahba
  Platform: Microsoft SQL Server
*/

USE master;
GO

IF DB_ID('BikeStoresPortfolioDB') IS NOT NULL
BEGIN
    ALTER DATABASE BikeStoresPortfolioDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BikeStoresPortfolioDB;
END;
GO

CREATE DATABASE BikeStoresPortfolioDB;
GO
USE BikeStoresPortfolioDB;
GO

CREATE SCHEMA production;
GO
CREATE SCHEMA sales;
GO

CREATE TABLE production.categories
(
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE production.brands
(
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE production.products
(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    brand_id INT NOT NULL REFERENCES production.brands(brand_id),
    category_id INT NOT NULL REFERENCES production.categories(category_id),
    model_year SMALLINT NOT NULL,
    list_price DECIMAL(12,2) NOT NULL CHECK (list_price > 0)
);

CREATE TABLE sales.stores
(
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    phone VARCHAR(25) NULL,
    email VARCHAR(100) NULL,
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL
);

CREATE TABLE sales.staffs
(
    staff_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    store_id INT NOT NULL REFERENCES sales.stores(store_id),
    manager_id INT NULL REFERENCES sales.staffs(staff_id)
);

CREATE TABLE sales.customers
(
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NULL,
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL
);

CREATE TABLE sales.orders
(
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES sales.customers(customer_id),
    order_status TINYINT NOT NULL CHECK (order_status BETWEEN 1 AND 4),
    order_date DATE NOT NULL,
    required_date DATE NOT NULL,
    shipped_date DATE NULL,
    store_id INT NOT NULL REFERENCES sales.stores(store_id),
    staff_id INT NOT NULL REFERENCES sales.staffs(staff_id)
);

CREATE TABLE sales.order_items
(
    order_id INT NOT NULL REFERENCES sales.orders(order_id),
    item_id INT NOT NULL,
    product_id INT NOT NULL REFERENCES production.products(product_id),
    quantity SMALLINT NOT NULL CHECK (quantity > 0),
    list_price DECIMAL(12,2) NOT NULL CHECK (list_price > 0),
    discount DECIMAL(5,4) NOT NULL DEFAULT (0) CHECK (discount BETWEEN 0 AND 0.50),
    CONSTRAINT PK_order_items PRIMARY KEY (order_id, item_id)
);

CREATE TABLE production.stocks
(
    store_id INT NOT NULL REFERENCES sales.stores(store_id),
    product_id INT NOT NULL REFERENCES production.products(product_id),
    quantity INT NOT NULL CHECK (quantity >= 0),
    CONSTRAINT PK_stocks PRIMARY KEY (store_id, product_id)
);
GO

INSERT INTO production.categories VALUES
    (1, 'Children Bicycles'), (2, 'Comfort Bicycles'),
    (3, 'Cruisers Bicycles'), (4, 'Electric Bikes'),
    (5, 'Mountain Bikes'), (6, 'Road Bikes');

INSERT INTO production.brands VALUES
    (1, 'Electra'), (2, 'Trek'), (3, 'Surly'),
    (4, 'Haro'), (5, 'Cannondale'), (6, 'Sun Bicycles');

INSERT INTO production.products VALUES
    (1,  'Electra Townie Original 21D', 1, 2, 2019, 599.99),
    (2,  'Electra Cruiser 1',           1, 3, 2020, 429.99),
    (3,  'Electra White Water 3i',      1, 3, 2018, 749.99),
    (4,  'Trek Fuel EX 8',              2, 5, 2021, 3299.99),
    (5,  'Trek Domane SL 6',            2, 6, 2021, 4199.99),
    (6,  'Trek Precaliber 24',          2, 1, 2020, 439.99),
    (7,  'Surly Straggler',             3, 6, 2020, 1549.00),
    (8,  'Surly Ice Cream Truck',       3, 5, 2021, 2099.00),
    (9,  'Haro Flightline Two 27.5',    4, 5, 2020, 549.99),
    (10, 'Haro Downtown 16',            4, 1, 2020, 279.99),
    (11, 'Cannondale Synapse Carbon',   5, 6, 2021, 3499.99),
    (12, 'Cannondale Adventure Neo',    5, 4, 2021, 2999.99),
    (13, 'Sun Traditional Trike',       6, 2, 2019, 579.99),
    (14, 'Sun Atlas Cargo',             6, 3, 2020, 899.99),
    (15, 'Electra Kids Starship',       1, 1, 2021, 329.99),
    (16, 'Trek Verve Plus 3',           2, 4, 2022, 3799.99),
    (17, 'Surly Midnight Special',      3, 6, 2022, 2349.00),
    (18, 'Haro Beasley 27.5',           4, 5, 2021, 699.99);

INSERT INTO sales.stores VALUES
    (1, 'Santa Cruz Bikes', '831-555-0111', 'santacruz@bikes.example', 'Santa Cruz', 'CA', '95060'),
    (2, 'Baldwin Bikes',    '516-555-0112', 'baldwin@bikes.example',   'Baldwin',    'NY', '11510'),
    (3, 'Rowlett Bikes',    '972-555-0113', 'rowlett@bikes.example',   'Rowlett',    'TX', '75088');

INSERT INTO sales.staffs (staff_id, first_name, last_name, email, store_id, manager_id) VALUES
    (1, 'Sarah', 'Mitchell', 'sarah.mitchell@bikes.example', 1, NULL),
    (3, 'David', 'Brown',    'david.brown@bikes.example',    2, NULL),
    (5, 'Maria', 'Garcia',   'maria.garcia@bikes.example',   3, NULL);

INSERT INTO sales.staffs VALUES
    (2, 'Kevin', 'Lee',      'kevin.lee@bikes.example',      1, 1),
    (4, 'Emma', 'Wilson',    'emma.wilson@bikes.example',    2, 3),
    (6, 'James', 'Taylor',   'james.taylor@bikes.example',   3, 5);

INSERT INTO sales.customers VALUES
    (101, 'Olivia', 'Martin',  'olivia.martin@example.com',  'San Jose',     'CA', '95112'),
    (102, 'Noah',   'Clark',   'noah.clark@example.com',     'Santa Cruz',   'CA', '95060'),
    (103, 'Ava',    'Lewis',   'ava.lewis@example.com',      'Los Angeles',  'CA', '90001'),
    (104, 'Liam',   'Walker',  'liam.walker@example.com',    'Buffalo',      'NY', '14201'),
    (105, 'Mia',    'Hall',    'mia.hall@example.com',       'Baldwin',      'NY', '11510'),
    (106, 'Ethan',  'Young',   'ethan.young@example.com',    'Albany',       'NY', '12201'),
    (107, 'Sophia', 'King',    'sophia.king@example.com',    'Dallas',       'TX', '75201'),
    (108, 'Mason',  'Wright',  'mason.wright@example.com',   'Rowlett',      'TX', '75088'),
    (109, 'Isabella','Scott',  'isabella.scott@example.com', 'Austin',       'TX', '73301'),
    (110, 'Lucas',  'Green',   'lucas.green@example.com',    'San Diego',    'CA', '92101'),
    (111, 'Amelia', 'Baker',   'amelia.baker@example.com',   'Rochester',    'NY', '14602'),
    (112, 'Logan',  'Adams',   'logan.adams@example.com',    'Houston',      'TX', '77001'),
    (113, 'Harper', 'Nelson',  'harper.nelson@example.com',  'Fresno',       'CA', '93650'),
    (114, 'Elijah', 'Carter',  'elijah.carter@example.com',  'Queens',       'NY', '11354'),
    (115, 'Evelyn', 'Perez',   'evelyn.perez@example.com',   'Plano',        'TX', '75023');

INSERT INTO sales.orders VALUES
    (1001,101,4,'2025-01-05','2025-01-10','2025-01-08',1,2),
    (1002,102,4,'2025-01-19','2025-01-24','2025-01-22',1,1),
    (1003,103,3,'2025-02-03','2025-02-08',NULL,1,2),
    (1004,104,4,'2025-02-12','2025-02-17','2025-02-15',2,4),
    (1005,105,4,'2025-03-02','2025-03-07','2025-03-05',2,3),
    (1006,106,1,'2025-03-18','2025-03-23',NULL,2,4),
    (1007,107,4,'2025-04-04','2025-04-09','2025-04-07',3,6),
    (1008,108,4,'2025-04-20','2025-04-25','2025-04-23',3,5),
    (1009,109,2,'2025-05-06','2025-05-11',NULL,3,6),
    (1010,110,4,'2025-05-22','2025-05-27','2025-05-25',1,1),
    (1011,111,4,'2025-06-09','2025-06-14','2025-06-12',2,3),
    (1012,112,4,'2025-06-25','2025-06-30','2025-06-28',3,5),
    (1013,113,4,'2025-07-11','2025-07-16','2025-07-14',1,2),
    (1014,114,3,'2025-07-28','2025-08-02',NULL,2,4),
    (1015,115,4,'2025-08-13','2025-08-18','2025-08-16',3,6),
    (1016,101,4,'2025-09-01','2025-09-06','2025-09-04',1,1),
    (1017,104,4,'2025-09-17','2025-09-22','2025-09-20',2,3),
    (1018,107,4,'2025-10-03','2025-10-08','2025-10-06',3,5),
    (1019,102,1,'2025-10-20','2025-10-25',NULL,1,2),
    (1020,105,4,'2025-11-07','2025-11-12','2025-11-10',2,4),
    (1021,108,4,'2025-11-24','2025-11-29','2025-11-27',3,6),
    (1022,110,4,'2025-12-10','2025-12-15','2025-12-13',1,1),
    (1023,111,2,'2025-12-19','2025-12-24',NULL,2,3),
    (1024,112,4,'2025-12-27','2026-01-01','2025-12-30',3,5);

INSERT INTO sales.order_items VALUES
    (1001,1,4,1,3299.99,0.10),(1001,2,9,2,549.99,0.05),
    (1002,1,1,1,599.99,0.00),(1002,2,15,2,329.99,0.05),
    (1003,1,5,1,4199.99,0.15),
    (1004,1,7,1,1549.00,0.05),(1004,2,13,1,579.99,0.00),
    (1005,1,11,1,3499.99,0.10),(1005,2,6,1,439.99,0.00),
    (1006,1,3,1,749.99,0.00),
    (1007,1,12,1,2999.99,0.08),(1007,2,14,2,899.99,0.10),
    (1008,1,8,1,2099.00,0.05),(1008,2,10,2,279.99,0.00),
    (1009,1,16,1,3799.99,0.12),
    (1010,1,5,1,4199.99,0.08),(1010,2,2,1,429.99,0.00),
    (1011,1,11,1,3499.99,0.05),(1011,2,17,1,2349.00,0.10),
    (1012,1,12,1,2999.99,0.10),(1012,2,18,2,699.99,0.05),
    (1013,1,6,2,439.99,0.00),(1013,2,15,3,329.99,0.05),
    (1014,1,7,1,1549.00,0.00),
    (1015,1,16,1,3799.99,0.10),(1015,2,14,1,899.99,0.00),
    (1016,1,4,1,3299.99,0.05),(1016,2,1,1,599.99,0.00),
    (1017,1,17,1,2349.00,0.05),(1017,2,13,2,579.99,0.10),
    (1018,1,8,1,2099.00,0.00),(1018,2,12,1,2999.99,0.08),
    (1019,1,3,1,749.99,0.00),
    (1020,1,5,1,4199.99,0.10),(1020,2,11,1,3499.99,0.12),
    (1021,1,9,2,549.99,0.00),(1021,2,18,1,699.99,0.05),
    (1022,1,2,2,429.99,0.05),(1022,2,15,1,329.99,0.00),
    (1023,1,16,1,3799.99,0.10),
    (1024,1,12,1,2999.99,0.05),(1024,2,14,2,899.99,0.10);

INSERT INTO production.stocks (store_id, product_id, quantity)
SELECT s.store_id, p.product_id,
       3 + ((s.store_id * 7 + p.product_id * 3) % 18)
FROM sales.stores AS s
CROSS JOIN production.products AS p;
GO

CREATE INDEX IX_orders_customer ON sales.orders(customer_id);
CREATE INDEX IX_orders_store_date ON sales.orders(store_id, order_date);
CREATE INDEX IX_order_items_product ON sales.order_items(product_id);
GO
