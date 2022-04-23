-- SQL flavor postgresql

--Scenario
    -- You work for a mobile / cell phone company. Pull together the revenue report of your 
    --current batch of contracts.
     
-- GOAL 
    -- Create end date for each contract
    -- Aggregate revenue for each month and customer
    -- JOIN LATERAL

-- Author Diana Kungu

DROP TABLE IF EXISTS mobile_rev;

CREATE TABLE IF NOT EXISTS mobile_rev(
     customer_name VARCHAR,
     monthly_cost INTEGER,
     contract_length INTEGER,
     start_date DATE
    )
;

--COPY Data into table
COPY mobile_rev FROM 'C://Users/DIANA/Desktop/Projects/SQL/Data/phone_contracts.csv'
DELIMITER ','
CSV HEADER;


DROP TABLE IF EXISTS mobile_rev_tbl;

SELECT customer_name, monthly_cost, contract_length, start_date,
    start_date + interval '1 month' * (contract_length-1) AS end_date
INTO  mobile_rev_tbl
FROM   mobile_rev;

SELECT * from mobile_rev_tbl;

select customer_name, monthly_cost, contract_length, start_date,
        dd::date AS "Payment Date"
FROM  mobile_rev_tbl M
JOIN LATERAL generate_series(M.start_date, M.end_date, '1 Month'::interval) dd ON true
