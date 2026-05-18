-- ============================================
-- SQL Server — Class 3 Homework
-- BikeStores Sample Database
-- Topics: GROUP BY · HAVING · ROLLUP · GROUPING SETS · Subqueries · EXISTS · ANY / ALL · APPLY
-- ============================================

-- Q1: Count how many products each brand has in the catalog.
-- Show brand name and product count.
-- Sort by count descending.

select 
		b.brand_name,
count(p.product_id) as brand_product_count
from [production].[products] as p
inner join [production].[brands] as b
on p.brand_id = b.brand_id
group by brand_name
order by  brand_product_count desc;


-- Q2: For each category, show:
-- category name,
-- total number of products,
-- cheapest price,
-- most expensive price,
-- average price (rounded to 2 decimals).
-- Sort by average price descending.

select 
		c.category_name,
		sum(p.product_id) as Total_number_of_products,
		min(p.list_price) as Cheapest_Price,
		max(p.list_price) as Expensive_Price,
		round(avg(p.list_price),2) as Average_Price
from [production].[products] p
inner join [production].[categories] c
on p.category_id = c.category_id
group by category_name
order by Average_Price desc;

-- Q3: Show the number of orders placed per order status.
-- Display the status value and order count.
-- Sort by order_status ascending.

select  
		order_status,
		count(order_id) as Number_of_Order
from [sales].[orders]
group by order_status
order by order_status ;


-- Q4: For each store, calculate total revenue:
-- (quantity × list_price × (1 – discount)) from order_items.
-- Show store name and total revenue.
-- Sort by revenue descending.

select 
		s.store_name,
		sum(quantity * list_price * (1 - discount)) as revenue
from [sales].[orders] o
inner join [sales].[stores] s 
on o.store_id = s.store_id
inner join [sales].[order_items] oi
on o.order_id = oi.order_id
group by store_name
order by revenue desc;

-- Q5: Show total number of products per brand per model year.
-- Display brand name, model year, and product count.
-- Sort by brand name then model year.

select 
		b.brand_name,
		p.model_year,
		count(product_id) as Total_Products
from [production].[products] p
inner join [production].[brands] b
on p.brand_id = b.brand_id
group by brand_name, model_year
order by brand_name, model_year;


-- Q6: Find all brands that have more than 25 products in the catalog.
-- Show brand name and product count.

select 
		b.brand_name,
		count(product_id) Total_Products
from [production].[products] p
inner join [production].[brands] b
on p.brand_id = b.brand_id
group by brand_name
having count(product_id) > 25;


-- Q7: Among products from year 2018 only,
-- find categories whose average price is above $1500.
-- Show category name, product count, and average price.

select
   c.category_name,
   count(p.product_id) as Product_Count,
   avg(p.list_price) as Average_Price
from [production].[products] p
inner join [production].[categories] c
on p.category_id = c.category_id
where p.model_year = 2018  
group by c.category_name
having avg(p.list_price) > 1500


-- Q8: Find customers who have placed 3 or more orders.
-- Show customer full name and order count.
-- Sort by order count descending.

select
		c.first_name + ' ' + c.last_name as Customer_name,
		count(o.order_id) as Order_Count
from [sales].[orders] o
inner join [sales].[customers] c
on o.customer_id = c.customer_id
group by c.first_name + ' ' + c.last_name 
having count(o.order_id) > 2
order by Order_Count desc;

-- Q9: Find all products whose list price is higher than
-- the average list price of all products.
-- Show product name and price.
-- Sort by price descending.

select
		p.product_name,
		p.list_price as Price
from [production].[products] p
where p.list_price >
(select avg(p.list_price)  Avg_Price
  from [production].[products] p)
 order by price desc;

-- Q10: Find all orders placed by customers from state 'TX'.
-- Use a subquery (NOT a JOIN).
-- Show order ID, customer ID, and order date.

select
		o.order_id,
		o.customer_id,
		o.order_date
from [sales].[orders] o
where o.customer_id in
(select c.customer_id
from [sales].[customers] c where c.state = 'TX')



-- Q11: For each brand, show its average price,
-- but only for brands whose average price exceeds overall product average.
-- Use a subquery in FROM (derived table).
-- Show brand name and average price.

 
select 
		b.brand_name,
		avg(p.list_price) Avg_Price
from [production].[products] p 
inner join [production].[brands] b 
on p.brand_id = b.brand_id
group by b.brand_name
having avg(p.list_price) > (
		select avg(list_price) 
		from [production].[products]
		)




-- Q12: Using EXISTS:
-- Find all customers who have placed at least one order.
-- Show customer full name and email.

select 
		c.first_name + ' ' + c.last_name as Customer_name,
		c.email
from [sales].[customers] c
where exists (
		select 1 
		 from [sales].[orders] o
		 where o.customer_id = c.customer_id
)

-- Q13: Using NOT EXISTS:
-- Find all products that have never appeared in any order (order_items).
-- Show product name and list price.

select
		p.product_name ,
		p.list_price
from [production].[products] p
where not exists(
		select 1
		from [sales].[order_items] oi
		where oi.product_id = oi.product_id
		)
