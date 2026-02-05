-- Query #1: Using a Join
-- Default JOIN type is INNER JOIN
SELECT C.CompanyName, O.OrderDate
FROM Customers AS c
JOIN Orders AS o ON c.CustomerID = o.CustomerID;

-- QUERY #2: LEFT JOIN
SELECT c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate
FROM Customers AS c
LEFT JOIN Orders AS o ON c.CustomerID = o.CustomerID;

--QUERY #3: Built-In FUnction *WOO HOO*
SELECT OrderID, ROUND(SUM( UnitPrice * Quantity * (1 - Discount)), 2) AS TotalValue,
Count(*) AS NumberOfItems
FROM [Order Details]
GROUP BY OrderID
ORDER BY TotalValue DESC;

--QUERY #4: Group records to get number of times each products is ordered
-- Filter order of products 10 or more
SELECT p.ProductID, p.ProductName, COUNT(od.OrderID) AS TimesOrdered
FROM [Products] AS p
JOIN [Order Details] AS od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName
HAVING COUNT(od.OrderID) > 10
ORDER BY TimesOrdered DESC;

--QUERY #5: Subquery: User a subquery to get avg proce of product;
-- then display product info
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice > (
    SELECT AVG(UnitPrice) FROM Products
)
ORDER BY UnitPrice;


--QUERY #6: Join three tables together
SELECT o.OrderID, o.OrderDate, p.ProductName, od.Quantity, od.UnitPrice
FROM Orders AS o
JOIN [Order Details] AS od ON o.OrderID = od.OrderID
JOIN Products AS p ON od.ProductID = p.ProductID
WHERE o.OrderID = 10248
ORDER BY p.ProductName ;

--QUERY #6b: Test for ALL
SELECT o.OrderID, o.OrderDate, p.ProductName, od.Quantity, od.UnitPrice
FROM Orders AS o
JOIN [Order Details] AS od ON o.OrderID = od.OrderID
JOIN Products AS p ON od.ProductID = p.ProductID
ORDER BY p.ProductName ;

--Query #7: Get avg product price by category
SELECT c.CategoryName, ROUND(AVG(p.UnitPRice), 2) AS AveragePrice
FROM Categories AS c
JOIN Products AS p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName
ORDER BY AveragePrice DESC;

--Query #8: Count orders by Employees / GROUP BY MUST BE IN SELECT
SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS EmployeeName, COUNT(o.OrderID) AS NumberOfOrders
FROM Employees AS e
JOIN Orders AS o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY NumberOfOrders DESC;

--Query #8b: Count orders by Employees by ID / GROUP BY MUST BE IN SELECT
SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS EmployeeName, COUNT(o.OrderID) AS NumberOfOrders
FROM Employees AS e
JOIN Orders AS o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY EmployeeID DESC;