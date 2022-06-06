-- SQL flavor postgresql

--Scenario/Goal
 /*
    Text Parsing:- unnesting String to Arrays

 */
     
-- FUNCTIONS WINDOW FUNCTIONS, JOINS(lateral/inner)

--Step 1:
--Seperate the ingredients and create a single column of them
CREATE TEMP TABLE ig_list AS
    (SELECT 
            cocktail,
            i.ing AS ingredients,
            price,
            i.row_no AS ingredient_position
            
    FROM cocktails,
    LATERAL UNNEST(STRING_TO_ARRAY(ingridients, ','))
         WITH ORDINALITY i(ing, row_no) --Work out the position of the ingredients within 
         --the list of ingredients in each cocktail
    );

--Step 2: Work out the 'average price of the cocktails that ingredient is used in'
SELECT 
        cocktail,
        ingredients,
        price,
        ingredient_position,
        ROUND(AVG(price) OVER(PARTITION BY ingredients)::numeric,2) AS Avg_ingredient_price

FROM ig_list
ORDER BY ingredient_position, ingredients;