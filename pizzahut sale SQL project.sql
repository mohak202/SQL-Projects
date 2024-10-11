select * from pizza_types

select * from pizzas

select * from orders

select * from order_details

--- 1) Retrieve the total number of orders placed.

select count(order_id) as 'Total no of orders' from orders

--2) Calculate the total revenue generated from pizza sales.


select * from pizzas

select * from order_details

select  round(sum (price * quantity),2)  as 'total revenue' from pizzas 
join order_details 
on pizzas.pizza_id = order_details.pizza_id

---3)Identify the highest-priced pizza.

select * from pizzas
select * from pizza_types

select top 1 name ,price from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by price desc


---4) Identify the most common pizza size ordered.
select * from pizzas
select * from pizza_types

select  size, count(order_details.order_details_id) 'order count' from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by  size order by [order count] desc

---5) List the top 5 most ordered pizza types along with their quantities.

select * from pizzas
select * from pizza_types
 select * from order_details

 select  top 5 name, sum(quantity) as 'total orders'  from pizza_types join pizzas
 on pizza_types.pizza_type_id = pizzas.pizza_type_id
 join order_details on 
 pizzas.pizza_id = order_details.pizza_id
 group by name
 order by [total orders] desc

 ---6)Join the necessary tables to find the total quantity of each pizza category ordered.
 
 select * from pizzas
select * from pizza_types
 select * from order_details

 select category, sum(quantity) as 'total orders' from pizza_types
 join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
 join order_details  on order_details.pizza_id = pizzas.pizza_id
 group by category order by [total orders] desc

 
 --7) Determine the distribution of orders by hour of the day and also fetch the pick 5 hours when most orders were 
 ---- placed.

 select * from orders
 select * from order_details

  select  top 5 datepart(hour,time) as hours  , count(order_id) as count_of_orders from orders 
 group by datepart(hour,time)
 order by  count_of_orders desc





---8) Join relevant tables to find the category-wise distribution of pizzas.

 select * from pizzas
select * from pizza_types

select category , count(name) as count from pizza_types group by category

---9) Group the orders by date and calculate the average number of pizzas ordered per day.
 
 
 select * from orders
 select * from order_details

 select round(avg(orders_per_day),0) as avg_orders_perday from
 (select date, sum(quantity) as orders_per_day from orders join order_details
 on orders.order_id = order_details.order_id
 group by date 
 ) as quantity 

 ---10) Determine the top 3 most ordered pizza types based on revenue.

  select * from pizzas
select * from pizza_types
select* from order_details

select top 3 round(sum (price * quantity),2)  as 'total revenue', name from pizzas 
join order_details 
on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by name
order by [total revenue] desc

--11) Calculate the percentage contribution of each pizza type to total revenue.

select category, round(round(sum (price * quantity),2)/(select  round(sum (price * quantity),2)   from pizzas 
                                                   join order_details 
                                                     on pizzas.pizza_id = order_details.pizza_id)  * 100,2) as percent_share

from pizzas 
join order_details 
on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category

---12) Analyze the cumulative revenue generated over time.

select  date, sum(revenue)over (order by date) as cummulative from 

(select date , sum (price * quantity) as revenue from orders join order_details
on orders.order_id = order_details.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by date) as sales


---13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, [total revenue] from 
(select  category ,name , [total revenue] , rank() over(partition by category order by [total revenue] desc)as ranks 
from
 
 (select  category ,round(sum (price * quantity),2)  as 'total revenue', name from pizzas 
join order_details 
on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by  category, name
) as abc) as xyz
where ranks<=3

