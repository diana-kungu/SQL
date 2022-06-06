-- SQL flavor postgresql

--Scenario/Goal
 /*
    Text Parsing:- Regex


     
-- FUNCTIONS WINDOW FUNCTIONS, JOINS(lateral/inner)
-- Date functions, AGGREGATE
*/

--Step 1: Parse field_1
CREATE TEMP TABLE gigs AS
    (SELECT 
            *,
            ROW_NUMBER() OVER(PARTITION BY Artist, Concert_Date, 
             Location ORDER BY Artist, Concert_Date, Concert, Location ) AS rank_for_dup

    FROM Concerts c
    --ORDER BY location
    FULL OUTER JOIN (
        
        SELECT 
                location,
                SPLIT_PART(longlat, ',', 1)::Numeric latitude,
                SPLIT_PART(longlat, ',', 2)::Numeric longitude

        FROM Concert_loc
    --    ORDER BY location
        ) l
    USING (location)
    );

SELECT * FROM gigs;

--Break up the Concert field to find Fellow Artists who performed in the same gig
CREATE TEMP TABLE gig_2 AS
    (SELECT 
            concert, concert_Date, venue, location, latitude, longitude,
            Artist, rank_for_dup, 
            CASE WHEN concert like '%/%' AND  (Fellow_Artist ='Ben Howard'
            OR Fellow_Artist = 'Ed Sheeran')
                THEN '' WHEN concert NOT like '%/%' THEN ''
                ELSE Fellow_Artist END Fellow_Artist
            
    FROM gigs,
        LATERAL 
            (SELECT
                UNNEST(STRING_TO_ARRAY(concert, ' / ')) Fellow_Artist
            )a

    WHERE rank_for_dup = 1
    );
-- Remove obvious duplicate records
SELECT * FROM gig_2
order by concert, concert_date;