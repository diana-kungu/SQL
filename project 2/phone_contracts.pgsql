-- SQL flavor postgresql

--Scenario
--You work for a mobile / cell phone company. You boss asks you to pull together the 
--revenue report of your current batch of contracts. They need to know how much revenue
-- is generated each month from these contracts whilst they are 'live' 

-- GOAL 
    -- Calculate the monthly cumulative cost of each person's contract
    -- for the duration of the contract_length.


-- Load data

DROP TABLE IF EXISTS phone_contracts;

CREATE TABLE IF NOT EXISTS phone_contracts (
     C_name VARCHAR,
     monthly_cost INTEGER,
     contract_length INTEGER,
     start_date DATE
    )
;

--COPY Data into table
\COPY phone_contracts FROM 'C://Users/DIANA/Desktop/Projects/SQL/Data/phone_contracts.csv'
DELIMITER ','
CSV HEADER;


DROP TABLE IF EXISTS tbl;

-- Create an End date for each person's contract

SELECT *,
    start_date + interval '1 month' * (contract_length-1) AS end_date
INTO TEMP tbl
FROM phone_contracts
;

DROP TABLE IF EXISTS tbl_1;

 -- Create cumulative_monthly_cost column for the duration of each contract
SELECT c_name, monthly_cost, d.Payment_date::date,
        sum(monthly_cost) OVER (PARTITION BY c_name ORDER BY d.Payment_date::date)
        AS Cumulative_monthly_cost
INTO tbl_1
FROM tbl t
CROSS JOIN generate_series(start_date, end_date
                          , interval  '1 Month') AS d(Payment_date)
;

-- Save output to csv
COPY tbl_1
TO '~\Output\phone_contracts.csv'
CSV HEADER
;