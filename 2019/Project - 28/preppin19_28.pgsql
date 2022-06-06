-- SQL flavor postgresql

--Scenario/Goal
 /*
    UN-PIVOTING COLUMNS
 */
     
-- FUNCTIONS WINDOW FUNCTIONS(SUM, LAG)

--Step 1: Unpivot the proximity, task fields
CREATE TEMP TABLE workers_unpivoted AS
(SELECT
       employees,
       TO_TIMESTAMP(CONCAT('16/08/2019 ', obs_start_time), 
                    'dd/mm/YYYY HH24:MI')::timestamp  observation_start_time, 
                    
       obs_interval_no,
       obs_length_min,
       UNNEST(ARRAY[inter_manager, inter_coworker, inter_customer, inter_no_one]) interaction_flag,
       UNNEST(ARRAY['Manager', 'Coworker', 'Customer', 'No one']) Interaction,
       UNNEST(ARRAY [on_task, off_task]) Task_flag,
       UNNEST(ARRAY ['on_task', 'off_task']) Task_Engagement,
       UNNEST(ARRAY [next_to_2m, close_to_5m, further_5m, na]) proximity_flag,
       UNNEST(ARRAY ['Next to (<2m)', 'Close to (<5M)', 'Further (>5M)', 'NA']) Manager_Proximity

FROM workers
WHERE employees IS NOT NULL
);

--Step 2:
-- Create a single fields for who they interacted with, manager's proximity and whether they were on task or not
CREATE TEMP TABLE workers_cleaned AS
    (SELECT 
        *
    FROM
        (SELECT 
                employees,
                observation_start_time,
                obs_interval_no,
                obs_length_min,
                interaction
                
        FROM workers_unpivoted
        WHERE interaction_flag IS NOT NULL) i --interactions

    LEFT JOIN (
        SELECT 
                employees,
                observation_start_time,
                obs_interval_no,
                obs_length_min,
                Task_Engagement

        FROM workers_unpivoted
        WHERE Task_flag IS NOT NULL
    ) t -- task status
    USING(employees,
            observation_start_time,
            obs_interval_no,
            obs_length_min)

    LEFT JOIN (
        SELECT 
                employees,
                observation_start_time,
                obs_interval_no,
                obs_length_min,
                Manager_Proximity

        FROM workers_unpivoted
        WHERE proximity_flag IS NOT NULL
    ) p -- proximity
    USING(employees,
            observation_start_time,
            obs_interval_no,
            obs_length_min)
);

--Step 3: Lag the observation length in mins field .
CREATE TEMP TABLE workers_temp AS
    (SELECT
            employees,
            observation_start_time ,
            LAG(obs_length_min, 1, 0) OVER(PARTITION BY employees
                                    ORDER BY obs_interval_no
                                    RANGE BETWEEN UNBOUNDED PRECEDING AND
                                    CURRENT ROW) duration,
            obs_interval_no,
            obs_length_min,
            interaction,
            Task_Engagement,
            Manager_Proximity 

    FROM workers_cleaned
     
    );


--Step 4: Calculate the actual start time.
SELECT
        employees,
        observation_start_time + INTERVAL '1m' *
        SUM(duration ) OVER(PARTITION BY employees
                            ORDER BY obs_interval_no
                                RANGE BETWEEN UNBOUNDED PRECEDING AND
                                    CURRENT ROW) observation_start_time,
            obs_interval_no,
            obs_length_min,
            interaction,
            Task_Engagement,
            Manager_Proximity 

    FROM workers_temp
