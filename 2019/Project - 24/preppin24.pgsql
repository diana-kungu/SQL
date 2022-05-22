-- SQL flavor postgresql

--Scenario/Goal
 /*
    Text Parsing
 */
     
-- FUNCTIONS


--Step 1: Parse field_1
-- Extract the datime time, name of author and message
-- Count the number of messages per name
CREATE TEMP TABLE msg_parsed AS
    (
        SELECT 
            TRIM(m1.Name) AS Name,
            m1.datetime,
            m1.datetime::date msg_date,
            m1.datetime::time msg_time,
            COUNT(*) OVER (PARTITION BY m1.Name) AS Total_msgs,
            TRIM(SPLIT_PART(SPLIT_PART(field_1, ']', 2), ':', 2)) message
        FROM msg M,
        LATERAL
            (SELECT
                TO_TIMESTAMP(SUBSTRING(SPLIT_PART(field_1, ']', 1), 2),
                'dd/mm/yyyy, HH24:MI:SS') AS datetime,
            SPLIT_PART(SPLIT_PART(field_1, ']', 2), ':', 1) AS Name
            ) m1
    );

-- Step 2
-- JOIN msg_parsed table with dates table
-- Flag messages sent during working hours

CREATE TEMP TABLE msg_combined AS 
    (  
        SELECT 
                m.name,
                m.message,
                m.Total_msgs, 
                CASE WHEN ((msg_time >= TO_TIMESTAMP('09:00:00', 'HH24:MI:SS')::time AND
                    msg_time <= TO_TIMESTAMP('12:00:00', 'HH24:MI:SS')::time) OR
                    (msg_time >= TO_TIMESTAMP('13:00:00', 'HH24:MI:SS')::time AND
                    msg_time <= TO_TIMESTAMP('17:00:00', 'HH24:MI:SS')::time)
                    AND d.holiday = 'Weekday' ) THEN 1 ELSE 0 END AS working_hrs

        FROM msg_parsed m
        INNER JOIN
            (
                SELECT 
                        TO_DATE(CONCAT(Date, '-', '2019'), 'dd-mon-yyy')::Date AS msg_date,
                        holiday
                FROM dates
            ) d
            ON m.msg_date =  d.msg_date

    )
;
--Step 3. 
-- split message into sentences
--Count the number of words  per name and sentence
-- Filter messages sent during working hours

CREATE TEMP TABLE msg_agg AS
    (
        SELECT 
            name, 
            Total_msgs,
            working_hrs,
            array_length(
                STRING_TO_ARRAY(message, ' ') , 1) Words
                      
        FROM

            msg_combined
        ORDER BY 
                Name
    );


Select 
        name,
        sum(words) Number_of_words,
        max(Total_msgs) AS Text,
        sum(words)/max(Total_msgs) AS Avg_words_per_message,
        sum(working_hrs) AS Text_while_at_work,
        ROUND(sum(working_hrs)::Numeric *100 /max(Total_msgs), 2) AS "%_while_at_work"
        
from msg_agg
GROUP by 
        name
ORDER BY

        name
;
