INSERT INTO Customers (CustomerID, CompanyName, ContactName, Country)
VALUES ('STUDE', 'Student Company', 'Marie Geislinger', 'USA');

INSERT INTO Customers (CustomerID, CompanyName, ContactName, Country)
VALUES ('STUDN', 'Student Company', 'Mary Lebens', 'USA');

SELECT * FROM Customers

INSERT INTO Customers (CustomerID, EmployeeID, OrderDate, ShipCountry)
VALUES ('STUDE', 1, GETDATE(), 'USA');

Select * FROM Customers WHERE CustomerID = 'STUDE';

UPDATE Customers SET ContactName = 'New Contact Name'
WHERE CustomerID = 'STUDE';

UPDATE Orders SET ShipCountry = 'New Country'
WHERE CustomerID = 'STUDE';

SELECT * FROM Orders

DELETE FROM Orders WHERE CustomerID = 'STUDE';
DELETE FROM Orders WHERE CustomerID = 'STUDN';

SELECT OrderID, CustomerID FROM Orders WHERE CustomerID = 'STUDE';

DELETE FROM Customers WHERE CustomerID = 'STUDE';
DELETE FROM Customers WHERE CustomerID = 'STUDN';

SELECT * FROM Customers WHERE CustomerID = 'STUDE';