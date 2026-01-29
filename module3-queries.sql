--Qurey A: Write a query that shows the CompanyName and City of all suppliers from Germany.
SELECT CompanyName, City FROM Customers
WHERE Country = 'Germany'

--Query B: Write a query that shows the ProductName and UnitPrice for all products that cost less than $20.
SELECT ProductName, UnitPrice FROM Products
WHERE UnitPrice < 20

--Query C: Write a query that shows the CompanyName, ContactName, and Phone for all customers located in London.
SELECT CompanyName, ContactName, Phone from Customers
WHERE City = 'London'