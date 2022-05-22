-- SQL flavor postgresql

--Scenario/Goal
 /* Create a function that returns n-days moving average

 -- Functions Used:
    User defined function
    WINDOW FUNCTIONS:- avg, row_number
 
-- Author: Diana Kung'u 
*/

--Step 1: create 7 day moving average

CREATE OR REPLACE FUNCTION n_days_Moving_Average (days INT) 
RETURNS TABLE
    (
        date Date, 
        sales Numeric,
        Moving_avg_Sales Numeric
       
    )
LANGUAGE 'plpgsql' 
AS 
$BODY$
BEGIN
    RETURN QUERY

       WITH sales_MA AS(
            SELECT 
                    s.date,
                    s.sales,
                    AVG(s.sales) OVER w AS Moving_avg_Sales,
                    ROW_NUMBER() OVER (ORDER BY s.Date) AS Ranked_days
            FROM   
                    soap.daily_sales s

            WINDOW w AS 
                    (
                        ORDER BY s.date ROWS BETWEEN 
                        days - 1 PRECEDING AND CURRENT ROW
                    ) 
            ORDER BY 
                    s.date
       )
        --Step 2: Remove moving average if it isn't the average of seven days sales

        select ma.date, 
               ma.sales::Numeric,
               CASE WHEN Ranked_days < days THEN NULL ELSE
                            ROUND(ma.Moving_avg_Sales::Numeric, 2) END AS Moving_avg_Sales
                        
        from sales_MA ma;
end;
$BODY$;

select * from n_days_Moving_Average (10) 
