-- SQL flavor postgresql

--Scenario/Goal
    -- Clean/Parse stock exchange json data
     
-- FUNCTIONS 
    -- Convert Epoch time into standard date 
    -- REGEXP_MATCH, UNNEST, MAX, LIKE, CASE STMT, ROUND
     
-- Author Diana Kungu

-- Load Data

DROP TABLE IF EXISTS stck;

CREATE TABLE stck(
    JSON_NAME VARCHAR,
    JSON_VALUE_STRING VARCHAR
);

COPY stck FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\PD - JSON DATA Stock data - PD - JSON DATA Stock data.csv'
DELIMITER ','
CSV HEADER;


-- Exclude 'meta' and '' records in the same column to just leave
-- 'indicators' and 'timestamp'

WITH Dates_tbl AS(
    -- step 1
    -- create key field from digits in the timestamp field
    SELECT  json_name, Date,
            UNNEST(REGEXP_MATCH(Json_name, '\d+$'))::INT as Row_no

    FROM (
            SELECT json_name,
                to_timestamp(json_value_string::BIGINT) AS Date
            FROM stck
            WHERE 
                    JSON_Name LIKE '%.timestamp.%') w
    ),

-- step 2: create trading metrics columns: volume, high, low, close, open, adjclose
    
Stock_metrics AS(
    SELECT json_name,
	UNNEST(REGEXP_MATCH(Json_name, '\d+$'))::INT as Row_no,
	MAX(CASE WHEN JSON_Name LIKE '%.volume.%' THEN JSON_VALUE_STRING::INT  ELSE 0 END) AS volume,
    ROUND(MAX(CASE WHEN JSON_Name LIKE '%.open.%' THEN JSON_VALUE_STRING::numeric  ELSE 0 END),2) AS open,
   	ROUND(MAX(CASE WHEN JSON_Name LIKE '%.high.%' THEN JSON_VALUE_STRING::numeric  ELSE 0 END),2) AS high,
    ROUND(MAX(CASE WHEN JSON_Name LIKE '%.low.%' THEN JSON_VALUE_STRING::numeric  ELSE 0 END),2) AS low,
    ROUND(MAX(CASE WHEN JSON_Name LIKE '%.adjclose.%' THEN JSON_VALUE_STRING::numeric  ELSE 0 END),2) AS adjclose,
   	ROUND(MAX(CASE WHEN JSON_Name LIKE '%.close.%' THEN JSON_VALUE_STRING::numeric  ELSE 0 END),2) AS close
 
FROM stck  
      WHERE 
        JSON_Name LIKE '%.open.%' OR 
        JSON_Name LIKE '%.volume.%' OR 
        JSON_Name LIKE '%.high.%' OR 
        JSON_Name LIKE '%.low.%' OR 
        JSON_Name LIKE  '%.adjclose.%' OR 
        JSON_Name LIKE  '%.close.%' OR 
        JSON_Name LIKE  '%.open.%'
    
GROUP BY
    UNNEST(REGEXP_MATCH(Json_name, '\d+$'))::INT,
    json_name
)

-- Step 3. Join the two queries

SELECT 
	sv.Row_no as "Row",
    d.Date, 
	Max(sv.volume) AS VOLUME, 
	Max(sv.high) AS HIGH, 
	Max(sv.low) AS LOW, 
    Max(sv.open) AS OPEN,
	Max(sv.adjclose) AS ADJCLOSE, 
	Max(sv.close) AS CLOSE
	
FROM Dates_tbl d
LEFT JOIN Stock_metrics sv
	ON d.Row_no = sv.Row_no
GROUP BY
        d.date, sv.Row_no
ORDER BY sv.Row_no
;
