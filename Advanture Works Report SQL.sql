-- Q0 Union
-- The query combines all rows from fact_internet_sales and fact_internet_sales_new table using the UNION operator.

select * from fact_internet_sales
union
select * from fact_internet_sales_new;

-- Q1  Productname 
-- This query retrieves the ProductKey from the salesf table and the corresponding EnglishProductName
-- from the dimproduct table, using an inner join on ProductKey.

SELECT 
    S.ProductKey,
    P.EnglishProductName
    FROM 
    salesf S
JOIN 
    dimproduct P
ON 
    S.ProductKey = P.ProductKey;


-- Q2 A) Customerfullname
-- This query combines the FirstName, MiddleName, and LastName columns 
-- from the dimcustomer table into a single string, separated by spaces. The result is labeled as FullName.
SELECT CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS FullName
FROM dimcustomer;


-- Q2 B) Customer and Unit Price 
-- This query calculates the TotalPrice by multiplying OrderQuantity and UnitPrice 
-- for each product in fact_internet_sales table, joining  with the dimproduct table on ProductKey.

SELECT  
    s.ProductKey, 
    s.UnitPrice, 
    s.OrderQuantity,
    (s.OrderQuantity * s.UnitPrice) AS TotalPrice
FROM 
    fact_internet_sales s
JOIN 
    dimproduct p
ON 
    s.ProductKey = p.ProductKey;		


-- Q3 the following fields from the Orderdatekey
-- This query converts orderdatekey from YYYYMMDD format into a date and labels it as OrderDate.
SELECT STR_TO_DATE(orderdatekey, '%Y%m%d') AS OrderDate FROM salesf;

-- A) Year
SELECT STR_TO_DATE(orderdatekey, '%Y%m%d') AS OrderDate, YEAR(OrderDatekey) AS Year FROM salesf;
-- B) Month 
select STR_TO_DATE(orderdatekey, '%Y%m%d') AS OrderDate, Month(orderdatekey) as Month from salesf;
-- C) Month Name
select STR_TO_DATE(orderdatekey, '%Y%m%d') AS OrderDate, monthname(orderdatekey) as Month_Name from salesf;
-- D) Quarter 
select STR_TO_DATE(orderdatekey, '%Y%m%d') AS OrderDate, quarter(orderdatekey) as Quarter FROM salesf;
-- E) YearMonth
SELECT STR_TO_DATE(orderdatekey, '%Y%m%d') AS OrderDate, DATE_FORMAT(OrderDatekey, '%Y-%m') AS YearMonth FROM salesf;
-- F) Week Day Number
SELECT STR_TO_DATE(orderdatekey, '%Y%m%d') AS OrderDate,DAYOFWEEK(OrderDatekey) AS WeekdayNumber FROM salesf;
-- G) Week Day Name 
SELECT STR_TO_DATE(orderdatekey, '%Y%m%d') AS OrderDate,DAYNAME(OrderDatekey) AS WeekdayName FROM salesf;

-- H) Financial Month
-- This query converts orderdatekey into a date, extracts the calendar month,
--  and calculates the financial month, with the fiscal year starting in April.

SELECT STR_TO_DATE(orderdatekey, '%Y%m%d') AS OrderDate,
    MONTH(orderdatekey) AS CalendarMonth,
    CASE 
        WHEN MONTH(orderdatekey) >= 4 THEN MONTH(orderdatekey) - 3
        ELSE MONTH(orderdatekey) + 9
    END AS FinancialMonth
FROM 
     salesf ;

-- I  Financial Quarter 

SELECT STR_TO_DATE(orderdatekey, '%Y%m%d') AS OrderDate,

    CASE 
        WHEN MONTH(orderdatekey) IN (4, 5, 6) THEN 'Q1'
        WHEN MONTH(orderdatekey) IN (7, 8, 9) THEN 'Q2'
        WHEN MONTH(orderdatekey) IN (10, 11, 12) THEN 'Q3'
        ELSE 'Q4' -- January, February, March
    END AS FinancialQuarter
FROM salesf ;


-- Q4 Calculate the Sales amount 
-- This query calculates the SalesAmount by applying a discount to the product of UnitPrice 
-- and OrderQuantity, retrieving all relevant values from the salesf table

