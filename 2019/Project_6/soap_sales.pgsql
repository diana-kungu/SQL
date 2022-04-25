-- SQL flavor postgresql

-- GOAL 
    -- Union  two TABLES
    -- Parse information reason for contact
    -- Filter out contact rows without policy number

-- FUNCTIONS USED: Regexp_match, Case Statements, Date functions

-- Author Diana Kungu

CREATE TABLE eng_agg AS

SELECT *

FROM england_report e
JOIN (SELECT 
    "manu_cost", "sell_price",
    CASE WHEN TRIM(type_of_soap) = 'Bar' THEN 'Bar Soap'
         WHEN type_of_soap = 'Liquid' THEN 'Liquid Soap'
         END AS type_of_soap
FROM soap_pricing p)
p ON e.category = p.type_of_soap;

-- Calculate Profit
(SELECT 'Mar 19' AS Month, Country, Category,
    SUM((sell_price - manu_cost)* unit_sold) AS Profit

FROM eng_agg
GROUP BY
    Category,
    Country)
UNION -- Union with company table

(select * from soaps_report)
ORDER BY month, country
;

