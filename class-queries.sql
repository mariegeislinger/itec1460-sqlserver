-- Query 1: Get all products
SELECT * FROM Products;

-- Query 2: Get specific customer -- List columns in all tables whose name is like 'SELECT '
SELECT CompanyName, ContactName, City FROM Customers;

-- Query 3: Get customer from USA
SELECT CompanyName, ContactName, City FROM Customers
WHERE Country = 'USA';

