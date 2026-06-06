-- ================================================================================
-- HOMEWORK: CLASS 5 - CTEs, PIVOT, EXPRESSIONS & WINDOW FUNCTIONS (EASY VERSION)
-- Database: BikeStores Sample Database
-- Instructions: Write SQL statements to solve each problem below.
-- ================================================================================

-- ================================================================================
-- SECTION A: CASE Expressions 
-- ================================================================================

-- Q1: Write a simple CASE that shows order_status as a word instead of number.
--     Show order_id, order_status (number), and status_description (word).
		
		SELECT  order_id,
				order_status,
				CASE order_status
						WHEN 1 THEN 'PACKING'
						WHEN 2 THEN 'SHIPPED'
						WHEN 3 THEN 'IN REGION'
						WHEN 4 THEN 'DELIEVERED'
				END AS status_description		
		FROM [sales].[orders]
		
				

-- Q2: Categorize products by price:
--     Under $500 = 'Budget'
--     $500 to $2000 = 'Standard' 
--     Over $2000 = 'Premium'
--     Show product_name, list_price, and price_category.

		SELECT
				product_name,
				list_price,
				CASE 
						WHEN list_price < 500 THEN 'BUGDET'
						WHEN list_price BETWEEN 500 AND 2000 THEN 'STANDARD'
						WHEN list_price < 2000 THEN 'PREMIUM'
				END AS price_category
		FROM production.products

-- Q3: Using CASE with COUNT, count how many orders have status = 4 (Completed) 
--     vs non-completed for each store. Show store_id, completed_count, not_completed_count.

	
				select 
				store_id,
				count (CASE  
						WHEN order_status = 4 THEN 1 END) 
				 AS completed_count,
				 COUNT(CASE  
						WHEN order_status <> 4 THEN 1 END)
				AS not_completed_count
				FROM  [sales].[orders]
				GROUP BY store_id
		

-- Q4: Create a column called "year_label" that shows:
--     If model_year = 2024: 'New'
--     If model_year = 2023: 'Recent'
--     Else: 'Older'
--     Show product_name, model_year, year_label.
		
		SELECT  
				product_name,
				model_year,
				CASE model_year
						when 2024 THEN 'NEW'
						WHEN 2023 THEN 'RECENT'
						ELSE 'OLDER'
				END as year_label
				
		FROM [production].[products];

-- Q5: For customers, show email and a column called "has_email" that says 'Yes' if email is not NULL, 'No' if NULL.

-- ================================================================================
-- SECTION B: CTEs (Common Table Expressions)
-- ================================================================================

-- Q6: Create a CTE called "high_value_products" that selects products with list_price > 3000.
--     Then SELECT from that CTE to show all those products.

		WITH high_value_products AS(
		SELECT 
				product_name,
				list_price 
		from [production].[products]
		where list_price > 3000
		) 
		select * from high_value_products;


-- Q7: Write a CTE that calculates the average list_price of all products.
--     Then use it to find products that cost more than average.
		
		WITH Avg_Product_Price AS (
		 SELECT AVG(list_price) AS AvgPrice
		FROM production.products
		)
		SELECT 
		 p.product_name,
		 p.list_price
		FROM production.products p
		CROSS JOIN  Avg_Product_Price
		WHERE p.list_price >  Avg_Product_Price.AvgPrice;



-- Q8: Create a CTE called "customer_order_counts" that counts how many orders each customer has.
--     Then use it to find customers with more than 5 orders.

		WITH customer_order_counts AS(
		SELECT customer_id,	
			count(order_date) as Total_Order
		FROM [sales].[orders] 
		group by customer_id
		)
		select * from customer_order_counts
		where Total_Order > 5 ;


-- ================================================================================
-- SECTION C: ROW_NUMBER() and RANK() - EASY BEGINNER
-- ================================================================================

-- Q9: Use ROW_NUMBER() to number all products ordered by list_price from highest to lowest.
--      Show product_name, list_price, and row_number.

		SELECT
				product_name,
				list_price,
				ROW_NUMBER() OVER (ORDER BY LIST_PRICE) AS R
		FROM production.products

		

-- Q10: Use ROW_NUMBER() to rank products by price WITHIN each brand (partition by brand_id).
--      Show brand_id, product_name, list_price, and rank_in_brand.
		
		SELECT
				brand_id,
				product_name,
				list_price, 
				ROW_NUMBER() OVER(PARTITION BY BRAND_ID ORDER BY LIST_PRICE) AS rank_in_brand
		FROM production.products


-- Q11: Use RANK() instead of ROW_NUMBER() on products ordered by list_price.
--      See what happens when multiple products have the same price.

		SELECT 
				product_name,
				list_price, 
				RANK() OVER (ORDER BY LIST_PRICE) AS RANK_PRICE
		FROM production.products;


-- ================================================================================
-- SECTION D: Window Functions - Running Totals and Averages
-- ================================================================================

-- Q12: Calculate a running total of daily orders (cumulative sum over time).
--      Show order_date, daily_order_count, and running_total.
		
		with Daily_Orders as (
		select 
				o.order_date,
				COUNT(Distinct o.order_id) as daily_order_count
		from [sales].[orders] o
		inner join  [sales].[order_items] oi
		on o.order_id = oi.order_id
		group by o.order_date
		)

		select 
				order_date,
				daily_order_count, 
				sum (daily_order_count) over (ORDER BY order_date) AS running_total
		from Daily_Orders


-- Q13: For each product, show its list_price and the average list_price of its brand.
--      Use AVG() OVER (PARTITION BY brand_id).

				SELECT
						product_name,
						list_price,
						AVG(list_price) OVER(PARTITION BY BRAND_ID) AS AVG_BRAND_PRICE
				FROM production.products;	

