-- SQL flavor postgresql

--INPUTS
    -- Table 1: Top 100 female poker players
    -- Table 2: Poker events

-- GOAL 
-- Create an aggregated view to find the following player stats:

    --Number of events they've taken part in
    --Total prize money
    -- Their biggest win
    -- The percentage of events they've won
    -- The distinct count of the country played in
    -- Their length of career'

-- Author Diana Kungu

-- STEP 1
-- Join events table and top 100 players table

DROP TABLE IF EXISTS t_poker;

CREATE TEMPORARY TABLE 	t_poker  AS

SELECT position_, country, name_, all_time_money_usd,
       p.player_id, TO_DATE(event_date, 'DD-Mon-YY') AS event_date, event_country, player_place,
       prize_usd,
       CASE 
        WHEN player_place = '1ST' THEN 1
        ELSE 0 END won_flag
       
FROM top_100 AS p
RIGHT JOIN events AS e
    ON p.player_id = e.player_id
;


-- STEP 2
-- Find the dates of the players first and last events

DROP TABLE IF EXISTS t_combined;

SELECT *,
FIRST_VALUE (event_date) OVER w AS latest_event,
LAST_Value(event_date) OVER w AS first_event
INTO TEMP t_combined
FROM t_poker
WINDOW w AS(PARTITION BY name_ 
            ORDER BY event_date DESC
                RANGE BETWEEN UNBOUNDED PRECEDING 
                         AND UNBOUNDED FOLLOWING);

-- STEP 3
-- From the dates calculate the players' career duration
DROP TABLE IF EXISTS tbl;

SELECT *,
	ROUND((latest_event - first_event)/365.0,2) AS career_duration
INTO tbl
FROM t_combined;

-- STEP 4
--Create an aggregated view
-- Group by name
DROP TABLE IF EXISTS t_agg;

SELECT name_,
	COUNT(event_date) AS no_of_events_participated,
	SUM(prize_usd) AS total_prize_money,
	MAX(prize_usd) AS biggest_win,
	COUNT (DISTINCT event_country) AS countries_visited,
	ROUND(AVG(won_flag)*100,1) AS percent_wins,
	ROUND(AVG(career_duration),2) AS career_length
INTO TEMP t_agg
FROM tbl
GROUP BY name_;

-- Unnest aggregate metrics raw_values

DROP TABLE IF EXISTS t_raw_melted;

SELECT name_,
   unnest(array['no_of_events_participated', 'total_prize_money', 'biggest_win', 
				'countries_visited', 'percent_wins', 'career_length']) AS "metrics",
   unnest(array[no_of_events_participated, total_prize_money, biggest_win,
				countries_visited, percent_wins, career_length]) AS "raw_value"
INTO TEMP t_raw_melted
FROM t_agg
;

-- For each metric create a scaled value using rank function
-- Ranks
DROP TABLE IF EXISTS t_rnks;

SELECT name_,
	RANK() OVER(
		ORDER BY biggest_win DESC) AS biggest_win,
	RANK() OVER(
		ORDER BY total_prize_money DESC) AS total_prize_money,
	RANK() OVER(
		ORDER BY percent_wins DESC) AS percent_wins,
	RANK() OVER(
		ORDER BY career_length DESC) AS career_length,
	RANK() OVER(
		ORDER BY no_of_events_participated DESC) AS no_of_events_participated,
	RANK() OVER(
		ORDER BY countries_visited DESC) AS countries_visited
INTO TEMP t_rnks
FROM t_agg
;

----------------------------------------------------------------
-- Unnest t_ranks
DROP TABLE IF EXISTS t_rnks_melted;
SELECT name_,
   unnest(array['no_of_events_participated', 'total_prize_money', 'biggest_win', 
				'countries_visited', 'percent_wins', 'career_length']) AS "metrics",
   unnest(array[no_of_events_participated, total_prize_money, biggest_win,
				countries_visited, percent_wins, career_length]) AS "scaled_value"
INTO TEMP t_rnks_melted
FROM t_rnks
;
select *
from t_rnks_melted;

--------------------------------------------------------------------------------------
-- Join Ranks and raw_aggregate tables
--------------------------------------------------------------------------------------
COPY (SELECT *
	from t_raw_melted AS a
	INNER JOIN 
		(
			SELECT * 
			FROM t_rnks_melted
		) AS r
	USING(name_, metrics)
	)
TO '~path\Output\top_100_female_poker_players.csv'
DELIMITER ',' 
CSV HEADER
;

