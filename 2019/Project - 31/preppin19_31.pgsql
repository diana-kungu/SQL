-- SQL flavor postgresql

--Scenario/Goal
 /*
    Text Parsing:- PIVOT TABLES

 */
     
-- FUNCTIONS WINDOW FUNCTIONS

--Step 1: Pivot the status field
WITH CTE_pivot AS
    (SELECT 
            order_no,
            date,
            customer,
            city,
            CASE WHEN status ILIKE 'Purchased%' THEN date END AS Purchased,
            CASE WHEN status ILIKE 'sent%' THEN date END Sent,
            CASE WHEN status ILIKE 'Reviewed%' THEN date END Reviewed

    FROM soap.buyer_behaviour)

--Step 2: Aggregate each order_no info on a single row
SELECT 
        order_no,
        customer,
        max(city) city,
        MAX(purchased) purchased,
        MAX(sent) sent,
        max(reviewed) reviewed
INTO TEMP buyers_formatted
FROM CTE_pivot
GROUP BY order_no,
         customer
;

--Step 3: Calculate time to send and time to review
CREATE TEMP TABLE buyer_agg AS 
    (SELECT
        *,
        sent - purchased AS time_to_send,
        Reviewed - sent AS time_to_review,
        CASE WHEN reviewed  is NULL THEN 0 ELSE 1 END Reviewed_flag
    FROM buyers_formatted
    )
; 

--step 4: 
-- step 4a: Average time to send the order
SELECT
        customer,
        ROUND(AVG(time_to_send),1) AVG_time_to_send
FROM buyer_agg
GROUP BY customer
;

-- step 4b:  Average time to review 
SELECT
        customer,
        ROUND(AVG(time_to_review),1) AVG_time_to_review
FROM buyer_agg
WHERE Reviewed_flag = 1
GROUP BY customer
;

-- step 4c: Cities where orders not sent
SELECT
        'Not sent' AS Order_not_sent,
        order_no,
        customer,
        city,
        Purchased,
        Sent
FROM buyer_agg
WHERE sent IS NULL
;

-- step 4d: For orders sent, which % of each cities orders have not been sent out within 3 days or less
-- count number of orders per city
-- flag orders meeting the kpi
CREATE TEMP TABLE kpi_check AS
    (SELECT
            city,
            time_to_send,
            sent,
            COUNT(*) OVER (PARTITION BY city) orders_per_city,
            CASE WHEN time_to_send <= 3 THEN 1 ELSE 0 END KPI_met
    FROM buyer_agg
    )
;    
--calculate % of orders meeting the kpi per city
SELECT
        city,
        SUM(kpi_met) AS Time_to_send_KPI,
        MAX(orders_per_city) orders_per_city,
        SUM(kpi_met::Numeric) *100/MAX(orders_per_city) AS percent_orders_meeting_3Days_kpi
FROM kpi_check
GROUP BY city