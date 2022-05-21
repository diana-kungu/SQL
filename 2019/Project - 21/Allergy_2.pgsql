-- SQL flavor postgresql

--Scenario/Goal
 /* Chin & Beard Suds Co. have had a local hospital get in contact about a number of patients 
 who have had an allergic reaction to some of its products. As a company, we want to cover 
 customers' medical expenses as we haven't labelled our products  clearly enough (or people aren't reading the ingredients).

Create the following views:
    1. Daily Hospital Costs
    2. Cost per Patient

 -- Functions Used:
    Scaffolding, Date FUNCTIONS(Add), AGGREGATE + GROUP BY,
    -- CROSS JOIN LATERAL 
 
-- Author: Diana Kung'u 
*/

--Step 1:
    -- Union all patients records
    -- create a discharge date
CREATE TEMP TABLE all_patients AS(
    SELECT 
            p.Name,
            p.first_visit,
            p.Length_of_Stay AS Total_Length_of_Stay,
            first_visit + interval '1 day' * p.Length_of_Stay AS Discharge_day
    FROM 
            soap.patients p
    
    UNION ALL

    SELECT 
            p2.Name,
            p2.first_visit,
            p2.Length_of_Stay AS Total_Length_of_Stay,
            first_visit + interval '1 day' * p2.Length_of_Stay AS Discharge_day
    FROM 
            soap.patients_2 p2
);   
-- Step 2
-- Add Frequency of Check-Ups data
-- Create check_up data for each patient  (x-months after discharge)

CREATE TEMP TABLE checkup_data AS(
    SELECT  c.name,
            c.type_of_visit,
            c.Length_of_Stay,
            s1.Value + 1 AS Day_number,
            Day_at_hospital + interval '1 day' * s1.Value AS Day_at_hospital
    FROM (
            SELECT  ap.name,
                    CONCAT(cu.check_up,' check-up') As type_of_visit,
                    cu.Length_of_Stay AS Length_of_Stay,
                    ap.discharge_day + interval '1 month' * 
                        cU.Months_After_Leaving AS Day_at_hospital
                    
            FROM all_patients ap
            CROSS JOIN
                    soap.checkups cu
        ) c
    CROSS JOIN 
    --The scaffold need to be appended with one more row, to accomodate the 14th day of patient Andy
        (
            SELECT *

            FROM
                    soap.scaffold
            UNION
                   SELECT 14 AS Value
        ) s1
        
    WHERE 
            s1.Value < c.Length_of_Stay
    ORDER BY 
            c.name, c.type_of_visit
);

--- Step 2
--- First visit data
CREATE TEMP TABLE first_visit_data AS(
    SELECT 
                p.Name,
                'First visit'AS type_of_visit,
                Total_Length_of_Stay AS Length_of_Stay,
                s1.Value + 1 AS Day_number,
                first_visit + interval '1 day' * s1.Value AS Day_at_hospital
        FROM 
                all_patients p
        
        CROSS JOIN 
                soap.scaffold s1
            
        WHERE 
                s1.Value < p.Total_Length_of_Stay
            
        ORDER BY 
                p.Name,
                s1.Value + 1
);

-- Step 3 
-- union check-up and first_visit date

CREATE TEMP TABLE patients_all_visits_cost AS(
    SELECT
            pt.Name,
            pt.Day_number,
            pt.Length_of_Stay,
            pt.Day_at_hospital,
            c.cost_per_day
            
    FROM 
        (SELECT * 

        FROM first_visit_data

        UNION ALL
        SELECT * 
                
        FROM checkup_data) pt


    INNER JOIN 
        (
            SELECT LEFT(length_of_stay, 1)::INT Lower_bound,
                    SPLIT_PART(length_of_stay, '-', 2)::INT upper_bound,
                    cost_per_day
            FROM soap.COST
         ) c

    ON pt.Day_number BETWEEN c.Lower_bound AND c.upper_bound
);

--Reports
--summary 1

--Daily Hospital Costs Analysis
SELECT
        SUM(cost_per_day) AS COST_per_day,
        Day_at_hospital,
        ROUND(AVG(cost_per_day), 2) Avg_cost_per_day,
        COUNT(*) AS Number_of_patients
FROM   patients_all_visits_cost
GROUP BY
        Day_at_hospital

ORDER BY
        Day_at_hospital
;

--summary 2
--Cost per Patient
SELECT
        SUM(cost_per_day) AS COST,
        name,
        ROUND(AVG(cost_per_day), 2) Avg_per_day_per_person
FROM   patients_all_visits_cost
GROUP BY
        name
;

