-- SQL flavor postgresql

-- FUNCTIONS USED: Regexp_replace, 
    -- 

-- Author Diana Kungu

DROP TABLE IF EXISTS complaints, wrds;

CREATE TABLE complaints(
    Tweet VARCHAR 
);

CREATE TABLE wrds(
     Rank SMALLINT,
     word VARCHAR
     
);

COPY complaints FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\Complaints.csv'
DELIMITER ','
CSV HEADER encoding 'Windows-1252';

COPY wrds FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\Common_Eng_Words.csv'
DELIMITER ','
CSV HEADER;


--- Remove @C&BSudsCo - twitter handle
--- Remove punctuation marks

with twt_p as(
SELECT twt_cln, word

FROM
    (select tweet,
            TRIM(regexp_replace(
                regexp_replace(tweet, '(\s?@C&BSudsCo)', ''),
                '[?!.,]', '', 'g')) AS twt_cln
    FROM complaints c1
    WHERE tweet NOTNULL) c_cln

-- split array and explode
CROSS JOIN LATERAL unnest(string_to_array(twt_cln, ' ')) as word 
)


--- filter rows values not in common english words table
SELECT twt_cln AS tweet,
        word
FROM   twt_p t 
WHERE  NOT EXISTS (
    SELECT  
    FROM   wrds w
    WHERE  LOWER(w.word) = LOWER(t.word)
)

