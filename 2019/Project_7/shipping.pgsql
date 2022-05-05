-- SQL flavor postgresql

--Scenario
    *\*\
    --.
     
-- GOAL 
    -- Load data into DB 
    -- Create end date for each contract
    -- Aggregate revenue for each month and customer
    -- JOIN LATERAL

-- Author Diana Kungu

DROP TABLE IF EXISTS departure_details, booking_log;

CREATE TABLE departure_details(
    Ship_ID VARCHAR(30),
    Depart_date DATE,
    Max_weight INTEGER,
    Max_vol INTEGER
);
CREATE TABLE booking_log(
    Salesperason VARCHAR(50),
    Depart_ID VARCHAR,
    Date_logged DATE,
    Product_type VARCHAR,
    Allocated_weight INTEGER,
    Allocated_vol INTEGER
);

--COPY Data into table
COPY departure_details FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\Departure_Details.csv'
DELIMITER ','
CSV HEADER;

COPY booking_log FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\Week7Challenge.csv'
DELIMITER ','
CSV HEADER;

    
UPDATE departure_details 
SET ship_id = replace(ship_id, '-', '_');

DROP TABLE IF EXISTS alloc;


-- Aggregate booked product (weight and volume) by
--- ship_id and departure date
WITH bkd_agg AS(
    SELECT b.ship_id::varchar[1], 
           depart_date,
           sum(allocated_weight) AS Total_weight,
           sum(allocated_vol) Total_vol
    FROM
        (SELECT depart_id, 
            -- split ship_id and departure date from depart_id
            REGEXP_MATCH(depart_id, '(\w+-\d{2})') AS Ship_ID,
            REGEXP_MATCH(depart_id, '\w+-\d{2}-(.+)') AS Depart_date,
            allocated_weight,
            allocated_vol
        FROM booking_log ) b
    GROUP BY b.Ship_ID, depart_date
    )

    /*dep AS (
        SELECT DISTINCT ON(ship_id) ship_id,
            depart_date, max_weight, max_vol
        FROM departure_details )*/
 
SELECT b.* 
INTO TABLE alloc
FROM bkd_agg b;

SELECT *
from alloc;

UPDATE alloc 
    SET ship_id = replace(ship_id, 'T', 'W');


SELECT  *
from boo;

from bkd_agg a 
JOIN   departure_details d 
    ON (a.ship_id) = (d.ship_id::VARCHAR[])
;

SELECT regexp_replace(ship_id, '[-]', '__') AS new_id
from departure_details
;