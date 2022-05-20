-- SQL flavor postgresql

--Scenario/Goal

 /* Evaluate the outcomes(winner) of an election based on 3 voting systems.
 1. First Past the Post (the one we currently use in the UK)

    Everyone picks their favourite candidate.
    The most commonly picked candidate wins.

2. AV (Alternative Vote)

    Everyone ranks the candidates in order of preference.
    If the candidate mostly commonly ranked first is ranked first in more than 50% of the votes, they win.
    If this is not the case, then the candidate least commonly ranked first is deleted from all the votes and there is a recount.
    This process of counting and deleting continues until a candidate holds over 50% of the popular vote.

3. Borda Count

    Everyone ranks the candidates in order of preference.
    The better the rank, the more points the candidate receives.
        E.g. if there are 3 candidates, the candidate ranked first gets 3 points and the
         candidate ranked last gets 1 point.
    The candidate with the most points wins.

*/
-- Step 1: split voting preferance and voter into distinct columns
CREATE TEMP TABLE Votes_1 AS(
    SELECT  
            LEFT(Votes, 3) AS Voting_Preferance,
            SUBSTRING(Votes, 5) AS Voter,
            SUBSTRING(Votes, 1, 1) AS _1st_Choice,
            SUBSTRING(Votes, 2,1) AS _2nd_Choice,
            SUBSTRING(Votes, 3,1) AS _3rd_Choice

    FROM elections
);



-- Vote System 1
-- First Past the Post
CREATE TEMP TABLE FPTP AS(
    SELECT  'FPTP' AS Voting_System,
           MODE() WITHIN GROUP (ORDER BY _1st_choice) AS Winner
    FROM votes_1
);

-- Vote System 2
-- Borda Count
CREATE TEMP TABLE BC_system AS(
    SELECT  
            'Borda' AS Voting_System,
            Candidate,
            SUM(CASE WHEN V1.vote_order = 'Winner' THEN 3 
                WHEN V1.vote_order = 'Second' THEN 2 
                ELSE 1 END) AS Candidate_points
    FROM
        (SELECT
                Voting_Preferance,
                VOTER,
                'Winner' AS Vote_order,
                _1st_Choice AS Candidate
        
            FROM votes_1

        UNION 
            SELECT
                Voting_Preferance,
                VOTER,
                'Second' AS Vote_order,
                _2nd_Choice AS Candidate
            
            FROM votes_1

        UNION
            SELECT
                Voting_Preferance,
                VOTER,
                '3rd' AS Vote_order,
                _3rd_Choice AS Candidate
        
            FROM votes_1) v1

    GROUP BY candidate
);

SELECT  
        voting_system,
        candidate
INTO TEMP BC
FROM BC_system
WHERE candidate_points = 
        (SELECT 
                MAX(candidate_points)
         FROM BC_system
        ) 
;

-- Vote System 3
-- AV (Alternative Vote)
CREATE TEMP TABLE AV1 AS(
    SELECT * ,
            COUNT(*) OVER (PARTITION BY _1st_choice) AS no_votes,
            CASE WHEN (COUNT(*) OVER (PARTITION BY _1st_choice)*100/
            COUNT(*) OVER() )>= 50 THEN TRUE ELSE FALSE END AS is_there_a_winner
    FROM VOTES_1
);

CREATE TEMP TABLE AV2 AS(
SELECT      'AV' AS voting_system,
            _1st_choice,
            COUNT(*) OVER (PARTITION BY _1st_choice) AS no_votes,
            (COUNT(*) OVER (PARTITION BY _1st_choice)*100/
            COUNT(*) OVER() ),
            CASE WHEN (COUNT(*) OVER (PARTITION BY _1st_choice)*100/
            COUNT(*) OVER() )>= 50 THEN TRUE ELSE FALSE END AS is_there_a_winner
    FROM 
        (SELECT * 
        FROM AV1
        WHERE no_votes <> 
            (
                SELECT MIN(no_votes)
                FROM AV1
            )) V2
);
SELECT  MAX(voting_system) AS voting_system,
       MAX( _1st_choice ) AS CANDIDATE
FROM AV2
UNION SELECT * FROM BC 
UNION SELECT * FROM  FPTP 
