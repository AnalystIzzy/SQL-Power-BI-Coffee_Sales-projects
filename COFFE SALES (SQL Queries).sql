SELECT *
FROM coffeeshop_sales;-- After checking, i saw i needed to do some data cleaning

DESCRIBE coffeeshop_sales;-- From the result , I had the datatype of the transaction date & time column as TEXT instead of DATE and TIME

UPDATE coffeeshop_sales
SET transaction_date = str_to_date(transaction_date, '%m/%d/%Y');

ALTER TABLE coffeeshop_sales
MODIFY COLUMN transaction_date DATE;

UPDATE coffeeshop_sales
SET transaction_time = str_to_date(transaction_time, '%H:%i:%s');

ALTER TABLE coffeeshop_sales
MODIFY COLUMN transaction_time TIME;

ALTER TABLE coffeeshop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;-- DATA CLEANING DONE!!!


-- ------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------KPIs----------------------------------------------------------------------------

-- 1. TOTAL SALES

SELECT SUM(transaction_qty * unit_price) Total_Sales
FROM coffeeshop_sales; 
/* WHERE 
MONTH(transaction_date) = 5;(Add the where clause to filter by months)*/

-- 2.MONTH ON MONTH DIFFERENCE AND MONTH ON MONTH GROWTH IN RESPECT TO SALES

SELECT 
    MONTH(transaction_date) AS month,-- Number of Month
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,-- Total Sales Column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) -- Month Sale Difference
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1)-- Division by Previous Month Sales
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage-- percentage
FROM 
    coffeeshop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
-- 3.TOTAL ORDERS PER MONTH
SELECT COUNT(transaction_id) Total_Sales
FROM coffeeshop_sales 
WHERE 
MONTH(transaction_date) = 3;-- (Add the where clause to filter by months)

-- 4.MONTH ON MONTH DIFFERENCE AND MONTH ON MONTH GROWTH IN RESPECT TO ORDERS
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffeeshop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
-- 5.TOTAL QUANTITY SOLD PER MONTH
SELECT SUM(transaction_qty) Total_Qty_Sold
FROM coffeeshop_sales 
WHERE 
MONTH(transaction_date) = 5;-- (Add the where clause to filter by months)

-- 6.MONTH ON MONTH DIFFERENCE AND MONTH ON MONTH GROWTH IN RESPECT TO QUANTITIES SOLD
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS MoM_increase_percentage
FROM 
    coffeeshop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
-- 7.CALENDAR TABLE: DAILY SALES,QUANTITY SOLD AND ORDERS
SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(transaction_id) AS total_orders
FROM 
    coffeeshop_sales
WHERE 
    transaction_date = '2023-05-18'; -- For 18 May 2023
    
-- To get exact Rounded off values then :
SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
    coffeeshop_sales
WHERE 
    transaction_date = '2023-05-18'; -- For 18 May 2023
    
-- 8.SALES OVER WEEKDAYS AND WEEKENDS
SELECT
	CASE
		WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
        ELSE 'Weekdays'
	END AS Period_of_Week,
SUM(unit_price * transaction_qty) AS total_sales
FROM coffeeshop_sales
WHERE MONTH(transaction_date) = 2 -- FEBRUARY
GROUP BY Period_of_Week;

-- 9.SALES BY STORE LOCATION
SELECT 
	store_location,
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') as Total_Sales
FROM coffeeshop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY store_location
ORDER BY Total_Sales DESC;

-- 10.DAILY AVERAGE SAE PERFORMANCE
SELECT AVG(total_sales) AS avg_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        coffeeshop_sales
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
) AS AVGSales;

-- 11.DAILY SALES PER MONTH
SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffeeshop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY day_of_month
ORDER BY day_of_month;

-- 12.DAILY SALES VS AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffeeshop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
-- 13.SALES BY PRODUCT CATEGORY
SELECT 
    product_category,
    ROUND(SUM(unit_price * transaction_qty), 1) AS Total_Sales
FROM
    coffeeshop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;

-- 13.SALES BY PRODUCT TYPE
SELECT 
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffeeshop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;

-- 14.SALES BY HOUR
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffeeshop_sales
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)
    
-- 15.TOTAL SALES BY WEEKDAYS
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffeeshop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY Day_of_Week;

-- 16.SALES FOR ALL HOURS FOR A SELECTED MONTH
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffeeshop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);
    