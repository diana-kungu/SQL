-- SQL flavor postgresql

--Scenario/Goal
 /* import & combine all the data from the file without deleting the non-sales data that was accidentally sent to you
 rank the customers by total sales across orders placed within the last 6 months.
        NB: For this challenge, calculate "last 6 months" from 24/05/2019, not today's date.
Find a way to filter these down to customers in the top 8%.
     
-- FUNCTIONS 
    -- UNION,WINDOW FUNCTIONS, Aggregate, Inheritance
--*/
-- Step 1:
-- Create a schema to hold sales tables

--CREATE SCHEMA soap;
/*   CREATE TABLE soap.S_Barsoap(
        Email VARCHAR,
        Order_Total Float,
        ORDER_Date Date
    );
    CREATE TABLE soap.S_Budgetsoap()
        INHERITS (soap.S_Barsoap);

    CREATE TABLE soap.S_Accessories()
        INHERITS (soap.S_Barsoap);
    CREATE TABLE soap.S_Liquid()
        INHERITS (soap.S_Barsoap);
    CREATE TABLE soap.S_Plasma()
        INHERITS (soap.S_Barsoap);
    CREATE TABLE soap.emails_1(
        Email VARCHAR
    );
    CREATE TABLE soap.Emails_2()
        INHERITS (soap.emails_1);

        */
-- Step 1:
-- Union sales tables
-- Aggregate sales per email address
-- Filter sales in last six months of date 24/05/2019
  
CREATE TEMP TABLE Soap_Sales AS(
    SELECT email,
            SUM(order_total) AS new_total_order
    FROM
        (SELECT * from soap.S_Barsoap
            UNION SELECT * FROM soap.S_Budgetsoap
            UNION SELECT * FROM soap.S_Accessories
            UNION SELECT * FROM soap.S_Liquid
            UNION SELECT * FROM soap.S_Plasma
        ) a
    WHERE 
         Order_Date > (To_Date('24/05/2019', 'DD/MM/YYYY')) - interval '6 month'
    GROUP BY Email
);

-- Results
-- Calculate the cumulative distribution of total orders and ranks per email address
-- Filter top 8% percentile 

SELECT S.Email,
        s.new_total_order,
        s.rank
FROM
    (SELECT 
        email, new_total_order,
        RANK() OVER (ORDER BY new_total_order DESC),
        cume_dist() over (order by new_total_order DESC) as Cum_Dist
    FROM SOAP_SALES
    ) s
WHERE Cum_Dist <= 0.08;



