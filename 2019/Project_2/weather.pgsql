-- SQL flavor postgresql

--INPUTS
    -- csv file - weather
-- GOAL 
    -- Pivot the data to give a measure per column 
    -- for the four metrics in the data set
    -- Aggregation

-- Author Diana Kungu
DROP TABLE IF EXISTS weather;

CREATE TABLE IF NOT EXISTS weather(
    city VARCHAR,
    metric VARCHAR,
    measure VARCHAR,
    value int,
    date DATE);
 
SET datestyle TO iso, dmy;

COPY weather FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\Weather Wk 2.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM weather;

SELECT  
	CASE 
		WHEN City ILIKE '%Lond%' THEN 'London' 
		WHEN City LIKE '%burg%' THEN 'Edinburg'	
		WHEN City LIKE '%nod%' THEN 'London'
		WHEN City ILIKE '%edi%' THEN 'Edinburg'
        WHEN City LIKE '%borg%' THEN 'Edinburg'	
		
	END AS City_corrected,
	date,
    SUM(CASE WHEN Metric = 'Wind Speed' THEN weather.value ELSE 0 END) AS "Wind_speed__mph",
    SUM(CASE WHEN Metric = 'Max Temperature' THEN Value ELSE 0 END) AS "Max_Temperature_-_Celsius",
	SUM(CASE WHEN Metric = 'Min Temperature' THEN Value ELSE 0 END) AS "Min Temperature_-_Celsius",
	SUM(CASE WHEN Metric = 'Precipitation' THEN Value ELSE 0 END) AS "Precipitation_-_mm"

FROM weather
GROUP BY
    City_corrected,
    Date
ORDER BY
	City_corrected DESC,
	Date
;

