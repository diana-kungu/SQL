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
*/

--Step 1:
    -- Make all time fields seconds 
    --Count number of riders per team
    -- Calculate the time difference between each rider and the first rider per team
WITH tdf_agg AS (
    SELECT 
            rider,
            team, 
            t.time_seconds,
            COUNT(*) OVER (PARTITION BY team) Riders_per_team,
            time_seconds - FIRST_VALUE(time_seconds)  
            OVER (ORDER BY time_seconds) time_diff_per_team   

    FROM soap.sponser,
        LATERAL (SELECT SUBSTRING(time,1,2)::int * 3600 + -- convert time duration into seconds
                        SUBSTRING(time, 5, 2)::int * 60 +
                        SUBSTRING(time, 9, 2)::int time_seconds
                ) t
)

--Step 2
--Filter by the following conditions
    -- Have seven or more riders complete the tour
    -- Must average 100 minutes or less behind the leader as a team
SELECT   
        Team,
        TRUNC(AVG(time_diff_per_team::numeric)/60) AS Team_Avg_Gap_mins,
        Min(Riders_per_team) No_of_Riders
FROM tdf_agg
WHERE riders_per_team >= 7
GROUP BY team
HAVING TRUNC(AVG(time_diff_per_team::numeric)/60) <= 100
;

