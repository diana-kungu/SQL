-- SQL flavor postgresql

--Scenario
--Car dealership sales data 

-- GOAL 
    -- Create a date from month and year Integers
	-- Aggregate car sales per color, dealer and month.


-- Load data

SELECT 
	    TO_DATE(CONCAT('01', '-', when_sold_month, '-', when_sold_year),'DD-MM-YYYY') AS Date,
		"Dealership",
	    Red_Cars,
	    Silver_Cars,
	    Black_Cars,
	    Blue_Cars,
		Red_Cars + Silver_Cars + Black_Cars + Blue_Cars AS Total_Cars

FROM car_sales
;

