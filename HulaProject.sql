CREATE DATABASE HulaTracker;
GO

USE HulaTracker;
GO

---STEP 1 Create 8 Tables
---TABLE 1, 2, & 3 - Member information with roles and status
CREATE TABLE Role (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName VARCHAR(20) NOT NULL UNIQUE,
    Description VARCHAR(100)
);

CREATE TABLE MemberStatus (
    MemberStatusID INT IDENTITY(1,1) PRIMARY KEY,
    StatusName VARCHAR(20) NOT NULL UNIQUE
);

---NEEDED TO START with Status Table to start first

CREATE TABLE Member (
    MemberID INT IDENTITY(1,1) PRIMARY KEY,
    MemberName VARCHAR(50) NOT NULL,
    HawaiianName VARCHAR(50),
    MemberStatusID INT NOT NULL,
        CONSTRAINT FK_Member_Status FOREIGN KEY (MemberStatusID) REFERENCES MemberStatus(MemberStatusID)
);

----TABLE 4 Role Assignment
CREATE TABLE MemberRole (
    MemberRoleID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT NOT NULL,
    RoleID INT NOT NULL,
        CONSTRAINT FK_MemberRole_Member FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
        CONSTRAINT FK_MemberRole_Role FOREIGN KEY (RoleID) REFERENCES Role(RoleID),
        CONSTRAINT UQ_MemberRole UNIQUE (MemberID, RoleID)
);

---TABLE 5 - Hula Catalog
CREATE TABLE Hula (
    HulaID INT IDENTITY(1,1) PRIMARY KEY,
    HulaName VARCHAR(100),
    TitleName VARCHAR(100),
    HulaType VARCHAR(20),
    Description VARCHAR(200)
);

---TABLE 6 - Practice Date
CREATE TABLE Practice (
    PracticeID INT IDENTITY(1,1) PRIMARY KEY,
    PracticeDate DATE,
    Lesson VARCHAR(100)
);

---TABLE 7 - Attendance Log
CREATE TABLE Attendance (
    AttendanceID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT NOT NULL,
    PracticeID INT NOT NULL,
    AttendanceStatus VARCHAR(20),
        CONSTRAINT FK_Attendance_Member FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
        CONSTRAINT FK_Attendance_Practice FOREIGN KEY (PracticeID) REFERENCES Practice(PracticeID)
);

---TABLE 8 - Performance Info
CREATE TABLE Performance (
    PerformanceID INT IDENTITY(1,1) PRIMARY KEY,
    PerformanceTitle VARCHAR(100),
    PerformanceDate DATE,
    Location VARCHAR(100)
);

---TABLE 9 - Performers at Performance
CREATE TABLE MemberPerformance (
    MemberPerformanceID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT NOT NULL,
    PerformanceID INT NOT NULL,
        CONSTRAINT FK_MemberPerformance_Member FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
        CONSTRAINT FK_MemberPerformance_Performance FOREIGN KEY (PerformanceID) REFERENCES Performance(PerformanceID)
);

---STEP 2 - 3 Stored Procedures / INSERT / RETRIEVE / DELETE
---PROCEDURE 1 - INSERT VALUES
---Values for Role
INSERT INTO Role (RoleName, Description)
VALUES
    ('Dancer', 'Dancer in class'),
    ('Performer', 'Performs at events'),
    ('Kumu', 'Teacher'),
    ('Holapa', 'Chanter');

SELECT * FROM Role

---Values for Status
INSERT INTO MemberStatus (StatusName)
	VALUES ('Active'), ('Inactive');

SELECT * FROM MemberStatus

---Values for Members
INSERT INTO Member (MemberName, HawaiianName, MemberStatusID)
SELECT MemberName, HawaiianName, ms.MemberStatusID
FROM MemberStatus ms
JOIN (VALUES
    ('Val', 'Vailana', 'Active'),
    ('Marie', 'Keala', 'Active'),
    ('Tish', 'Malea', 'Inactive'),
    ('Janelle', 'Kalei', 'Active'),
    ('Tammy', 'Lu''ukia', 'Active'),
    ('Winnie', 'Mikalalani', 'Active'),
    ('Shiz', 'Manulani', 'Active')
) AS m(MemberName, HawaiianName, StatusName)
ON ms.StatusName = m.StatusName;

SELECT * FROM Member

---Need values for ROLE ASSIGNMENT
INSERT INTO MemberRole (MemberID, RoleID)
SELECT
    m.MemberID,
    r.RoleID
FROM (VALUES
    ('Val', 'Holapa'),
    ('Marie', 'Performer'),
    ('Tish', 'Dancer'),
    ('Janelle', 'Performer'),
    ('Tammy', 'Kumu')
) AS rmap(MemberName, RoleName)
JOIN Member m
    ON m.MemberName = rmap.MemberName
JOIN Role r
    ON r.RoleName = rmap.RoleName;

SELECT * FROM MemberRole

