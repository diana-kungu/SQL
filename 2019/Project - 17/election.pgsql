-- SQL flavor postgresql

--Scenario/Goal
 /* import & combine all the data from the file without deleting the non-sales data that was accidentally sent to you
 rank the customers by total sales across orders placed within the last 6 months.
        NB: For this challenge, calculate "last 6 months" from 24/05/2019, not today's date.
Find a way to filter these down to customers in the top 8%.
     
-- FUNCTIONS 
    -- UNION,WINDOW FUNCTIONS, Aggregate, Inheritance
--
-- Step 1:
-- Create a table
CREATE TABLE elections(
        votes VARCHAR
        
    );

COPY elections FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\Voting Systems.csv'
DELIMITER ','
CSV HEADER;
*/
-- Step 1: split voting preferance and voter into distinct columns
CREATE TEMP TABLE Votes_1 AS(
    SELECT  
            LEFT(Votes, 3) AS Voting_Preferance,
            SUBSTRING(Votes, 5) AS Voter

    FROM elections
);

-- Vote System 1
-- First Past the Post
CREATE TEMP TABLE FPTP AS(
    SELECT  'FPTP' AS Voting_System,
           MODE() WITHIN GROUP (ORDER BY LEFT(Voting_Preferance, 1)) AS Winner
    FROM votes_1
);

-- Vote System 3
-- Borda Count

SELECT * 

FROM votes_1;
