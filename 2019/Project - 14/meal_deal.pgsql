-- SQL flavor postgresql

--Scenario/Goal
 /*The challenge focuses on Whyte's Cafe based in Stevenage in the UK. 
 The cafe has been growing well and brings in a good amount of revenue but 
 like any business, they are trying to drive for more. Many popular lunch 
 shops provide a 'Meal Deal' when you can purchase a drink, a snack to go 
 with a main for a set price. Whyte's Cafe wants to know how much it would cost
 them to install a Meal Deal (for £5 each meal - what a bargain!) option on
  their menu as the ownership team believe it will entice a lot more customers 
  through the door.*/
     
-- FUNCTIONS 
    -- Joins,
    -- Date Parsing, Aggregate 


select  ticketid, TYPE,
        to_date(date, 'DD/MM/YYYY') AS Date,
        ROW_NUMBER() OVER (PARTITION BY TicketID, 
                Type ORDER BY TicketID, Type) AS number_of_item_per_type_in_ticket,
        CASE WHEN ascii(memberid)=0 THEN '0' ELSE memberid END AS memberid,
        COUNT(*) OVER (PARTITION BY TicketID, 
                Type ORDER BY TicketID, Type) AS items_per_types_in_ticket,
        p.price,
       AVG(p.Price) OVER (PARTITION BY TicketID, Type ORDER BY TicketID, Type) AS avg_price_per_type
from cafe_orders,
LATERAL 
        (
            SELECT CASE WHEN price IS NULL THEN 1.5 ELSE price END AS Price
        ) p

LIMIT 30 
;
-- Step 1: Join transaction and customer details tables