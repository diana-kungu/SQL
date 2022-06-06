-- SQL flavor postgresql

--Scenario/Goal
 /*
    Text Parsing:- Date functions

 */
     
-- FUNCTIONS WINDOW FUNCTIONS

--Step 1:
--Create a pre/post valentine field
WITH vals1 AS
    (SELECT
            store,
            date,
            value,
            CASE WHEN date > to_date('14/02/2019', 'dd/mm/YYYY') 
            THEN 'post' ELSE 'pre' END AS Pre_Post_valentines
    FROM val_sales
    )

-- Step 2:Work out the running total of sales for each store, restarting after Valentine's day
SELECT 
        store,
        date,
        Pre_Post_valentines,
        value,
        SUM(value) OVER(PARTITION BY store, pre_post_valentines
                         ORDER BY date) Running_Total_Sales
FROM Vals1;