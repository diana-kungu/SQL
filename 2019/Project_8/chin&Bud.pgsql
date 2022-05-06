-- SQL flavor postgresql

-- FUNCTIONS USED: Regexp_match, Case Statements, Date functions

-- Author Diana Kungu

SET datestyle = dmy;

DROP TABLE IF EXISTS w82019, brch;

CREATE TABLE w82019(
    Prod_Type VARCHAR,
    Action VARCHAR,
    Date Date,
    Quantity INTEGER,
    Store_ID VARCHAR,
    Crime_Ref_No VARCHAR
);

CREATE TABLE brch(
     Branch_Id VARCHAR
);

COPY w82019 FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\Theft_Audit.csv'
DELIMITER ','
CSV HEADER;

COPY brch FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\Branch_ID.csv'
DELIMITER ','
CSV HEADER;

-- Step 1  
-- split store_id and location
WITH brc_updated AS(
        SELECT TRIM(SPLIT_PART(branch_id, '-', 1)) AS  Store_ID,
            SPLIT_PART(branch_id, '-', 2) AS  Branch_Name 
        FROM brch),

-- step 2 
--- Correct spellings in Type
--  Create the pivoted metrics for Stock Adjusted, Stock Volume and Theft
--  Sum quantity as Stock Variance
--  Group by Store_ID, Crime Ref and the corrected type

    new_audit  AS(
        SELECT store_id,
            CASE WHEN prod_type = 'Soap Bar' THEN 'Bar'
            WHEN prod_type = 'Luquid' THEN 'Liquid'
            ELSE prod_type END AS prod_type,
            crime_ref_no,
            COUNT(DISTINCT Crime_Ref_no) AS Number_of_records,
            MAX(CASE WHEN Action = 'Stock Adjusted' THEN Date ELSE NULL END) AS Stock_Adjusted,
            SUM(Quantity) AS Stock_Variance,
            MAX(CASE WHEN Action = 'Theft' THEN Quantity ELSE NULL END) AS Stolen_Volume,
            MAX(CASE WHEN Action = 'Theft' THEN Date ELSE NULL END) AS Theft
        FROM w82019
        GROUP BY
		Store_ID,
		Crime_Ref_No,
		CASE 
		WHEN prod_type = 'Soap Bar' THEN 'Bar'
		WHEN prod_type = 'Luquid' THEN 'Liquid'
		ELSE prod_type END
        )

-- Final query
-- Join the new audit query (the previous one) with the new branch one
-- Calculate the days to complete adjustments column

SELECT 
	nb.Branch_name,
	na.Crime_Ref_No, 
	(na.Stock_Adjusted - na.Theft)AS Days_to_complete_adjustment,
    na.Number_of_records, 
	na.Stock_Adjusted, 
	na.Stock_Variance, 
	na.Stolen_Volume, 
	na.Theft, 
	na.Prod_Type
FROM new_audit na
LEFT JOIN brc_updated nb
	ON na.Store_ID = nb.Store_ID
ORDER BY 
	na.Crime_Ref_No
;

