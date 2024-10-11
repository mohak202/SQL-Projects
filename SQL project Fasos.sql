drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2021 21:30:45','25km','25mins',null),
(8,2,'01-10-2021 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2021 18:50:20','10km','10minutes',null);

update driver_order set pickup_time= DATEADD(YEAR,1,pickup_time) 
where YEAR(pickup_time)= 2020


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

---1) How many rolls were ordered?

select count(roll_id) from customer_orders

---2) How many unique customer orders were made?

select count(distinct customer_id) from customer_orders;

---3) How many successfull orders were delivered by each driver?

select driver_id, count(distinct order_id) cnt from driver_order
 where cancellation not in ('Cancellation', 'customercancellation')
 group by driver_id

 ---4) How many of each type of rolls were delivered?

 select roll_id, COUNT(roll_id) from customer_orders where order_id in
 (select a.order_id from 
(select *, case when cancellation in ('cancellation', 'customer cancellation') then 'c'
 else 'nc' end order_cancel_details from  driver_order) a
 where a.order_cancel_details = 'nc')
 group by roll_id

 ---5) How many Veg and Nonveg rolls were ordered by each customer?
select * from customer_orders;
select * from driver_order;
select * from rolls;

  
 select a.*,b.roll_name from
  (
 select customer_id, roll_id, count(roll_id) cnt from customer_orders group by 
 customer_id, roll_id )a inner join rolls b on a.roll_id = b.roll_id
 order by customer_id

---6) What were the maximum no of rolls delivered in a single order?
select * from 
(select order_id, cnt, rank() over(order by b.cnt desc) rnk  from 
(select order_id, COUNT(roll_id) cnt from customer_orders where order_id in
 (select a.order_id from 
(select *, case when cancellation in ('cancellation', 'customer cancellation') then 'c'
 else 'nc' end order_cancel_details from  driver_order) a
 where a.order_cancel_details = 'nc')
 group by order_id) b) c
 where rnk= 1

 ---7) For each customer, how many delivered rolls have atleat 1 change and how many had 
 -----no change ?

 with temp_customer_orders  as
 (
 select order_id, customer_id, roll_id, 
 case when not_include_items is null or not_include_items=' ' then '0'  
 else not_include_items  end as new_not_include_items,
 case when extra_items_included is null or extra_items_included=' 'or extra_items_included= 'nan'  
  then '0' else extra_items_included end as new_extra_items_included, order_date 
  from customer_orders
 ),

  temp_driver_order  as
 (
 select order_id,driver_id,pickup_time,distance,duration, 
 case when cancellation in('cancellation','customer cancellation') then '0'
 else 1 end as new_cancellation
  from driver_order
 ) 
   select customer_id,change_no_change, count(order_id) from
 (select  *, case when new_extra_items_included = '0' and 
 new_not_include_items='0' then 'no_change'
 else 'change' end change_no_change
 from temp_customer_orders  where order_id in
 (select  order_id from temp_driver_order where new_cancellation = 1))a
 group by customer_id, change_no_change
 order by customer_id
  select * from customer_orders
 
 ---8 How many rolls were delivered that had both exclusions and extras?
	
 with temp_customer_orders  as
 (
 select order_id, customer_id, roll_id, 
 case when not_include_items is null or not_include_items=' ' then '0'  
 else not_include_items  end as new_not_include_items,
 case when extra_items_included is null or extra_items_included=' 'or extra_items_included= 'nan'  
  then '0' else extra_items_included end as new_extra_items_included, order_date 
  from customer_orders
 ),

  temp_driver_order  as
 (
 select order_id,driver_id,pickup_time,distance,duration, 
 case when cancellation in('cancellation','customer cancellation') then '0'
 else 1 end as new_cancellation
  from driver_order
 ) 
   select change_no_change, count(a.change_no_change) cnt from 
 (select  *, case when new_extra_items_included != '0' and 
 new_not_include_items !='0' then 'both_inc_exc'
 else 'either _inc_or_exc' end change_no_change
 from temp_customer_orders  where order_id in
 (select  order_id from temp_driver_order where new_cancellation = 1))a
 group by change_no_change
 
  
----9) What was the total number of rolls ordered for each hour of the day?
 select hour_bracket, count(hour_bracket) no_of_orders from 
 (select *,concat(cast(DATEPART(hour, order_date) as varchar) ,'-', cast(DATEPART(hour, order_date)+1 as varchar) ) hour_bracket
 from customer_orders)a
 group by hour_bracket

 ----10) What was the number of orders for each day of the week?
 select * from customer_orders

 select name_of_week, count(distinct order_id) no_of_orders from 
 (select *,DATEname(WEEKDAY, order_date) name_of_week 
 from customer_orders)a
 group by name_of_week
 
 ---11)What was the average in minutes it took for eah driver to reach the fasos HQ to pickup the order?
 select  driver_id, sum(diff)/COUNT(diff) avg_time from 
 (select *, row_number() over(partition by order_id order by diff ) rnk from
 (select a.order_id,a.customer_id,a.roll_id,a.order_date, b.driver_id,pickup_time,
 DATEDIFF(minute,a.order_date,b.pickup_time) diff
 from customer_orders a inner join driver_order b 
 on a.order_id = b.order_id where b.pickup_time is not null) c) d where rnk = 1
 group by driver_id

----12) Is there any relationship between the number of rolls and how long the order takes to prepare?
 
 select c.order_id, count(c.roll_id) no_of_rolls, sum(c.diff)/COUNT(c.roll_id) tym from 
 (select a.order_id,a.customer_id,a.roll_id,a.order_date, b.driver_id,pickup_time,
 DATEDIFF(minute,a.order_date,b.pickup_time) diff
 from customer_orders a inner join driver_order b 
 on a.order_id = b.order_id where b.pickup_time is not null)c
 group by c.order_id


---13) What was the average distance travelled for each customer?
select customer_id, SUM(d.updated_dis)/COUNT(d.updated_dis) avg_dis  from 
(select c.*, row_number() over(partition by c.order_id order by c.updated_dis)rnk from
(select a.order_id,a.customer_id,a.roll_id,a.order_date, b.driver_id,pickup_time,
cast(trim(replace(b.distance,'km','')) as decimal(4,2)) updated_dis
 from customer_orders a inner join driver_order b 
 on a.order_id = b.order_id where b.pickup_time is not null)c)d where rnk = 1
 group by customer_id


----14) What was the difference between the longest and the shoertest dilevery times for all orders?

select duration, CHARINDEX('m', duration) from driver_order

select max(a.dur)- MIN(dur) diff from
(select duration, cast(case when duration like '%min%' then trim(left(duration, CHARINDEX('m',duration)-1)) 
else duration  end as int) as dur
from driver_order)a

----15) What is the average speed of each driver for each delivery and 
-----   do you notice any trends foe these values?

select  a.order_id,a.driver_id, (a.updated_dis/a.dur)*10 from
(select order_id, driver_id, cast(case when duration like '%min%' then trim(left(duration, CHARINDEX('m',duration)-1)) 
else duration  end as int) as dur,cast(trim(replace(distance,'km','')) as decimal(4,2)) updated_dis 
from driver_order where distance is not null)a


---16) What is the successfull delivery percentage of each driver?

select b.driver_id,(b.successfully_delivered * 1.0/ b.total_orders_taken)*100 from 
(select a.driver_id, sum(a.can_per) successfully_delivered, count(a.can_per) total_orders_taken from
(select driver_id, case when cancellation like '%cancel%' then 0 else 1 end can_per from driver_order)a
group by driver_id)b