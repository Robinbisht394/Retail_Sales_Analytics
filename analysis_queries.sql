-- Retail Sales Analytics Project
CREATE DATABASE IF NOT EXISTS retail_sales_analytics;
USE retail_sales_analytics;

-- =========================
-- TABLES
-- =========================
CREATE TABLE customers(
 customer_id INT PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 gender VARCHAR(20),
 age INT,
 city VARCHAR(50),
 state VARCHAR(50)
);

CREATE TABLE products(
 product_id INT PRIMARY KEY,
 productName VARCHAR(50) NOT NULL,
 Category VARCHAR(50),
 UnitPrice DECIMAL(10,2)
);

CREATE TABLE salesPerson(
 salesperson_id INT PRIMARY KEY,
 salespersonName VARCHAR(50) NOT NULL,
 region VARCHAR(50)
);

CREATE TABLE orders(
 order_id INT PRIMARY KEY,
 customer_id INT,
 salesperson_id INT,
 orderDate DATE,
 paymentMode VARCHAR(20),
 deliveryDays INT,
 returned BOOLEAN,
 FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
   ON DELETE CASCADE ON UPDATE CASCADE,
 FOREIGN KEY(salesperson_id) REFERENCES salesPerson(salesperson_id)
   ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE orderDetails(
 orderDetail_id INT PRIMARY KEY,
 order_id INT,
 product_id INT,
 quantity INT,
 discount DECIMAL(5,2),
 FOREIGN KEY(order_id) REFERENCES orders(order_id)
   ON DELETE CASCADE ON UPDATE CASCADE,
 FOREIGN KEY(product_id) REFERENCES products(product_id)
   ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- NOTE:
-- Paste the INSERT statements for Customers (50),
-- Products (20), SalesPerson (10),
-- Orders (500), OrderDetails (1000)
-- that you generated earlier.
-- =====================================================

-- =========================
-- DATA CLEANING
-- =========================
UPDATE customers
SET name=TRIM(name),
    gender=TRIM(gender),
    city=TRIM(city),
    state=TRIM(state);

UPDATE products
SET productName=TRIM(productName),
    Category=TRIM(Category);

UPDATE salesPerson
SET salespersonName=TRIM(salespersonName),
    region=TRIM(region);

UPDATE orders
SET paymentMode=TRIM(paymentMode);

UPDATE customers
SET gender='Male'
WHERE gender IN('M','male','MALE');

UPDATE customers
SET gender='Female'
WHERE gender IN('F','female','FEMALE');

UPDATE products
SET Category='Electronics'
WHERE LOWER(Category) IN('electronic','electronics');

UPDATE products
SET Category='Home & Kitchen'
WHERE LOWER(Category)='home kitchen';

UPDATE orders
SET paymentMode='UPI'
WHERE UPPER(paymentMode) IN('UPI','GPAY','GOOGLE PAY','PHONEPE');

UPDATE orders
SET paymentMode='Card'
WHERE LOWER(paymentMode) IN('card','credit card','debit card');

UPDATE orders
SET paymentMode='Cash'
WHERE LOWER(paymentMode)='cash';

UPDATE customers
SET age=NULL
WHERE age<18 OR age>100;

-- =========================
-- EDA
-- =========================
SELECT COUNT(*) AS TotalCustomers FROM customers;
SELECT COUNT(*) AS TotalProducts FROM products;
SELECT COUNT(*) AS TotalOrders FROM orders;
SELECT COUNT(*) AS TotalSalespersons FROM salesPerson;

-- =========================
-- BUSINESS INSIGHTS
-- =========================

--1 Total Revenue
SELECT SUM((p.UnitPrice*od.quantity)-od.discount) AS TotalRevenue
FROM orderDetails od
JOIN products p ON od.product_id=p.product_id;

--2 Revenue by Category
SELECT p.Category,
SUM((p.UnitPrice*od.quantity)-od.discount) Revenue
FROM products p
JOIN orderDetails od ON p.product_id=od.product_id
GROUP BY p.Category
ORDER BY Revenue DESC;

--3 Monthly Revenue
SELECT MONTHNAME(o.orderDate) Month,
SUM((p.UnitPrice*od.quantity)-od.discount) Revenue
FROM orders o
JOIN orderDetails od ON o.order_id=od.order_id
JOIN products p ON od.product_id=p.product_id
GROUP BY MONTH(o.orderDate),MONTHNAME(o.orderDate)
ORDER BY MONTH(o.orderDate);

--4 Top 5 Products
SELECT p.productName,
SUM((p.UnitPrice*od.quantity)-od.discount) Revenue
FROM products p
JOIN orderDetails od ON p.product_id=od.product_id
GROUP BY p.product_id,p.productName
ORDER BY Revenue DESC
LIMIT 5;

--5 Top Customers
SELECT c.name,
SUM((p.UnitPrice*od.quantity)-od.discount) Revenue
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN orderDetails od ON o.order_id=od.order_id
JOIN products p ON od.product_id=p.product_id
GROUP BY c.customer_id,c.name
ORDER BY Revenue DESC
LIMIT 5;

--6 Salesperson Performance
SELECT s.salespersonName,
SUM((p.UnitPrice*od.quantity)-od.discount) Revenue
FROM salesPerson s
JOIN orders o ON s.salesperson_id=o.salesperson_id
JOIN orderDetails od ON o.order_id=od.order_id
JOIN products p ON od.product_id=p.product_id
GROUP BY s.salesperson_id,s.salespersonName
ORDER BY Revenue DESC;

--7 Payment Mode Revenue
SELECT o.paymentMode,
SUM((p.UnitPrice*od.quantity)-od.discount) Revenue
FROM orders o
JOIN orderDetails od ON o.order_id=od.order_id
JOIN products p ON od.product_id=p.product_id
GROUP BY o.paymentMode
ORDER BY Revenue DESC;

--8 State Revenue
SELECT c.state,
SUM((p.UnitPrice*od.quantity)-od.discount) Revenue
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN orderDetails od ON o.order_id=od.order_id
JOIN products p ON od.product_id=p.product_id
GROUP BY c.state
ORDER BY Revenue DESC;

--9 Return Analysis
SELECT returned,COUNT(*) TotalOrders
FROM orders
GROUP BY returned;

--10 CTE Revenue Contribution
WITH CategoryRevenue AS(
SELECT p.Category,
SUM((p.UnitPrice*od.quantity)-od.discount) Revenue
FROM products p
JOIN orderDetails od ON p.product_id=od.product_id
GROUP BY p.Category
)
SELECT Category,
Revenue,
ROUND(Revenue*100/(SELECT SUM(Revenue) FROM CategoryRevenue),2) AS RevenueContribution
FROM CategoryRevenue
ORDER BY Revenue DESC;

-- Bonus
SELECT AVG(deliveryDays) AS AvgDeliveryDays
FROM orders;
