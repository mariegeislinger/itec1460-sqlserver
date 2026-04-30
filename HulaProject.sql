CREATE DATABASE HulaTracker;
GO

USE HulaTracker;
GO

CREATE TABLE Member (
    MemberID   INT PRIMARY KEY IDENTITY(1,1),
    MemberName VARCHAR(50)
);

CREATE TABLE Status (
    StatusID            INT PRIMARY KEY IDENTITY(1,1),
    StatusType          VARCHAR(50),
    StatusDescription   VARCHAR(200)
);

CREATE TABLE Role (
    RoleID          INT PRIMARY KEY IDENTITY(1,1),
    RoleName        VARCHAR(50),
    RoleDescription VARCHAR(200)
);

CREATE TABLE MemberRole (
    MemberRoleID    INT PRIMARY KEY IDENTITY(1,1),
    MemberID        INT,
    RoleID          INT
);

CREATE TABLE Practice (
    PracticeID      INT PRIMARY KEY IDENTITY(1,1),
    PracticeDate    DATE,
    BeginTime       TIME,
    EndTime         TIME
);

CREATE TABLE Attendance (
    AttendanceID    INT PRIMARY KEY IDENTITY(1,1),
    MemberID        INT,
    PracticeDate    DATE,
    CONSTRAINT FK_AttendanceMember FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
);

--CREATE ATTENDANCE LOG
SELECT  m.MemberName
        p.PracticeDate
    FROM Attendance p
    JOIN Member m on

CREATE TABLE Role (
    RoleID    INT PRIMARY KEY IDENTITY(1,1),
    RoleName  VARCHAR(50),
    RoleDescription  VARCHAR(200)
);

CREATE TABLE MemberRole (
    MemberRoleID INT PRIMARY KEY IDENTITY(1,1),
    MemberID INT,
    RoleID INT
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

--Part 1 of 2 > Log in and create page file

-- ===== PART 2 STEP 2: ADD INVENTORY USER =====

CREATE LOGIN InventoryMgr WITH PASSWORD = 'Inv123!';
GO

USE PixelPizzaPalace;
GO

-- Create user for the login inside the database
CREATE USER InventoryMgr FOR LOGIN InventoryMgr;
GO

-- Inventory manager can only view and update Products
GRANT SELECT, UPDATE ON Products TO InventoryMgr;
GO


-- ===== PART 2 STEP 2 CHECK PERMISSIONS =====
SELECT 
    dp.name  AS UserName,
    o.name   AS TableName,
    p.permission_name AS Permission
FROM sys.database_permissions p
JOIN sys.database_principals dp 
    ON p.grantee_principal_id = dp.principal_id
JOIN sys.objects o 
    ON p.major_id = o.object_id
WHERE dp.name = 'InventoryMgr'
ORDER BY TableName;
GO


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
--      1. Create Users and their Roles
--      2. Access Levels 
--      3. Backing up the data and secure it

-- Question 2: Pixel Pizza Palace needs permission control because...
--  The business have multiple individuals that only need access for particluar part of their job duties.
--  A cashier only needs the product and order information while a manager has access to all information.
-- This ensures that information is protected and for a need-to-know basis.

-- Question 3: Without regular backups...
-- If the information is not backup regularly, the information may go missing and is unable to retrieve. 
-- There are many horror stories of companies not having information backup and lose their data to ransomware attacks.
-- It is vital for each part of the company and departments to find a way to consistently back up their data.
-- Even if the most important information is kept safe, the day-to-day tasks that is low priority can take
-- a lot of time and money to restore or recreate.