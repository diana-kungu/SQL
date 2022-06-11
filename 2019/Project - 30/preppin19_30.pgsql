-- SQL flavor postgresql

--Scenario/Goal
 /*
    Text Parsing:- REGEX

 */
     
-- FUNCTIONS WINDOW FUNCTIONS

--Step 1: Filter tweets that give water / air temperatues
CREATE TEMP TABLE tweetsplit AS
    (
        SELECT 
            tweet_id, 
            regexp_match(comment, '(?<= Air.+C\.\s).+') AS comment,
            created_at::timestamp,
            regexp_matches(comment, '^\d+\s\w+\s\d{4}:\s(\w+).+;\s(\w+)\s-\s\d') AS Category,
            regexp_matches(comment, '^\d+\s\w+\s\d{4}:\s\w+\s-\s(\d+.\d*)F\s/\s(\d+.\d*)C') AS water_temp,
            regexp_matches(comment, '^\d+\s\w+\s\d{4}:\s\w+\s-\s\d+.\d*F\s/\s\d+.\d*C;\s\w+\s-\s(\d+.\d*)F\s/\s(\d+.\d*)C') AS AIR_temp

        FROM tweet
        WHERE comment ~ '^\d+\s\w+\s\d{4}'
        )
;

--Step 2:Extract Water and Air Temperatures as separate columns
WITH twt_rcds AS
    (SELECT 
            tweet_id,
            REGEXP_REPLACE(comment::Text, '[[:punct:]]', '', 'g') AS no_punct_comment,
            comment[1],
            created_at,
            TRIM(UNNEST(STRING_TO_ARRAY(Category::Text, ',')), '{|}') AS Category,
            UNNEST(ARRAY [water_temp[1], air_temp[1]]) temp_F,
            UNNEST(ARRAY [water_temp[2], air_temp[2]]) temp_C       
        
    FROM tweetsplit)



-- step 3: Remove Common English words and punctuactions
SELECT
        UNNEST(STRING_TO_ARRAY(
            regexp_replace(no_punct_comment, '\s+', ' ', 'g'),
             ' ')) AS comment_split,
        category, 
        temp_F,
        temp_C,
        comment,
        tweet_id,
        created_at 
       -- w.word
INTO TEMP twt
FROM twt_rcds 
WHERE temp_F IS NOT NULL OR temp_C IS NOT NULL
 
/*
LEFT JOIN wrds w
    ON twt_rcds.comment_split = w.word
 WHERE w.word IS NULL
;*/
;

COPY
    (select 
            category, 
            temp_F,
            temp_C,
            comment,
            tweet_id,
            created_at,
            lower(TRIM(comment_split))
    from twt t
    WHERE  (NOT EXISTS
            (SELECT NULL 
                FROM wrds w
                WHERE lower(TRIM(comment_split)) = lower(
                    REGEXP_REPLACE(w.word::Text, '[[:punct:]]', '', 'g')
                    )
            ))
            
    ORDER BY created_at, tweet_id, category)
TO 'C:\Users\DIANA\Desktop\Projects\SQL\2019\output2.csv'
DELIMITER ',' 
CSV HEADER
;