SELECT 
    UnitPrice,
    OrderQuantity,
    DiscountAmount,
    (UnitPrice * OrderQuantity * (1 - DiscountAmount)) AS SalesAmount
FROM salesf ;


-- Q5  Production Cost
-- This query calculates the ProductionCost by multiplying UnitPrice and OrderQuantity, retrieving the values from the salesf table.
SELECT 
    UnitPrice,
    OrderQuantity,
    (UnitPrice * OrderQuantity) AS ProductionCost
FROM salesf;


-- Q6 profit
-- This query calculates Profit by subtracting TotalProductCost from SalesAmount, retrieving these values from the salesf table.
SELECT 
    SalesAmount,
    TotalProductCost,
    (SalesAmount - TotalProductCost) AS Profit
FROM salesf ;

-- Q8 yearwise Sales
-- This query calculates the total SalesAmount for each year, compares  with the previous year's sales using LAG(), 
-- and computes the year-over-year  change percentage. The results are grouped by year.

select year(orderdatekey)as year,sum(SalesAmount),lag(sum(SalesAmount)) over(order by year(orderdatekey)) as previous_year,
 (sum(SalesAmount)-lag(sum(SalesAmount)) over(order by year(orderdatekey )))*100/lag(sum(SalesAmount)) over(order by year(orderdatekey)) as yoy_changes 
 from salesf group by year(orderdatekey);
 
-- Q9 Month Wise Sales 

SELECT 
    MONTH(orderdatekey) AS month,
    SUM(SalesAmount) AS current_month_sales,
    LAG(SUM(SalesAmount)) OVER(ORDER BY MONTH(orderdatekey)) AS previous_month_sales,
    (SUM(SalesAmount) - LAG(SUM(SalesAmount)) OVER(ORDER BY MONTH(orderdatekey))) * 100 
        / LAG(SUM(SalesAmount)) OVER(ORDER BY MONTH(orderdatekey)) AS MoM_changes
FROM 
    salesf
GROUP BY 
    MONTH(orderdatekey);


-- Q10 Quarter Wise Sales

		SELECT 
			QUARTER(orderdatekey) AS quarter,
			SUM(SalesAmount) AS current_quarter_sales,
			LAG(SUM(SalesAmount)) OVER(ORDER BY QUARTER(orderdatekey)) AS previous_quarter_sales,
			(SUM(SalesAmount) - LAG(SUM(SalesAmount)) OVER(ORDER BY QUARTER(orderdatekey))) * 100 
				/ LAG(SUM(SalesAmount)) OVER(ORDER BY QUARTER(orderdatekey)) AS QoQ_changes
		FROM 
			salesf
		GROUP BY 
			QUARTER(orderdatekey);
			
    
-- 11 Sales And Production Cost 
-- This query calculates the total sales and ProductionCost for each year by summing SalesAmount
-- and the product of UnitPrice and OrderQuantity, respectively, grouped by year.

select year(orderdatekey) as Year,
 sum(salesamount) as sales,
 sum(UnitPrice*OrderQuantity) as ProductionCost 
 from salesf group by year(orderdatekey);


-- 12  Top 10 Product Wise Sales
-- This query retrieves the top 10 products (EnglishProductName) by total SalesAmount.
-- using a left join between salesf and dimproduct tables, grouped by product name and ordered by sales amount.

select  P.EnglishProductName, sum(salesamount) from  salesf S left join dimproduct P on
    S.ProductKey = P.ProductKey group by P.EnglishProductName order by sum(SalesAmount) limit 10 ;

-- 12 Top 10 Region Wise Sales 
    select R.SalesTerritoryRegion, sum(salesamount) from salesf S left join dimsalesterritory R on 
    S.SalesTerritoryKey = R.SalesTerritoryKey group by R.SalesTerritoryRegion order by sum(SalesAmount) limit 10 ;	
    
    	
-- 12 Top 10 Customers Wise Sales 

    select  CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS FullName, sum(salesamount) from salesf S left join dimcustomer C on
     S.CustomerKey = C.CustomerKey Group by CONCAT(FirstName, ' ', MiddleName, ' ', LastName) order by sum(SalesAmount) limit 10 ;

