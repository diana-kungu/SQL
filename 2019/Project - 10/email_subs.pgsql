-- SQL flavor postgresql
    
-- FUNCTIONS USED: unnest, To_date, Extract, CASE stmts,
    --- age, sum

-- Author Diana Kungu

SET datestyle = dmy;


DROP TABLE IF EXISTS clv, subs, un_subs;

CREATE TABLE clv(
    Email VARCHAR,
    E_Domain VARCHAR,
    Sales_to_Date INTEGER 
    );

    COPY clv FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\CLV.csv'
    DELIMITER ','
    CSV HEADER;


CREATE TABLE subs(
    Email VARCHAR,
    E_Domain VARCHAR,
    Bar INTEGER,
    Signup_Date Date 
    );

    COPY subs FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\mailing_lst.csv'
    DELIMITER ','
    CSV HEADER;


-- Unsubscription table
CREATE TABLE un_subs(
    lowercase VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    unsubscribe_Date Date 
    );

    COPY un_subs FROM 'C:\Users\DIANA\Desktop\Projects\SQL\Data\Unsubcribe_lst.csv'
    DELIMITER ','
    CSV HEADER;

--- Create the a common key in all datasets, so we can join them later
---The common feature that can be assembled is the first letter 
-- of the firtname and the lastname

CREATE TEMPORARY TABLE mail_list_1 AS
    SELECT 
            *,
           UNNEST(REGEXP_MATCH(email, '(^\D+)\d*.*$')) AS f_lastname
    FROM   subs
    WHERE email NOTNULL
;

CREATE TEMPORARY TABLE unsubs_list_1 AS
	SELECT 
		*,
        REGEXP_REPLACE(CONCAT( LOWER(LEFT(first_name,1)), LOWER(Last_name)),'[[:space:]]|-','') AS f_lastname
    FROM un_subs
    WHERE lowercase NOTNULL
;


CREATE TEMPORARY TABLE clv_1 AS
	SELECT 
		*,
		UNNEST(REGEXP_MATCH(email, '(^\D+)\d*.*$')) AS f_lastname
	FROM clv
;

---Create new mailing list 
--- join mail list, un_subs and customer livetime value table 
--- create status field to identify active and non active subscribers
CREATE TEMP TABLE new_mailing_lst AS  
    SELECT 
            CONCAT(ml.email,'@', ml.E_Domain) AS Email,
            ml.signup_date,
            ul.unsubscribe_date,
            cl.Sales_to_Date AS "Bar Sales to Date",
            (ml.Bar) AS Interested_in_soap,
            EXTRACT(YEAR FROM age(Signup_Date, unsubscribe_date))*12 +
                EXTRACT(MONTH FROM age(Signup_Date, unsubscribe_date))
                    AS Months_before_Unsubscribed,
            CASE 
                WHEN ml.Signup_Date > ul.unsubscribe_date THEN 'Resubscribed' 
                WHEN ul.unsubscribe_date IS NULL THEN 'Subscribed'
                ELSE 'Unsubscribed' END 	AS Status
        
    from mail_list_1 ml
    LEFT JOIN unsubs_list_1 ul
        ON ml.f_lastname = ul.f_lastname
    LEFT JOIN clv_1 cl
            ON ml.f_lastname = cl.f_lastname
;
-- Result 1: Active mail_list
SELECT *
FROM new_mailing_lst
WHERE 
        Status IN ('Subscribed', 'Resubscribed')

ORDER BY email;


-- Result 2: Mailing list Analytics table
SELECT 
	CASE 
		WHEN Months_before_Unsubscribed IS NULL THEN ''
        WHEN Months_before_Unsubscribed <0 THEN ''
		WHEN Months_before_Unsubscribed <3 THEN '0-3'
		WHEN Months_before_Unsubscribed <6 THEN '3-6'
		WHEN Months_before_Unsubscribed <12 THEN '6-12'
        WHEN Months_before_Unsubscribed <24 THEN '12-24'
		ELSE '24+'
	END AS Months_before_Unsubscribed_group,
    Status, 
	Interested_in_soap, 
	COUNT(DISTINCT email) AS email,
	SUM("Bar Sales to Date") AS Bar_Sales_to_Date
FROM new_mailing_lst
GROUP BY
	Status, 
	Interested_in_soap,
	CASE 
		WHEN Months_before_Unsubscribed IS NULL THEN ''
        WHEN Months_before_Unsubscribed <0 THEN ''
		WHEN Months_before_Unsubscribed <3 THEN '0-3'
		WHEN Months_before_Unsubscribed <6 THEN '3-6'
		WHEN Months_before_Unsubscribed <12 THEN '6-12'
        WHEN Months_before_Unsubscribed <24 THEN '12-24'
		ELSE '24+'
	END

;
