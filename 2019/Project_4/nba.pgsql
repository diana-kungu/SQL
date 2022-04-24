-- SQL flavor postgresql

-- GOAL 
    --Clean Date field 
    -- FUNCTIONS USED: Split_part, To_date, Extract + Month

-- Author Diana Kungu

DROP TABLE IF EXISTS nba;

CREATE TABLE nba(
    "Date" VARCHAR,
    "Opponent" VARCHAR,
    "Result" VARCHAR,
    "W-L" VARCHAR,
    "HI-Points" VARCHAR,
    "HI-Rebounds" VARCHAR,
    "HI-Assists" VARCHAR
);

COPY nba FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\PD - ESPN stats.csv'
DELIMITER ','
CSV HEADER;

DROP TABLE IF EXISTS nba_cleaned;

SELECT 
        "W-L",
        "Result",
        
       -- Split Player name and valuee 
        SPLIT_PART("HI-Points", ' ',1) AS "HI-Points Player",
        SPLIT_PART("HI-Points", ' ',2)AS "HI-Points Value",
        SPLIT_PART("HI-Rebounds", ' ',1)AS "HI-Rebounds Player",
        SPLIT_PART("HI-Rebounds", ' ',2)AS "HI-Rebounds Value",
        SPLIT_PART("HI-Assists", ' ',1)AS "HI-Assists Player",
        SPLIT_PART("HI-Assists", ' ',2)AS "HI-Assists Value",
        -- Home or Away
        CASE WHEN LEFT("Opponent",2) = 'vs' THEN 'Home' 
            WHEN LEFT("Opponent",1) = '@' THEN 'Away'
            ELSE 'Check'
            END AS Home_or_Away,
        -- Opponent
        CASE WHEN LEFT("Opponent", 2) = 'vs' THEN REPLACE("Opponent", 'vs', '')
            WHEN LEFT("Opponent", 1) = '@' THEN REPLACE("Opponent", '@', '')
            END AS "Opponent_cleaned",
        -- date
        TO_DATE(CONCAT(SPLIT_PART("Date", ' ',3), '-' ,SPLIT_PART("Date", ' ',2) , '-',
               CASE WHEN EXTRACT(MONTH FROM TO_DATE ("Date", 'Dy, mon, DD')) >= 10 
               THEN 2018 ELSE 2019 END), 'DD-mon-YY')  AS True_Date

INTO nba_cleaned
FROM nba
where "Date" NOTNULL;


-- Save output
COPY nba_cleaned
TO 'C:\Users\DIANA\Desktop\Projects\SQL\Data\nba_cleaned.csv'
DELIMITER ',' 
CSV HEADER
;

DROP TABLE nba_cleaned;