-- Q14: Calculate a running total of quantity sold for each product over time.
--      Show product_id, order_date, quantity, and cumulative_quantity for that product.

		
		
		SELECT 
				OI.product_id,
				O.order_date,
				oi.quantity,
				SUM(quantity) OVER (PARTITION BY OI.PRODUCT_ID) AS cumulative_quantity

		FROM sales.order_items OI
		INNER JOIN sales.orders O
		ON OI.order_id = O.order_id
	

-- ================================================================================
-- SECTION E: LAG, LEAD (Previous and Next)
-- ================================================================================

-- Q15: For each customer, show their order date and the date of their previous order.
--      Use LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date).

		SELECT 
				order_date,
				LAG(order_date) OVER(PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE) AS PREVIOUS_ORDERDATE
		FROM sales.orders;

-- Q16: Calculate the number of days between a customer's consecutive orders.
--      (Use LAG and DATEDIFF)
		
		SELECT	
				customer_id,
				LAG(order_date) OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE) AS PREVIOUS_ORDER_DATE,
				DATEDIFF(DAY, LAG(ORDER_DATE) OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE), ORDER_DATE) AS DAYS_BTW_OD
		FROM SALES.orders;



-- ================================================================================
-- SECTION F: PIVOT (Rows to Columns)
-- ================================================================================

-- Q17: Create a simple pivot showing the count of orders for each order_status (1,2,3,4) 
--      as separate columns. Only need store_id and the 4 status columns.

Select * from (
		select store_id , order_id, order_status  
		from sales.orders)
		as sourcetable

		pivot (
		count(order_id)
		for order_status in  ([1],[2],[3],[4])
		) as pivottable;




-- ================================================================================
-- SECTION G: Mixed Practice (Putting It All Together)
-- ================================================================================

-- Q18: Use CASE to categorize customers by total spending:
--      Over $5000 = 'VIP'
--      $1000-$5000 = 'Regular'
--      Under $1000 = 'New'
--      Show customer_name and tier.

select  
		c.first_name +' '+ c.last_name as customer_name,
		case 
				when oi.list_price > 5000 then 'VIP'
				when oi.list_price >= 1000 and oi.list_price <5000 then 'REGULAR'
			    when oi.list_price <1000 then 'NEW'
		 end as tier
				
from sales.customers c
inner join sales.orders o
on c.customer_id = o.customer_id
inner join sales.order_items oi
on o.order_id = oi.order_id

		



-- Q19: Use ROW_NUMBER() and CASE together: Find top 3 products per category, 
--      and label them as 'Gold', 'Silver', 'Bronze'.

WITH RankedProducts AS (
    SELECT 
        p.product_name,
        c.category_name,
        ROW_NUMBER() OVER (
            PARTITION BY p.category_id 
            ORDER BY p.list_price ASC
        ) AS rank
    FROM production.products p
    INNER JOIN production.categories c
        ON p.category_id = c.category_id
)
SELECT 
    product_name,
    category_name,
    rank,
    CASE 
        WHEN rank = 1 THEN 'Gold'
        WHEN rank = 2 THEN 'Silver'
        WHEN rank = 3 THEN 'Bronze'
    END AS label
FROM RankedProducts
WHERE rank <= 3
ORDER BY category_name, rank;


-- Q20: Create a CTE that calculates monthly revenue, then use LAG to show month-over-month growth.

WITH MonthlyRevenue AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM((oi.quantity * oi.list_price) *(1 - oi.discount)) AS revenue
    FROM sales.orders o
	inner join sales.order_items oi
	on o.order_id = oi.order_id
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_year,
    order_month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY order_year, order_month) AS prev_revenue,
    (revenue - LAG(revenue, 1) OVER (ORDER BY order_year, order_month)) AS growth
FROM MonthlyRevenue
ORDER BY order_year, order_month;


-- Q21: Write a query that shows each product, its price, its rank in its brand, 
--      and a CASE that says 'Top Product' if rank = 1, else 'Other'.

WITH RankedProducts AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.list_price,
        p.brand_id,
        ROW_NUMBER() OVER (
            PARTITION BY p.brand_id 
            ORDER BY p.list_price DESC
        ) AS rank
    FROM production.products p
)
SELECT 
    product_name,
    list_price,
    rank,
    CASE 
        WHEN rank = 1 THEN 'Top Product'
        ELSE 'Other'
    END AS label
FROM RankedProducts
ORDER BY brand_id, rank;


-- Q22: Create a pivot showing the count of customers by state and by customer tier 
--      (you'll need to create the tier using CASE first, then pivot).

-- Step 1: Create tiers using CASE
WITH CustomerTiers AS (
    SELECT 
        c.customer_id,
        c.state,
        CASE 
            WHEN oi.list_price >= 5000 THEN 'Platinum'
            WHEN oi.list_price  >= 2000 THEN 'Gold'
            WHEN oi.list_price  >= 1000 THEN 'Silver'
            ELSE 'Bronze'
        END AS tier
from sales.customers c
inner join sales.orders o
on c.customer_id = o.customer_id
inner join sales.order_items oi
on o.order_id = oi.order_id
)
-- Step 2: Pivot counts by state and tier
SELECT *
FROM (
    SELECT state, tier
    FROM CustomerTiers
) AS SourceTable
PIVOT (
    COUNT(tier)
    FOR tier IN ([Platinum], [Gold], [Silver], [Bronze])
) AS PivotTable
ORDER BY state;


-- ================================================================================
-- END OF HOMEWORK - ALL QUESTIONS ARE BEGINNER-FRIENDLY
-- ================================================================================