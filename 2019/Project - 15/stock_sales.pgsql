-- SQL flavor postgresql

--Scenario/Goal
 /**/
     
-- FUNCTIONS 
    -- Joins,
    -- Date Parsing, Aggregate 
--/*
-- Step 1:
-- Union all region tables 
CREATE TEMP TABLE stocks_all AS (
    SELECT *,
            'East' AS Region 
    FROM stocks.east 
    UNION
    SELECT *,
            'cental' AS Region 
    FROM stocks.cental
    UNION
    SELECT *,
            'north' AS Region 
    FROM stocks.north
    UNION
    SELECT *,
            'south' AS Region 
    FROM stocks.south
    UNION
    SELECT *,
            'west' AS Region 
    FROM stocks.west
    );

-- Step 2:
-- Aggregate sales per stock and stock + region
-- calculate % of sales grouped by stock and stock + region
-- Create row flag per stock + region

CREATE TEMP TABLE stocks_agg AS (
        select *,
                SUM(Sales) OVER (PARTITION BY Stock) AS Total_sales,
                SUM(Sales) OVER (PARTITION BY Stock, Region) AS Total_Regional_Sales,
                Sales / SUM(Sales) OVER (PARTITION BY Stock) * 100.0 AS "%_of_Total_Sales",
                Sales / SUM(Sales) OVER (PARTITION BY Stock, Region) * 100.0 AS "%_of_Regional_Sales",
                COUNT(*) OVER (PARTITION BY Stock, Region ORDER BY Stock, Region) AS Transactions_per_region
        from stocks_all
);

-- STEP 3
-- Filter out rows that show one transaction per state for the same stock

SELECT
    "%_of_Regional_Sales",
    "%_of_Total_Sales",
    CustomerID,
    FirstName,
    LastName,
    Sales,
    Order_Date,
    Stock,
    Total_Regional_Sales,
    Total_sales
FROM
    stocks_agg
WHERE
    Transactions_per_region > 1
;