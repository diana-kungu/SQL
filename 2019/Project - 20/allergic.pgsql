-- SQL flavor postgresql

--Scenario/Goal
 /* Chin & Beard Suds Co. is growing from strength to strength and this has led
  us to think big - sponsorship!What we are looking for in the team to sponsor is a team that works really hard 
  (ie are sweaty!) but are all consistently doing well 
  Using the 2018 Tour de France results find the team(s) that 
    -- Have seven or more riders complete the tour
    -- Must average 100 minutes or less behind the leader as a team

 -- Functions Used:
    CTEs, WINDOW FUNCTIONS- FIRST_VALUE, AGGREGATE,
    -- LATERAL JOIN
 
-- Author: Diana Kung'u 
drop TABLE Soap.patients;
CREATE TABLE soap.Cost (
     
     LengtH_OF_stay varchar,
     Cost_per_Day integer
);
--COPY Data into table
COPY soap.Cost FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\PD - Week 20_Cost_per_visit.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE soap.scaffold (
     value integer
);
--COPY Data into table
COPY soap.scaffold FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\PD - Week 20_scaffold.csv'
DELIMITER ','
CSV HEADER; --*/

--Step 1:
    -- Build a complete dataset for each date a patient is in hospital(Scaffold)
    -- Create new date field
CREATE TEMP TABLE patients_scaffold AS(
    SELECT 
            p.Name,
            --p.First_Visit,
            p.Length_of_Stay AS Total_Length_of_Stay,
            'First Visit' AS Visit_type,
            s.Value + 1 AS Day_number,
            first_visit + interval '1 day' * s.Value AS Day_at_hospital
    FROM soap.patients p
    CROSS JOIN LATERAL 
        (SELECT
                Value
        FROM soap.scaffold s1
        WHERE 
            s1.Value < p.Length_of_Stay
        ) s
    ORDER BY p.Name,
            s.Value + 1
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