drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


	select * from sales;
	select * from product;
	select * from goldusers_signup;
	select * from users;

---1. What is the total smount each customer is spending on zomato?

select s.userid,   sum(p.price) as 'total_amount_spent' from sales as s inner join product as p 
on s.product_id = p.product_id
group by s.userid

---2.How many days has each customer visited zomato?

select userid, COUNT(distinct created_date) as 'no_of_days' from sales
group by userid

---3. What was the first product purchased by each customer?

select * from 
(select *,RANK() over (partition by userid order by created_date) as rnk from sales) as a where rnk = 1

---4. What is the most purchased item in the menu and how many times was it purchased by all customers?

select userid , COUNT(product_id) as 'no_of_times' from sales where product_id = 
(select  top 1 product_id  from sales group by product_id 
order by COUNT(product_id) desc)
group by userid

---5. Which item was the most popular for each customer
 select * from 
 (select *, rank() over( partition by userid order by cnt desc) rk from 
(select userid , product_id, COUNT(product_id) cnt from sales group by userid, product_id) a) b
 where  rk= 1

 ---6. Which item was purchased first by a customer after they become a member?

 select * from 
 (select rank() over(partition by a.userid order by a.created_date) rk , 
 a.userid, a.created_date, a.product_id, b.gold_signup_date from 
 sales a inner join goldusers_signup b 
 on a.userid = b.userid where created_date >= gold_signup_date ) c  where rk = 1

 --- 7. Which item was purchased just before the customer became the member?


 select * from 
 (select rank() over(partition by a.userid order by a.created_date desc) rk , 
 a.userid, a.created_date, a.product_id, b.gold_signup_date from 
 sales a inner join goldusers_signup b 
 on a.userid = b.userid where created_date <= gold_signup_date ) c  where rk = 1


 -- 8. what is the total orders and amount spent for each customer before they became member?

 select userid, COUNT(created_date) no_of_orders, SUM(price) total_spent from
 (select c.*, p.price from
 (select a.userid,  a.product_id, a.created_date, b.gold_signup_date from 
 sales a inner join goldusers_signup b 
 on a.userid = b.userid 
 where created_date <= gold_signup_date) c  inner join product p on c.product_id = p.product_id) e
 group by userid

 --- 9. If buying each product generates points for eg 5rs= 2 points and each product has different purchasing points 
 ----for eg p1 5rs = 1 point, p2 10rs = 5 points and p3 5rs = 1 point, then calculate points collected by each customer
 ----and which product has the most points till now?

    select * from sales;
	select * from product;
	select * from goldusers_signup;
	select * from users;
 
 ---Solution of 1st part
 
 select x.*, x.points_per_user*2.5 total_cashback from
 (select f.product_id , sum(f.total_points) points_per_user from
 (select e.*, e.total/e.points as total_points from 
 (select d.*, case when d.product_id = 1 then 5 when d.product_id = 2 then 2 when d.product_id = 3 then 5 else 0 
 end as points from   
 (select   s.userid, s.product_id, SUM(p.price) total from sales s 
 join product p on s.product_id = p.product_id 
 group by userid, s.product_id) d) e) f group by f.product_id) x 


 ----Solution of 2nd part
 
 select * from 
 (select g.*, rank() over( order by g.total_points_per_product desc) product_with_highest_points from
 (select  f.product_id , sum(f.total_points) total_points_per_product from
 (select e.*, e.total/e.points as total_points from 
 (select d.*, case when d.product_id = 1 then 5 when d.product_id = 2 then 2 when d.product_id = 3 then 5 else 0 
 end as points from   
 (select   s.userid, s.product_id, SUM(p.price) total from sales s 
 join product p on s.product_id = p.product_id 
 group by userid, s.product_id) d) e) f group by f.product_id) g) r where product_with_highest_points = 1

---10.In the first one year after a customer joins the gold membership (Including the joining date)
---irrespective of what customer purchased they earn 5 zomato point for every every 10rs spent who earn 
---more, 1 or 3? and what was their points earnings in their first year?

    select * from sales;
	select * from product;
	select * from goldusers_signup;
	select * from users;

	select b.userid,  b.total_spent*0.5 points_earned from 
	(select a.userid,  sum(a.price) total_spent from
	(select s.userid, s.created_date,s.product_id, gs.gold_signup_date,p.price
	from sales s join goldusers_signup gs
	on s.userid = gs.userid join product p 
	on s.product_id = p.product_id
	where s.created_date>= gs.gold_signup_date and s.created_date<=dateadd(year,1,gs.gold_signup_date)) a
	group by a.userid) b
	
---- 11.Rank all the transactions of each customer whenever they are a gold member and for every non gold 
---- member transaction mark it as NA.

     select b.*, case when rnk = 0 then 'NA' else rnk end ranking from
	 (select a.*, cast((case when gold_signup_date is null then 0 else 
	 rank() over(partition by userid order by created_date desc)  end)as varchar) rnk from
    (select s.userid, s.created_date,s.product_id, gs.gold_signup_date
	from sales s left join goldusers_signup gs
	on s.userid = gs.userid 
	and s.created_date>= gs.gold_signup_date) a) b



	