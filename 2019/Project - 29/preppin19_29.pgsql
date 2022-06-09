-- SQL flavor postgresql

--Scenario/Goal
 /*
    Text Parsing:- Date functions

 */
     
-- FUNCTIONS WINDOW FUNCTIONS

--Step 1: Unpivot the proximity, task fields
CREATE TEMP TABLE pckg_joined AS
   (SELECT 
         *
   FROM
      (SELECT
            name,
            frequency::INTEGER AS Frequency_code,
            UNNEST(STRING_TO_ARRAY(packages, '|'))::INTEGER packages
      FROM soap.pckg_customers 
      WHERE name IS NOT NULL) a1
   LEFT JOIN 
         (SELECT * 
         FROM soap.pckg_prod
         WHERE sub_pckg IS NOT NULL) p
   ON a1.packages = p.sub_pckg

   LEFT JOIN
      soap.pckg_freq f
   ON a1.frequency_code = f.sub_frequency
   
);

--Step 2a: using frequency find number of orders per year
CREATE TEMP TABLE pckg_yrly AS
   (SELECT 
         name,
         frequency,
         packages,
         product,
         price,
         CASE WHEN Frequency_code = 1 THEN 52
            WHEN Frequency_code = 2 THEN 12
            WHEN Frequency_code = 3 THEN 4
            ELSE 1 END AS Order_per_yr
   from pckg_joined
);
--step 2b:calculate average price excluding mystery package
CREATE TEMP TABLE pckg_yrly_1 AS
   (SELECT 
         name,
         frequency,
         packages,
         product,
         price,
         price * Order_per_yr AS Annual_subscription_cost,
         Order_per_yr,
         CASE WHEN Product = 'Mystery' THEN 0 ELSE Order_per_yr END AS packages_per_year_no_mistery
   from pckg_yrly
);

-- Step 3: Aggregate to obtain Annual_subscription_cost and Avg price per order
CREATE TEMP TABLE pckg_yrly_without_mystery AS
   (SELECT 
      name,
      frequency,
      product,
      packages,
      price,
      Order_per_yr,
      Annual_subscription_cost,
      FLOOR(sum(annual_subscription_cost) over()/ sum(packages_per_year_no_mistery) over())  AS Mystery_cost
   FROM pckg_yrly_1
   );

--STEP 4 Aggregate to generate the resulting tables

--Step 4a - Subscription Pricing Table:
SELECT
   packages Subscription_Package,
   Product,
   AVG(case when product = 'Mystery' THEN Mystery_cost       
      ELSE price END) AS price
FROM pckg_yrly_without_mystery

GROUP BY packages,
         Product
;

--Step 4a - Subscription Cost per annum
SELECT
      name,
      SUM(case when product = 'Mystery' THEN Mystery_cost       
      ELSE price END * Order_per_yr) Subscription_cost_per_annum
FROM pckg_yrly_without_mystery
GROUP BY name


