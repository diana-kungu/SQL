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
    -- Build a complete dataset for each date a patient is in hospital(Scaffold by length_of_stay)
    -- Create new date field
CREATE TEMP TABLE patients_scaffold AS(
    SELECT 
            p.Name,
            p.Length_of_Stay AS Total_Length_of_Stay,
            s1.Value + 1 AS Day_number,
            first_visit + interval '1 day' * s1.Value AS Day_at_hospital
    FROM 
            soap.patients p
    
    CROSS JOIN 
            soap.scaffold s1
        
    WHERE 
            s1.Value < p.Length_of_Stay
        
    ORDER BY 
            p.Name,
            s1.Value + 1
);
-- Step 2:
-- Add cost per day data to patients_scaffold
CREATE TEMP TABLE patients_cost AS(
    SELECT
            p.Name,
            p.Day_number,
            p.Total_Length_of_Stay,
            p.Day_at_hospital,
            c.cost_per_day
            
    FROM patients_scaffold p

    INNER JOIN 
        (
            SELECT LEFT(length_of_stay, 1)::INT Lower_bound,
                    SPLIT_PART(length_of_stay, '-', 2)::INT upper_bound,
                    cost_per_day
            FROM soap.COST
         ) c

    ON P.Day_number BETWEEN c.Lower_bound AND c.upper_bound
);

--Reports
--summary 1

--Daily Hospital Costs
SELECT
        SUM(cost_per_day) AS COST_per_day,
        Day_at_hospital,
        ROUND(AVG(cost_per_day), 2) Avg_cost_per_day,
        COUNT(*) AS Number_of_patients
FROM   patients_cost
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
FROM   patients_cost
GROUP BY
        name
;