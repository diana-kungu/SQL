-- SQL flavor postgresql

-- GOAL 
    -- Union  two TABLES
    -- Parse information reason for contact
    -- Filter out contact rows without policy number

-- FUNCTIONS USED: Regexp_match, Case Statements, Date functions

-- Author Diana Kungu

DROP TABLE IF EXISTS w52019_I, w52019_II;

CREATE TABLE w52019_I(
    "Date" VARCHAR,
    "Customer_Id" INTEGER,
    "Notes" VARCHAR
);

CREATE TABLE w52019_II(
    "Date" VARCHAR,
    "Customer_Id" INTEGER,
    "Notes" VARCHAR
);

COPY w52019_I FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\week5input_I.csv'
DELIMITER ','
CSV HEADER;

COPY w52019_II FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\week5input_II.csv'
DELIMITER ','
CSV HEADER;

SELECT
        -- Real Date
        TO_DATE('17/06/2019', 'DD/MM/YYYY') + INTERVAL '1 day' * CASE WHEN "Date" = 'Monday' THEN 0
                                                                    WHEN "Date" = 'Tuesday' THEN 1
                                                                    WHEN "Date" = 'Wednesday' THEN 2
                                                                    WHEN "Date" = 'Thursday' THEN 3
                                                                    WHEN "Date" = 'Friday' THEN 4
        END AS "Real Date", 
        -- Contact Method
        CASE WHEN "Notes" LIKE '%Call%' THEN 'Call' 
             WHEN "Notes" LIKE 'Email%' THEN 'Email' END AS Contact_method,
        -- Statement, Balance or Complaint 
		CASE WHEN "Notes" LIKE '%statement%' THEN 1 ELSE 0 END AS Statement,
        CASE WHEN "Notes" LIKE '%balance%' THEN 1 ELSE 0 END AS Balance,
        CASE WHEN "Notes" LIKE '%complaint%' THEN 1 ELSE 0 END AS Complaint,
        "Customer_Id",
        --Policy number
        REGEXP_MATCH("Notes", '(#\d+)') AS "Policy",

        "Notes"
FROM w52019_I
WHERE "Date" NOTNULL AND REGEXP_MATCH("Notes", '(#\d+)') NOTNULL

UNION
SELECT
        -- Real Date
        TO_DATE('24/06/2019', 'DD/MM/YYYY') + INTERVAL '1 day' * CASE WHEN "Date" = 'Monday' THEN 0
                                                                    WHEN "Date" = 'Tuesday' THEN 1
                                                                    WHEN "Date" = 'Wednesday' THEN 2
                                                                    WHEN "Date" = 'Thursday' THEN 3
                                                                    WHEN "Date" = 'Friday' THEN 4
        END AS "Real Date", 
        -- Contact Method
        CASE WHEN "Notes" LIKE '%Call%' THEN 'Call' 
             WHEN "Notes" LIKE 'Email%' THEN 'Email' END AS Contact_method,
        -- Statement, Balance or Complaint 
		CASE WHEN "Notes" LIKE '%statement%' THEN 1 ELSE 0 END AS Statement,
        CASE WHEN "Notes" LIKE '%balance%' THEN 1 ELSE 0 END AS Balance,
        CASE WHEN "Notes" LIKE '%complaint%' THEN 1 ELSE 0 END AS Complaint,
        "Customer_Id",
        --Policy number
        REGEXP_MATCH("Notes", '(#\d+)') AS "Policy",

        "Notes"
FROM w52019_II
WHERE "Date" NOTNULL AND REGEXP_MATCH("Notes", '(#\d+)') NOTNULL;

