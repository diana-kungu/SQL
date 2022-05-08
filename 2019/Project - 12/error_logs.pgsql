-- SQL flavor postgresql

--Scenario/Goal
    -- Union tables,
     
-- FUNCTIONS 
    -- Timestamp, case stmts, trunc, 
    -- Window_functions
     
-- Author Diana Kungu



-- Step 1: Union the manual and automatic error
-- Create timestamp field in manual table (Start and End date_time)

-- manual log
CREATE TEMP TABLE error_log AS(
    SELECT  'Manual capture error list' AS Error_source, 
        TO_TIMESTAMP(CONCAT(start_date, ' ', start_time), 'DD/MM/YY HH24:MI:SS')::TIMESTAMP AS Start_Date_Time,
        TO_TIMESTAMP(CONCAT(End_date, ' ', End_time), 'DD/MM/YY HH24:MI:SS')::TIMESTAMP AS End_Date_Time,
        TO_DATE(start_date, 'DD/MM/YY') AS start_date,
        system,
        CASE WHEN error LIKE '%Plan%' THEN 'Planned Outage' ELSE Error END As Error 

    from manual_log

    UNION 
    -- automatic log  
        SELECT 
                'Automatic Error log' AS Error_source, 
                Start_Date_Time,
                End_Date_Time,
                start_date_time::Date AS start_date,
                System_Type AS system,
                Error         

        FROM auto_log
);
-- step 2:
-- Create downtime field with duration in hours  
-- create keys to duplicates entries distigush logs from auto and manual log
CREATE TEMP TABLE rnk_error AS(
    SELECT  
            *,
            ROW_NUMBER() OVER (PARTITION BY Start_Date ORDER BY Start_Date, Error_source) AS Issue_rank,
	        CASE WHEN Error = 'Planned Outage' Then 'Planned'ELSE 'Other' END AS Error_category,
            DATE_PART('day', end_date_time - start_date_time ) * 24  + 
               DATE_PART('hour', end_date_time - start_date_time )  +
               DATE_PART('minute', end_date_time - start_date_time)/60 AS Downtime_in_hours
    FROM error_log

);

--SELECT * from rnk_error;

-- step 3:
-- AGGREGATE total down_time, find the % of system downtime for each error category
SELECT  TRUNC((Downtime_in_hours  / SUM(Downtime_in_hours)
             OVER (PARTITION BY Error_category))::NUMERIC, 2) AS "%_of_system_downtime",
        TRUNC(SUM(downtime_in_hours::numeric) OVER (PARTITION BY Error_category),2) AS Total_Downtime_in_hours,
        ROUND(downtime_in_hours::numeric, 2) AS downtime_in_hours,
        Error_Source,
        error_category,
        Error, 
        Start_Date_Time,
        End_Date_Time,
        system
FROM rnk_error
WHERE 
	Issue_rank = 1
ORDER BY 
	downtime_in_hours
;
