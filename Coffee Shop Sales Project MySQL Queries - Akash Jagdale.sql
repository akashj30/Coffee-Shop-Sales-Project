-- Creating Database
create database coffee_shop_sales_db;

-- Using the Database
use coffee_shop_sales_db;


select * from coffee_shop_sales;

-- DATA TYPES OF DIFFERENT COLUMNS
describe coffee_shop_sales;

set SQL_SAFE_UPDATES = 0;

-- CONVERT TIME (transaction_time)  COLUMN TO PROPER DATE FORMAT
UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

-- CONVERTING DATE (transaction_date) COLUMN TO PROPER DATE FORMAT
UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d:%m:%Y');
 
-- ALTERING DATE (transaction_date) COLUMN TO DATE DATA TYPE
alter table coffee_shop_sales
modify column transaction_date date;

-- ALTERING TIME (transaction_time) COLUMN TO DATE DATA TYPE
alter table coffee_shop_sales
modify column transaction_time time;

-- TOTAL SALES FOR MAY MONTH
select round(sum(unit_price*transaction_qty),1) as Total_Sales
from coffee_shop_sales
where month(transaction_date)=5; -- May Month

-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH
select month(transaction_date) as month, -- number of month
round(sum(unit_price * transaction_qty)) as Total_Sales, -- total sales
(sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty),1) -- Month difference Sales
over(order by month(transaction_date))) / lag(sum(unit_price*transaction_qty),1) -- division by previous month sales
over(order by month(transaction_date))* 100 as mom_increase_percentage -- percentage mom=Month on Month

from coffee_shop_sales
where month(transaction_date) in (4,5) -- for month of April(Previous Month) and May(Current Month)
group by  month(transaction_date)
order by  month(transaction_date);



-- TOTAL ORDERS
select count(transaction_id) as Total_Sales from coffee_shop_sales
where month(transaction_date)=5; -- for March month


-- TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH
select month(transaction_date) as month, -- number of month
round(count(transaction_id)) as Total_Order, -- total sales
(count(transaction_id) - lag(count(transaction_id),1) -- Month difference Sales
over(order by month(transaction_date))) / lag(count(transaction_id),1) -- division by previous month sales
over(order by month(transaction_date))* 100 as mom_increase_percentage -- percentage mom=Month on Month

from coffee_shop_sales
where month(transaction_date) in (4,5) -- for month of April(Previous Month) and May(Current Month)
group by  month(transaction_date)
order by  month(transaction_date);


-- TOTAL QUANTITY SOLD
select sum(transaction_qty) as Total_Quantity from coffee_shop_sales
where month(transaction_date)=5; -- June month


-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
select month(transaction_date) as month,
round(sum(transaction_qty)) as total_qty_sold,
(sum(transaction_qty) - lag(sum(transaction_qty),1)
over(order by month(transaction_date))) / lag(sum(transaction_qty),1)
over(order by month(transaction_date)) * 100 as mom_increased_percentage

from coffee_shop_sales
where month(transaction_date) in (4,5)
group by month(transaction_date)
order by month(transaction_date);	


-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS WITH Rounded off values 
select concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as Total_Sales,
       concat(round(sum(transaction_qty)/1000,1),'K') as Total_Quantity_Sold,
        concat(round(count(transaction_id)/1000,1),'K') as Total_Orders
from coffee_shop_sales
where transaction_date = '2023-05-18';



-- SALES BY WEEKDAY / WEEKEND:
select 
	case when dayofweek(transaction_date) in (1,7) then 'Weekends'
    else 'Weekdays'
    end as 'Day_type'	,
    concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as Total_Sales
from coffee_shop_sales
where month(transaction_date)=5 -- MAY Month
group by 
        case when dayofweek(transaction_date) in (1,7) then 'Weekends'
    else 'Weekdays'
    end;


-- SALES BY STORE LOCATION
select store_location,concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as Total_Sales
from coffee_shop_sales
where month(transaction_date) = 5 -- May Month
group by store_location
order by sum(unit_price * transaction_qty) desc;


-- SALES TREND OVER PERIOD
select concat(round(avg(total_sales)/1000,1),'K') as Avg_Sales
from(
     select sum(unit_price * transaction_qty) as total_sales
     from coffee_shop_sales
     where month(transaction_date) = 5 -- May Month
     group by transaction_date
) as Internal_query;


-- DAILY SALES FOR MONTH SELECTED
select day(transaction_date) as Day_of_Month,
	sum(unit_price * transaction_qty) as Total_Sales
from coffee_shop_sales
where month(transaction_date) =5
group by day(transaction_date)
order by day(transaction_date);



-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
select day_of_month,
case 
     when total_sales > avg_sales then 'Above Average'
     when total_sales < avg_sales then 'Below Average'
     else 'Average'
end as sales_status,
total_sales from (
                  select day(transaction_date) as day_of_month,
				  SUM(unit_price * transaction_qty) AS total_sales,
                  avg(sum(unit_price * transaction_qty)) over() as avg_sales
                  from coffee_shop_sales 
                  where month(transaction_date) = 5 -- May Month
                  group by day(transaction_date)
                  order by day(transaction_date)
) as sales_data
order by day_of_month;


-- SALES BY PRODUCT CATEGORY
select product_category, sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
where month(transaction_date)=5
group by product_category
order by total_sales desc;


-- SALES BY PRODUCTS (TOP 10)
select product_type, sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
where month(transaction_date)=5 and product_category='Coffee'
group by product_type
order by total_sales desc
limit 10;


-- SALES BY DAY | HOUR
select sum(unit_price * transaction_qty) as total_sales,
	   sum(transaction_qty) as Total_qty_Sold,
       count(*) as Total_Orders
from coffee_shop_sales
where month(transaction_date) = 5 -- May month
and dayofweek(transaction_date) = 3 -- Monday
and hour(transaction_time) = 8; -- hour no 8


-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
select hour(transaction_time) as hours_of_day,
	  sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales 
where month(transaction_date) = 5
group by hour(transaction_time)
order by hour(transaction_time);


-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;


