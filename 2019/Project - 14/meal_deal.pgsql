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
     
SET Datestyle TO dmy;
create table cafe_orders(
    TicketID VARCHAR,
    Date VARCHAR,
    MemberID VARCHAR,
    Descp VARCHAR,
    Price FLOAT,
    Type VARCHAR

);
COPY cafe_orders From 'C:\Users\DIANA\Desktop\Projects\SQL\Data\Cafe_orders.csv'
WITH (FORMAT CSV, NULL 'NULL', HEADER);

select * from cafe_orders
LIMIT 100;
-- Step 1: Join transaction and customer details tables