-- SQL flavor postgresql

--Scenario
    *\*\
    --.
     
-- FUNCTION Used 
    -- Load data into DB 
    -- With Clause
    -- Aggregate 
   

-- Author Diana Kungu
set client_encoding to 'utf8';

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



DROP TABLE IF EXISTS alloc;


-- Aggregate booked product (weight and volume) by
--- ship_id and departure date


WITH booked_agg AS(
    SELECT  depart_id, 
            sum(allocated_weight) AS Total_weight,
            sum(allocated_vol) Total_vol 
    FROM booking_log 
    GROUP BY depart_id
    ),

    dep_ids AS(
    SELECT *,
        CONCAT(ship_id, '-', 
        LPAD((EXTRACT(DAY FROM depart_date))::TEXT, 2, '0'), '-',
        LPAD((EXTRACT(MONTH FROM depart_date))::TEXT, 2, '0'), '-',
        EXTRACT(YEAR FROM depart_date)) AS depart_id    
    FROM departure_details 
    )

SELECT  d.depart_date,
        d.ship_id,
        d.max_weight,
        d.max_vol,
        bk.total_weight,
        bk.total_vol,
        CASE WHEN bk.total_weight > d.Max_Weight THEN 'TRUE' ELSE 'FALSE' END AS Max_Weight_Exceeded,
        CASE WHEN bk.total_vol > d.Max_Vol THEN 'TRUE' ELSE 'FALSE' END AS Max_Volume_Exceeded
FROM booked_agg bk
JOIN dep_ids d
	ON bk.depart_id = d.depart_id  
ORDER BY
d.depart_id;


