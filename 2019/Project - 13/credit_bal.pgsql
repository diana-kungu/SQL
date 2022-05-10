-- SQL flavor postgresql

--Scenario/Goal
    -- What is the average weekly, monthly and quarterly balance?
    -- What is the average weekly, monthly and quarterly transaction value?
    -- How many days does the customer have a negative balance?
    -- How many days does the customer exceed their credit limit?
     
-- FUNCTIONS 
    -- Joins,
    -- Date Parsing, Aggregate 
     

-- Step 1: Join transaction and customer details tables
-- Create date fields; week number, month and quarter
-- Flag days where balance is less than 0
-- Flag days where customer's balance is below their credit limit

CREATE TABLE Trans_compiled AS(
SELECT t.account,
       t.date,
       t.transaction,
       t.balance,
       c.c_name,
       c.max_credit,
       Date_Part('Quarter', Date) As Quarter,
       EXTRACT(MONTH FROM Date) AS Month,
       Date_Part('Week', Date)AS Week, 
       CASE WHEN Balance <= 0 THEN 1 ELSE 0 END AS day_below_zero_balance,
	   CASE WHEN Balance >= -Max_Credit THEN 0 ELSE 1 END AS day_beyond_credit_limit
from transations t
    LEFT JOIN customers c 
        USING(Account) 
);

-- Report 1: Weekly

SELECT account,
       Min(Date),
       c_name,
       Week,
       SUM(day_below_zero_balance) AS day_below_zero_balance,
       Sum(day_beyond_credit_limit) AS day_beyond_credit_limit,
       TRUNC(AVG(Balance), 2) AS Weekly_Avg_Balance,
       TRUNC(AVG(Transaction),2) AS Weekly_AVG_Transaction
FROM Trans_compiled
GROUP BY
    week, c_name, account
ORDER BY Min(date);


--- Report 2: monthly
SELECT account,
       Min(Date),
       c_name,
       month,
       SUM(day_below_zero_balance) AS day_below_zero_balance,
       Sum(day_beyond_credit_limit) AS day_beyond_credit_limit,
       TRUNC(AVG(Balance), 2) AS monthly_Avg_Balance,
       TRUNC(AVG(Transaction),2) AS monthly_AVG_Transaction
FROM Trans_compiled
GROUP BY
    month, c_name, account
ORDER BY Min(date);


--- Report 3: Quarterly
SELECT account,
       Min(Date),
       c_name,
       Quarter,
       SUM(day_below_zero_balance) AS day_below_zero_balance,
       Sum(day_beyond_credit_limit) AS day_beyond_credit_limit,
       TRUNC(AVG(Balance), 2) AS Quarterly_Avg_Balance,
       TRUNC(AVG(Transaction),2) AS Quarterly_AVG_Transaction
FROM Trans_compiled
GROUP BY
    Quarter, c_name, account
ORDER BY Min(date);

-- Remove table
DROP TABLE Trans_compiled;