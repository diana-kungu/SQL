-- SQL flavor postgresql

--Scenario/Goal
 /*
    Text Parsing
 */
     
-- FUNCTIONS 
    -- REGEXP_REPLACE- positive lookahead,
    -- Union, Text Parsing, Arrays, LATERAL JOIN, INITCAP

--Step 1: Union all sales record
CREATE TEMP TABLE all_sales AS(
    SELECT
            Notes,
            Day,      
            TO_DATE('15/07/2019', 'dd/mm/yyyy') AS Date
    FROM soap.jul_15

    UNION
    SELECT
            Notes,
            Day,      
            TO_DATE('22/07/2019', 'dd/mm/yyyy') AS Date
    FROM soap.jul_22

    UNION
    SELECT
            Notes,
            Day,      
            TO_DATE('29/07/2019', 'dd/mm/yyyy') AS Date
    FROM soap.jul_29
);

--Step 2: Create correct date
-- Parse name, scent, value and product type fields
-- Format fields accordingly

SELECT
        s.date + interval '1 day' * d.day_no AS Date, 
        INITCAP(CONCAT(d.n[1], ' ', d.n[2] )) AS Name, 
        SUBSTRING(d.n[4],2)::numeric AS Value,
        INITCAP(d.n[6]) Scent,
        INITCAP(CONCAT(d.n[7], ' ', d.n[8] )) Product,
        LOWER(REGEXP_REPLACE(Notes, '.(?=\d+)', '£' )) notes

FROM all_sales s,
LATERAL
        (
            SELECT CASE WHEN day = 'Monday' THEN 0
                        WHEN day = 'Tuesday' THEN 1
                        WHEN day = 'Wednesday' THEN 2
                        WHEN day = 'Thursday' THEN 3
                        WHEN day = 'Friday' THEN 4 END AS day_no,
                    string_to_array(Notes, ' ') n
        ) d
ORDER BY
        s.date + interval '1 day' * d.day_no,
        SUBSTRING(d.n[4],2)::numeric DESC