---Need values for Performances
INSERT INTO Performance (PerformanceTitle, PerformanceDate, Location)
VALUES
    ('IFest', '2026-04-11', 'St. Paul RiverCentre'),
    ('Lafayette Luau', '2026-06-20', 'Lake Minnetonka'),
    ('Project Fine', '2026-05-31', 'Winona State University'),
    ('MN Homeschool Prom', '2026-05-16', 'Church of Open Doors – Maple Grove'),
    ('Kahea Ordination', '2026-05-17', 'United Church of Christ – New Brighton');
GO

SELECT * FROM Performance

---Need values for Performances Assignment
INSERT INTO MemberPerformance (MemberID, PerformanceID)
SELECT m.MemberID, p.PerformanceID
FROM Member m
JOIN MemberRole mr ON m.MemberID = mr.MemberID
JOIN Role r ON mr.RoleID = r.RoleID
JOIN Performance p ON p.PerformanceTitle = 'IFest'
WHERE r.RoleName = 'Performer';


INSERT INTO MemberPerformance (MemberID, PerformanceID)
SELECT m.MemberID, p.PerformanceID
FROM Member m
JOIN MemberRole mr ON m.MemberID = mr.MemberID
JOIN Role r ON mr.RoleID = r.RoleID
JOIN Performance p ON p.PerformanceTitle = 'Project Fine'
WHERE r.RoleName = 'Performer';


INSERT INTO MemberPerformance (MemberID, PerformanceID)
SELECT m.MemberID, p.PerformanceID
FROM Member m
JOIN Performance p ON p.PerformanceTitle = 'MN Homeschool Prom'
WHERE m.HawaiianName IN ('Mikalalani', 'Manulani');


INSERT INTO MemberPerformance (MemberID, PerformanceID)
SELECT m.MemberID, p.PerformanceID
FROM Member m
JOIN Performance p ON p.PerformanceTitle = 'Kahea Ordination'
WHERE m.HawaiianName IN ('Kalei', 'Keala');

INSERT INTO MemberPerformance (MemberID, PerformanceID)
SELECT m.MemberID, p.PerformanceID
FROM Member m
JOIN Performance p ON p.PerformanceTitle = 'Kahea Ordination'
WHERE m.HawaiianName IN ('Vailana');

---PROCEDURE 2 - Retrieve 
SELECT * FROM Member;

---Retrieve Member Performers
CREATE PROCEDURE sp_GetMemberPerformers
AS
BEGIN
    SELECT
        m.MemberName,
        m.HawaiianName,
        r.RoleName,
        s.StatusName
FROM Member m
    JOIN MemberRole mr ON m.MemberID = mr.MemberID
    JOIN Role r ON mr.RoleID = r.RoleID
    JOIN MemberStatus s ON m.MemberStatusID = s.MemberStatusID
    WHERE r.RoleName = 'Performer';
END;
GO

EXECUTE sp_GetMemberPerformers;


---Retrieve Member Performers at a performance
SELECT
    m.MemberName,
    m.HawaiianName,
    p.PerformanceTitle
FROM Performance p
	JOIN MemberPerformance mp ON p.PerformanceID = mp.PerformanceID
	JOIN Member m ON mp.MemberID = m.MemberID
	JOIN MemberRole mr ON m.MemberID = mr.MemberID
WHERE p.PerformanceTitle = 'Kahea Ordination';


---PROCEDURE 3 - Delete Record
---VIEW ALL RECORDS
Select * From Member

---ADDED SAME RECORD TWICE - DELETE THE DUPLICATES
---Needed to delete on Constraint References
DELETE
FROM MemberPerformance
WHERE MemberID BETWEEN 8 AND 14;

DELETE
FROM MemberRole
WHERE MemberID BETWEEN 8 AND 14;

DELETE
FROM Attendance
WHERE MemberID BETWEEN 8 AND 14;

DELETE
FROM Member
WHERE MemberID BETWEEN 8 AND 14;


---STEP 3 Create 2 VIEWS
---VIEW 1
CREATE VIEW vw_MemberOverview AS
SELECT 
    m.MemberName,
    m.HawaiianName,
    r.RoleName,
    s.StatusName
FROM Member m
JOIN MemberStatus s ON m.MemberStatusID = s.MemberStatusID
JOIN MemberRole mr ON m.MemberID = mr.MemberID
JOIN Role r ON mr.RoleID = r.RoleID;

SELECT * FROM vw_MemberOverview


---VIEW 2
CREATE VIEW vw_PerformanceRoster AS
SELECT
    p.PerformanceTitle,
    p.PerformanceDate,
    p.Location,
    m.MemberName,
    m.HawaiianName
FROM Performance p
JOIN MemberPerformance mp
    ON p.PerformanceID = mp.PerformanceID
JOIN Member m
    ON mp.MemberID = m.MemberID;
GO

SELECT * FROM vw_PerformanceRoster