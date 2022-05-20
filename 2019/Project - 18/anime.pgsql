-- SQL flavor postgresql

--Scenario/Goal
 /* From data scrapped from MyAnimeList.net figure out the most popular genres.

 -- Functions Used:
    Cross Join LATERAL, WINDOW FUNCTIONS, AGGREGATE
 
-- Author: Diana Kung'u

 CREATE TABLE soap.anime (
     anime_id integer,
     name VARCHAR, 
     genre	VARCHAR,
     type	VARCHAR,
     episodes VARCHAR,
     rating float,
     members integer

 ); */
-- STEP 1
-- Include only TV Shows and movies
-- Ignore any anime without a rating or without any genres.
-- Ignore any anime with less than 10000 viewers (i.e. [Members])

WITH anime_unpivoted AS(
    SELECT * ,
            MAX(rating) OVER (PARTITION BY TRIM(new_genre), type)  AS MAX_rating
    FROM soap.anime a
    CROSS JOIN LATERAL 
            regexp_split_to_table(a.genre, ',') new_genre --Split genre string and unnest
    WHERE type IN ('TV', 'Movie') AND rating IS NOT NULL
        AND genre IS NOT NULL AND members >= 10000 
    
)

--Step :
/*For each genre and type combination (e.g. Action & TV, Romance & Movie) return the following information:

    - The average rating (to 2 decimal places).
    - The average viewership (to 0 decimal places).
    - The maximum rating.
    - A prime example of the genre and type combination (i.e. the anime with the max rating for the combo).
*/
SELECT 
        TRIM(new_genre) AS genre,
        type,
        ROUND(AVG(rating)::numeric, 2)AS Avg_Rating,
        ROUND(MAX(rating)::numeric, 2) AS Max_Rating,
        ROUND(AVG(members)::numeric, 0) AS Avg_Viewership,
        MAX(CASE WHEN rating = MAX_rating THEN name ELSE NULL END) AS Prime_Example
FROM anime_unpivoted
GROUP BY 
        type,
        TRIM(new_genre)
ORDER BY 
        TRIM(new_genre)
;