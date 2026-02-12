INSERT INTO Suppliers (CompanyName, ContactName, ContactTitle, Country)
VALUES ('Pop-up Foods', 'Marie Geislinger', 'Owner', 'USA');

-- Check your work:
SELECT * FROM Suppliers WHERE CompanyName = 'Pop-up Foods';

SELECT * FROM Products

INSERT INTO Products  (ProductName, SupplierID, CategoryID, UnitPrice, UnitsInStock)
VALUES ('House Special Pizza', 30, 2, 15.99, 50);

SELECT * FROM Products WHERE SupplierID = 30

UPDATE Products SET UnitPrice = 17.99
WHERE ProductName = 'House Special Pizza';

SELECT * FROM Products WHERE ProductName = 'House Special Pizza';

UPDATE Products SET UnitsInStock = 25
WHERE ProductName = 'House Special Pizza';

DELETE FROM Products WHERE ProductName = 'House Special Pizza';

SELECT SupplierID, ProductName FROM Products WHERE ProductName = 'House Special Pizza';