CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    BirthDate DATE
);

CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    Title VARCHAR(100),
    AuthorID INT, --foreign key links to author
    PublicationYear INT,
    Price DECIMAL(10,2) --remember 2 is the place of the decimal
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

SELECT * FROM Authors;
SELECT * FROM Books;

---INSERT DATA for authors
INSERT INTO Authors (AuthorID, FirstName, LastName, BirthDate)
VALUES 
    (1, 'Jane', 'Austen', '1775-12-16'),
    (2, 'George', 'Orwell', '1903-06-25'),
    (3, 'J.K.', 'Rowling', '1965-07-21'),
    (4, 'Ernest', 'Hemingway', '1899-07-21'),
    (5, 'Virginia', 'Woolf', '1882-01-25');

INSERT INTO Books (BookID, Title, AuthorID, PublicationYear, Price)
VALUES
    (1, 'Pride and Prejudice', 1, 1813, 12.99),
    (2, '1984', 2, 1949, 10.99),
    (3, 'Harry Potter and the Philosopher''s Stone', 3, 1997, 15.99),
    (4, 'The Old Man and the Sea', 4, 1952, 11.99),
    (5, 'To the Lighthouse', 5, 1927, 13.99),
    (6, 'The diary of Virginia Woolf', 5, 1915, 16.99);

--Create view combines books and authors
CREATE VIEW BookDetails AS
SELECT 
    b.BookID,
    b.Title,
    a.FirstName + ' ' + a.LastName AS AuthorName,
    b.PublicationYear,
    b.Price
FROM Books b
JOIN Authors a ON b.AuthorID = a.AuthorID;

CREATE VIEW RecentBooks AS
SELECT 
    BookID,
    Title,
    PublicationYear,
    Price
FROM 
    Books
WHERE 
    PublicationYear > 1990;

SELECT * FROM BookDetails;

--TEST RUN
CREATE VIEW ClassicBooks AS
SELECT 
    BookID,
    Title,
    PublicationYear,
    Price
FROM 
    Books
WHERE 
    PublicationYear < 1900;

SELECT * FROM RecentBooks;
SELECT * FROM ClassicBooks;

--CREATE aggregate query that shows the avg.price of books
--for each author and total number of books
--Use Alias for JOIN Statement
--Left JOIN all author on the left
--GROUP BY must appear in SELECT Clause
CREATE VIEW AuthorStats AS
SELECT
    a.AuthorID, a.FirstName + ' ' + a.LastName AS AuthorName,
    COUNT(b.BookID) AS BookCount,
    AVG(b.Price) AS AverageBookPrice
    FROM Authors a
    LEFT JOIN Books b ON a.AuthorID = b.AuthorID
    GROUP BY 
        a.AuthorID, a.FirstName, a.LastName;

SELECT * FROM AuthorStats;



CREATE View AuthorContactInfo AS
    SELECT AuthorID, FirstName, LastName
    From Authors;

UPDATE AuthorContactInfo
SET FirstName = 'Joanne'
WHERE AuthorID = 3;

SELECT * FROM AuthorContactInfo;
SELECT * FROM Authors;

--GET DATE returns current date
CREATE TABLE BookPriceAudit(
    AuditID INT IDENTITY(1,1),
    BookID INT,
    OldPrice DECIMAL(10,2),
    NewPrice DECIMAL(10,2),
    ChangeDate DATETIME DEFAULT GETDATE()
);


--CREATE TRIGGER
--i alias for insert and d for delete
--since we are creating a trigger, the alias is for the trigger

CREATE TRIGGER trg_BookPriceChange
ON Books
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Price)
    BEGIN
        INSERT INTO BookPriceAudit (BookID, OldPrice, NewPrice)
        SELECT 
            i.BookID, d.Price, i.Price
        FROM inserted i
        JOIN deleted d ON i.BookID = d.BookID
    END
END;

UPDATE Books
Set Price = 14.99
WHERE BookID = 1;

SELECT * From BookPriceAudit;

----TEST
CREATE View BookAuthor AS
    SELECT a.AuthorID, a.FirstName, a.LastName, b.BookID, b.Title
    From Authors a
    JOIN Books b ON a.AuthorID = b.AuthorID;

UPDATE Book
SET AuthorID = 1
WHERE BookID = 7;

UPDATE BookAuthor 
SET AuthorID = 1
WHERE BookID = 8;

INSERT INTO Books (BookID, Title, PublicationYear, Price)
VALUES (8, 'Love and Friendship', '1790', 45.00);

