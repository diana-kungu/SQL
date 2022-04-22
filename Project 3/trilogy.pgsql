-- SQL flavor postgresql

-- Fuzzy joins
--

-- Create tables
DROP TABLE IF EXISTS films;

CREATE TABLE IF NOT EXISTS films(
     no_in_listing Integer,
     trilogy_grouping VARCHAR,
     title VARCHAR,
     rating float

);

DROP TABLE IF EXISTS trilogy;

CREATE TABLE IF NOT EXISTS trilogy(
     title VARCHAR,
     ranking INTEGER
);

