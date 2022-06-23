USE AdventureWorks2019
GO

-- 1. Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables. Join them and produce a result set similar to the following.
SELECT cr.Name AS Country, sp.Name AS Province
FROM Person.StateProvince sp Join Person.CountryRegion cr on sp.CountryRegionCode = cr.CountryRegionCode

-- 2. Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Germany and Canada. Join them and produce a result set similar to the following.
SELECT cr.Name AS Country, sp.Name AS Province
FROM Person.StateProvince sp Join Person.CountryRegion cr on sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name in ('Germany', 'Canada')

USE Northwind
GO
-- 3. List all Products that has been sold at least once in last 25 years.
SELECT P.ProductName
FROM Products P JOIN [Order Details] O ON P.ProductID = O.ProductID JOIN Orders R ON R.OrderID = O.OrderID
WHERE R.OrderDate BETWEEN '1997-06-23' AND '2022-06-23'

-- 4. List top 5 locations (Zip Code) where the products sold most in last 25 years.
SELECT TOP 5 ShipPostalCode
FROM Orders
GROUP BY ShipPostalCode
ORDER BY ShipPostalCode DESC

-- 5. List all city names and number of customers in that city.   
SELECT City, COUNT(ContactName) AS 'Number of Customers in City'
FROM Customers
GROUP BY City

-- 6. List city names which have more than 2 customers, and number of customers in that city
SELECT City, COUNT(ContactName) AS 'Number of Customers in City'
FROM Customers
GROUP BY City
HAVING COUNT(ContactName) > 2

-- 7. Display the names of all customers  along with the  count of products they bought
SELECT C.ContactName, COUNT(C.ContactName) AS 'SellProducts'
FROM Orders O JOIN Customers C ON O.CustomerID = C.CustomerID
GROUP BY C.ContactName
ORDER BY COUNT(C.ContactName) DESC

-- 8. Display the customer ids who bought more than 100 Products with count of products.
SELECT C.ContactName, SUM(OD.Quantity) AS 'TotalQuantity'
FROM Orders O JOIN Customers C ON O.CustomerID = C.CustomerID JOIN [Order Details] OD ON OD.OrderID = O.OrderID
GROUP BY C.ContactName
HAVING SUM(OD.Quantity) > 100
ORDER BY SUM(OD.Quantity) DESC

-- 9. List all of the possible ways that suppliers can ship their products. Display the results as below
SELECT U.CompanyName AS 'Supplier Company Name', S.CompanyName AS 'Shipping Company Name'
FROM Shippers S CROSS JOIN Suppliers U

-- 10. Display the products order each day. Show Order date and Product Name.
SELECT O.OrderDate, P.ProductName
FROM Products P JOIN [Order Details] OD ON P.ProductID = OD.ProductID JOIN Orders O ON O.OrderID = OD.OrderID

-- 11. Displays pairs of employees who have the same job title.
SELECT *
FROM Employees E JOIN Employees M ON E.Title = M.Title

-- 12. Display all the Managers who have more than 2 employees reporting to them.
SELECT E.EmployeeID, E.LastName, E.FirstName, E.Title
FROM Employees E JOIN Employees M ON E.EmployeeID = M.ReportsTo
WHERE E.Title LIKE '%Manager%'
GROUP BY E.EmployeeID, E.LastName, E.FirstName, E.Title
HAVING COUNT(M.ReportsTo) > 2

-- 13. Display the customers and suppliers by city. The results should have the following columns
SELECT City, ContactName, 'Customer' AS TYPE
FROM Customers
UNION
SELECT City, ContactName, 'Supplier' AS TYPE
FROM Suppliers

-- 14. List all cities that have both Employees and Customers.
SELECT City
FROM Customers
WHERE City IN
(
SELECT City
FROM Employees
)

-- 15. List all cities that have Customers but no Employee.
-- a. Use sub-query
SELECT DISTINCT City
FROM Customers
WHERE City NOT IN
(
SELECT City
FROM Employees
)
-- b. Do not use sub-query
SELECT DISTINCT C.City
FROM Customers C LEFT JOIN Employees E ON C.City = E.City

-- 16. List all products and their total order quantities throughout all orders.
SELECT C.CustomerID, C.CompanyName, C.ContactName, SUM(OD.Quantity) AS TotalQuantity
FROM Customers C LEFT JOIN Orders O ON C.CustomerID = O.CustomerID LEFT JOIN [Order Details] OD ON OD.OrderID = O.OrderID
GROUP BY C.CustomerID, C.CompanyName, C.ContactName
ORDER BY TotalQuantity DESC

-- 17. List all Customer Cities that have at least two customers.
-- a. Use union
SELECT C.City
FROM Customers C
GROUP BY C.City
HAVING COUNT(C.City) > 2
UNION
SELECT CU.City
FROM Customers CU
GROUP BY CU.City
HAVING COUNT(CU.City) = 2

-- b. Use no union
SELECT DISTINCT C.City
FROM Customers C
WHERE C.City IN
(
SELECT CU.City
FROM Customers CU
GROUP BY CU.City
HAVING COUNT(CU.City) >= 2
)

-- 18. List all Customer Cities that have ordered at least two different kinds of products.
SELECT DISTINCT C.City
FROM Orders O JOIN Customers C ON O.CustomerID = C.CustomerID JOIN [Order Details] OD ON OD.OrderID = O.OrderID
GROUP BY C.City, OD.ProductID
HAVING COUNT(OD.ProductID) > 2

-- 19. List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
WITH ordersCTE
as(
SELECT OC.ShipCity, OC.ProductID, OC.AVERAGE,DENSE_RANK() OVER (partition by OC.ProductID order by OC.NUMBER) RNK
FROM (
SELECT TOP 5 OD.ProductID, O.ShipCity, SUM(Quantity) NUMBER,AVG(od.UnitPrice) AVERAGE
FROM Orders O left join [Order Details] OD on O.OrderID = OD.OrderID
GROUP BY O.ShipCity, OD.ProductID
ORDER BY number DESC
) OC
)
select * from ordersCTE where RNK=1

-- 20. List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)
SELECT *
FROM
(
SELECT TOP 1 E.City, COUNT(O.OrderID) COrder
FROM Employees E JOIN Orders O ON E.EmployeeID = O.EmployeeID
GROUP BY E.City
) C1
JOIN
(
SELECT TOP 1 C.City, COUNT(OD.Quantity) CQuantity
FROM [Order Details] OD JOIN Orders O ON OD.OrderID = O.OrderID JOIN Customers C ON C.CustomerID = O.CustomerID
GROUP BY C.City
) C2
ON C1.City = C2.City

-- 21. How do you remove the duplicates record of a table?
-- Find duplicates using GROUP BY, and using DELETE statement to remove duplicates.