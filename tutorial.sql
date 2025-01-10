-- Examine the employees, employeeterritories, and territories tables
SELECT *
FROM employees;

SELECT *
FROM employeeterritories;

SELECT *
FROM territories;


-- Show all employeeids and their territoryid (including possible nulls)
SELECT employeeid, territoryid
FROM employees

FULL OUTER JOIN employeeterritories USING(employeeid)
FULL OUTER JOIN territories USING(territoryid);
		

-- Show each employee full name and their territorydescription
SELECT firstname || ' ' || lastname AS fullname,
-- 	   CONCAT(firstname, ' ', lastname) AS fullname,
	   territorydescription
FROM employees 

LEFT JOIN employeeterritories USING(employeeid)
LEFT JOIN territories USING(territoryid);


-- Show each employee full name and their regiondescription
SELECT DISTINCT firstname || ' ' || lastname AS fullname,
-- 	   CONCAT(firstname, ' ', lastname) AS fullname,
	   --territorydescription, --WHY ARE THERE MULTIPLE INSTANCES OF EMPLOYEES?
	   regiondescription
FROM employees

LEFT JOIN employeeterritories USING(employeeid)
LEFT JOIN territories USING(territoryid)
LEFT JOIN region USING(regionid);


-- SELECT subquery example
-- E.g. Make a table with product names, units in stock and average units in stock for all products
SELECT productname, unitsinstock,
	(SELECT AVG(unitsinstock) FROM products) AS avg_unitsinstock
FROM products;


-- WHERE subquery example
-- E.g. List information on products that never had a discount > 0.20
SELECT *
FROM products
WHERE productid NOT IN

	(SELECT	DISTINCT productid
	FROM order_details
	WHERE discount > 0.20
	ORDER BY productid);


-- FROM subquery example
-- E.g. Find average price of products with units in stock above 100
SELECT AVG(unitprice)
FROM
	(SELECT	*
	FROM products
	WHERE unitsinstock > 100) AS large_unitsinstock_products;


-- Exercises Using the Northwind Database (try to avoid JOINs)
-- Show orderid, country and freight difference from overall average freight
SELECT orderid,
	   shipcountry,
	   freight,
	   (SELECT AVG(freight) FROM orders) AS d,
	   (freight - (SELECT AVG(freight) FROM orders)) AS diff_from_avg_freight
 	   --ROUND((freight - (SELECT AVG(freight) FROM orders))::NUMERIC, 3) AS diff_from_avg_freight
FROM orders;

-- Compare average freight of orders to Germany with average freight of orders to France
SELECT
	(SELECT	AVG(freight) AS avg_freight_germany
	FROM orders
	WHERE shipcountry = 'Germany')
	-
	(SELECT	AVG(freight) AS avg_freight_france
	FROM orders
	WHERE shipcountry = 'France') AS freight_difference;

-- Show all products (names) with a supplier from Germany
SELECT *
FROM products
WHERE supplierid IN
	(SELECT	supplierid
	FROM suppliers
	WHERE country = 'Germany');

SELECT * FROM order_details
LIMIT 10;

-- Show orderid and country for orders with higher than average total value (including discount)
SELECT orderid, shipcountry
FROM orders
WHERE orderid IN
	-- filter to keep only orders above average total value
	(SELECT	orderid
	FROM order_details
	GROUP BY orderid
	HAVING SUM(unitprice * quantity * (1-discount)) >
		-- average order value
	 	(SELECT	AVG(order_value)
		FROM	-- order values for each order
			(SELECT	orderid,
			-- calculate total order value
			SUM(unitprice * quantity * (1-discount)) AS order_value
			FROM order_details
			GROUP BY orderid) AS order_values));