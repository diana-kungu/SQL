-- SQL flavor postgresql

--Scenario/Goal
 /*
    Text Parsing:- REGEX, PIVOT

 */
     
--Step 1: pivot products to single COLUMN
        --pivot sales to single COLUMN
        -- Apply Regex to extract: city, property no, country and postal code
SELECT  
        customer,
        address,
        UNNEST(ARRAY[Product_1, product_2]) Product,
        UNNEST(ARRAY[sales_1, Sales_2]) Sales,
        REGEXP_MATCH(address, '([A-Z]{2}\d+\s\d+\w+)') Postal_code,
        REGEXP_MATCH(address, '(?<=[A-Z]{2}\d+\s\d+\w+,\s)\w+') country,
        REGEXP_MATCH(address, '(\d+)') Property,
        SPLIT_PART(address, ',', 2) Town
FROM soap.multiples