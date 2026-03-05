CREATE DATABASE PixelPizzaPalace;
GO

USE PixelPizzaPalace;
GO

CREATE TABLE Products (
    ProductID   INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(50),
    Price       DECIMAL(5,2),
    Stock       INT
);

CREATE TABLE Sales (
    SaleID    INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity  INT,
    SaleDate  DATETIME DEFAULT GETDATE()
);

INSERT INTO Products (ProductName, Price, Stock)
VALUES 
    ('Pepperoni Pizza', 12.99, 50),
    ('Cheese Pizza',    10.99, 50),
    ('Garlic Bread',     4.99, 75),
    ('Soda',             2.50, 200);

INSERT INTO Sales (ProductID, Quantity)
VALUES (1, 3), (2, 2), (3, 5);
GO


---STEP 3 Create Users & Grant Permissions - Follows Least Priviledge
---Create login at the server level of Pizza Place
CREATE LOGIN Cashier WITH PASSWORD = 'Cash123!';
CREATE LOGIN Manager WITH PASSWORD = 'Mangr123!';
GO

USE PixelPizzaPalace;
GO

-- Create users for the logins inside the PixelPizzaPalace database
CREATE USER Cashier FOR LOGIN Cashier;
CREATE USER Manager FOR LOGIN Manager;
GO

-- Cashier can only read the menu and add new sales
--- GRANT SELECT is the permission
GRANT SELECT ON Products TO Cashier;
GRANT SELECT, INSERT ON Sales TO Cashier;
GO


-- Manager can do everything on both tables
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO Manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Sales TO Manager;
GO

--STEP 4 Check the user permission
SELECT 
    dp.name  AS UserName,
    o.name   AS TableName,
    p.permission_name  AS Permission
FROM sys.database_permissions p
JOIN sys.database_principals dp 
    ON p.grantee_principal_id = dp.principal_id
JOIN sys.objects o 
    ON p.major_id = o.object_id
WHERE dp.name IN ('Cashier', 'Manager')
ORDER BY UserName, TableName;
GO

--STEP 5 Monitor database size (SixeMB is column name)
--GO will run each database
SELECT 
    name        AS FileName,
    size / 128.0 AS SizeMB
FROM sys.database_files;
GO

--STEP 6 Backup Database (Pathway)
BACKUP DATABASE PixelPizzaPalace
TO DISK = '/var/opt/mssql/data/PixelPizzaPalace.bak'
WITH FORMAT;
GO

--STEP 7 Create an Index - Do most often as DBA
-- Create an index so searches by ProductName are faster
CREATE NONCLUSTERED INDEX IX_Products_Name 
ON Products(ProductName);
GO

-- Verify the index was created by listing all indexes on Products
SELECT 
    i.name      AS IndexName,
    i.type_desc AS IndexType,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName
FROM sys.indexes i
JOIN sys.index_columns ic 
    ON i.object_id = ic.object_id 
    AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('Products')
ORDER BY i.name;
GO

--=============================================--
--                  PART 2                       
--=============================================--     

-- ===== PART 2 STEP 2: ADD INVENTORY USER =====
Your Task:

Add a comment header to your module8_lab.sql file such as -- ===== PART 2 STEP 2: ADD INVENTORY USER =====
Write the SQL to create a login called InventoryMgr with password Inv123!
Write the SQL to create a database user for that login in PixelPizzaPalace.
Write the SQL to grant InventoryMgr SELECT and UPDATE on the Products table only.
Run each statement individually by right-clicking and choosing Execute Query.
Copy the permissions query from Part 1 Step 4 into this section and run it to verify the permissions are correct.

-- ===== PART 2 STEP 3: TABLE SIZES =====
USE PixelPizzaPalace;
GO

SELECT 
    t.name              AS TableName,
    p.rows              AS NumberOfRows,
    SUM(a.total_pages) * 8 AS TotalSpaceKB
FROM sys.tables t
JOIN sys.indexes i 
    ON t.object_id = i.object_id
JOIN sys.partitions p 
    ON i.object_id = p.object_id 
    AND i.index_id = p.index_id
JOIN sys.allocation_units a 
    ON p.partition_id = a.container_id
GROUP BY t.name, p.rows
ORDER BY TotalSpaceKB DESC;
GO

-- ===== PART 2 STEP 4: BACKUP AND RESTORE =====
--*4a: Add a new product
INSERT INTO Products (ProductName, Price, Stock)
VALUES ('Ice Cream Sundae', 5.99, 60);
GO

--*4b: Back up the database with the new product included
BACKUP DATABASE PixelPizzaPalace
TO DISK = '/var/opt/mssql/data/PixelPizzaPalace_New.bak'
WITH FORMAT;
GO

--*4c: Delete the product and verify it is gone
DELETE FROM Products WHERE ProductName = 'Ice Cream Sundae';
GO

SELECT * FROM Products;
GO

--*4d: Restore the database and verify the product came back
USE master;
GO

-- Take the database offline so we can restore it
ALTER DATABASE PixelPizzaPalace SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE PixelPizzaPalace
FROM DISK = '/var/opt/mssql/data/PixelPizzaPalace_New.bak'
WITH REPLACE;
GO

-- Bring the database back online for all users
ALTER DATABASE PixelPizzaPalace SET MULTI_USER;
GO

USE PixelPizzaPalace;
GO

SELECT * FROM Products;
GO

-- ===== PART 2 STEP 5: REFLECTION ===== 
-- Reflection
-- Question 1: The three most important tasks were...
-- Question 2: Pixel Pizza Palace needs permission control because...
-- Question 3: Without regular backups...