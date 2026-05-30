-- ================================================================================
-- HOMEWORK: CLASS 4 - MODIFYING DATA, DDL, DATA TYPES & CONSTRAINTS
-- Database: BikeStores Sample Database
-- Instructions: Write SQL statements to solve each problem below.
-- Answers will be provided in a separate file.
-- ================================================================================

-- ================================================================================
-- SECTION A: DATA TYPES & CONSTRAINTS (Conceptual Questions)
-- ================================================================================

-- Q1: What data type would you use for a product's weight (e.g., 2.5 kg)?

		weight decimal(5,3)  12345.999


-- Q2: In the sales.stores table, the zip_code is VARCHAR(5). Why not use INT?
			
		--	We donot addition, subtract, or average ZIP codes.Hence text storage (VARCHAR) is more appropriate.


-- Q3: Look at sales.orders.order_status. The comment says 1=Pending,2=Processing,3=Rejected,4=Completed.
--     Is TINYINT a good choice? Why not use INT?


		--yes, tinyint is a good choice as int will be large enough to just to store (1-4) numbers


-- Q4: If you add a CHECK constraint that rating must be BETWEEN 1 AND 5, what happens if you try to INSERT rating = 0?
		
		--It cannot be zero if CHECK constraint is there


-- Q5: Why does sales.staffs have UNIQUE constraint on email but not on phone?

		--Depends on the need email should be unique for may perpose including login email,
		--or foremost communication need.



-- ================================================================================
-- SECTION B: DDL (CREATE, ALTER, DROP)
-- ================================================================================

-- Q6: Create a new table called sales.loyalty_programs with the following columns:
--     - program_id (INT, auto-increment starting 1, PRIMARY KEY)
--     - program_name (VARCHAR(100), NOT NULL, UNIQUE)
--     - discount_rate (DECIMAL(3,2), NOT NULL, DEFAULT 0.05, CHECK between 0.00 and 0.50)
--     - start_date (DATE, NOT NULL, DEFAULT GETDATE())
--     - end_date (DATE, NULL)

CREATE TABLE sales.loyalty_programs (
    program_id INT IDENTITY(1,1) NOT NULL,
    program_name VARCHAR(100) NOT NULL UNIQUE,
    
    discount_rate DECIMAL(3,2) NOT NULL
        DEFAULT 0.05
        CHECK (discount_rate BETWEEN 0.00 AND 0.50),

    start_date DATE NOT NULL DEFAULT GETDATE(),
    end_date DATE NOT NULL DEFAULT GETDATE()
);


-- Q7: Add a new column 'loyalty_program_id' (INT, NULL) to the sales.customers table.

    alter table sales.customers
    add [loyalty_program_id] INT null;



-- Q8: Add a FOREIGN KEY constraint to sales.customers.loyalty_program_id that references 
--     sales.loyalty_programs.program_id.
        
		ALTER TABLE [sales].[customers]
		ADD CONSTRAINT FK_loyalty_program_id
		FOREIGN KEY(program_id)
		REFERENCES  sales.loyalty_programs (program_id);



-- Q9: Change the data type of sales.customers.zip_code from VARCHAR(5) to VARCHAR(10).

    ALTER TABLE sales.customers
    ALTER COLUMN zip_code VARCHAR(10);

-- Q10: Drop the column 'birth_date' from sales.customers (first add it if it doesn't exist, then drop it).

   alter table sales.customers
   add birtXh_date date null;


   alter table sales.customers
   drop column  birth_date

-- Q11: Create a new table production.product_reviews with appropriate columns and constraints:
--      - review_id (PK, auto-increment)
--      - product_id (FK to production.products)
--      - customer_id (FK to sales.customers)
--      - rating (TINYINT, 1-5)
--      - review_text (VARCHAR(1000))
--      - review_date (DATE, default today)

		Create table production.product_reviews(

		review_id INT IDENTITY(1,1) NOT NULL,
		product_id  INT NOT NULL,
		customer_id INT NOT NULL,
		rating TINYINT NOT NULL 
				CHECK (rating between 1 and 5 ),
		review_text VARCHAR(1000) NOT NULL,
		review_date DATE NOT NULL DEFAULT GETDATE() ,
	
		);

-- ================================================================================
-- SECTION C: INSERT STATEMENTS
-- ================================================================================

-- Q12: Insert a new brand called 'Santa Cruz' into production.brands.

SET IDENTITY_INSERT production.brands on;
        
        INSERT INTO production.brands
        (BRAND_ID, BRAND_NAME)
        VALUES (9, 'Trek')

        SELECT * FROM production.brands;

-- Q13: Insert three new categories at once: 'Mountain', 'Road', 'Hybrid'.

 SELECT * FROM production.categories;
 INSERT INTO production.categories
 (category_name)
 VALUES ('Mountain'), ('Road'), ('Hybrid')
        

-- Q14: Insert a new product with the following details:
--      product_name = 'Santa Cruz Bronson'
--      brand_id = (the brand_id of 'Santa Cruz' from Q12)
--      category_id = (category_id of 'Mountain' from Q13)
--      model_year = 2025
--      list_price = 4299.99

	INSERT INTO [production].[products] (product_name, brand_id , category_id, model_year, list_price)
	VALUES('Santa Cruz Bronson', 10, 8 , 2025 , 4299.99 )

-- Q15: Copy all customers from California (state = 'CA') into a new table called sales.ca_customers_backup.
--      (Create the table first with the same structure as sales.customers)

		CREATE TABLE sales.customers_backup (
		customer_id INT IDENTITY(1,1) NOT NULL ,
		first_name VARCHAR(255) NOT NULL,
		last_name VARCHAR (255) NOT NULL,
		phone VARCHAR(25) NULL,
		email VARCHAR(255) NOT NULL,
		street VARCHAR(255) NULL,
		city VARCHAR(50) NULL,
		state VARCHAR(25) NULL ,
		zip_code VARCHAR(5) NULL
		);

		INSERT INTO sales.customers_backup (
		first_name, last_name, phone, email, street, city, state, zip_code
		)
		SELECT 
		first_name, last_name, phone, email, street, city, state, zip_code
		FROM sales.customers
		WHERE state = 'CA';


		

-- ================================================================================
-- SECTION D: UPDATE STATEMENTS
-- ================================================================================

-- Q16: Update the phone number of customer with customer_id = 10 to '(555) 123-4567'.

		UPDATE sales.customers
		SET phone = '(555) 123-4567'
		WHERE customer_id =10

-- Q17: Increase the list price of all products in the 'Road' category by 8%.
		
		UPDATE	production.products
		SET list_price = list_price * 1.08
		where category_id =  (
		select * from [production].[categories]
		where category_name = 'Road')

-- Q18: Mark all orders that have status = 4 (Completed) and shipped_date IS NULL 
--      to set shipped_date = order_date + 3 days.
		
		UPDATE [sales].[orders]
		SET   shipped_date = DATEADD(DAY, 3, order_date) 
		WHERE order_status = 4 AND shipped_date IS NULL

-- Q19: Set the manager_id of all staffs working at store_id = 1 to staff_id = 5 
--      (assume staff_id 5 is the manager of that store).

		
		Update	 [sales].[staffs]
		SET manager_id = 5
		Where store_id = 1
		AND staff_id <> 5 ;

-- Q20: Update the discount for order_items where order_id = 100 and item_id = 2 to 0.15 (15%).

		Update [sales].[order_items]
		set discount = 0.15
		where order_id = 100 and item_id = 2

-- ================================================================================
-- SECTION E: DELETE STATEMENTS
-- ================================================================================

-- Q21: Delete the brand 'Santa Cruz' you inserted in Q12.

			DELETE FROM [production].[brands]
			WHERE brand_name = 'Santa Cruz'

-- Q22: Delete all order_items that have quantity = 0.

			DELETE FROM [sales].[order_items]
			WHERE quantity = 0 ;

-- Q23: Delete all customers who have never placed an order (use subquery with NOT EXISTS).

			DELETE FROM sales.customers 
			WHERE NOT EXISTS (
				SELECT 1
				FROM sales.orders O
				WHERE O.customer_id = sales.customers.customer_id	
			);


-- Q24: Delete all products that have list_price > 10000 and model_year < 2020.

		DELETE FROM production.products
		WHERE list_price > 1000 AND model_year < 2020;

-- Q25: Delete the loyalty_programs table you created in Q6 (clean up).

		DROP TABLE sales.loyalty_programs;


-- ================================================================================
-- SECTION F: COMBINED & CHALLENGE QUESTIONS
-- ================================================================================

-- Q26: Write a single transaction that:
--      1. Creates a new store called 'Downtown LA'
--      2. Adds 3 new staff members to that store
--      3. Inserts 100 units of product_id = 1 into stocks for that store
--      (ROLLBACK if any step fails)

		INSERT INTO [sales].[stores](store_name)
		VALUES('Downtown LA');

		SELECT store_id,store_name FROM sales.stores;


		INSERT INTO sales.staffs ( first_name, last_name, email, phone, active, store_id,  manager_id)
		VALUES('Alice', 'Johnson', 'alice.johnson@bikestore.com', '213-555-1111', 1, 4, NULL),
			  ('Brian', 'Smith', 'brian.smith@bikestore.com', '213-555-2222', 1, 4, NULL),
			  ('Carla', 'Martinez', 'carla.martinez@bikestore.com', '213-555-3333', 1, 4, NULL);

	

-- Q27: Change the schema of sales.order_items: add a new column 'tax_amount' DECIMAL(8,2) DEFAULT 0.00,
--      then update it to be (list_price * quantity * discount * 0.08) for all existing rows.

		ALTER TABLE [sales].[order_items] 
		ADD tax_amount DECIMAL (8,2) DEFAULT 0.00;

		UPDATE [sales].[order_items] 
		SET tax_amount = list_price * quantity * discount * 0.08 ;

-- Q28: Identify and delete duplicate email addresses in sales.customers (keeping the smallest customer_id).

DELETE FROM sales.customers
WHERE EXISTS (
    SELECT 1
    FROM sales.customers x
    WHERE x.email = sales.customers.email
      AND x.customer_id < sales.customers.customer_id
);


		

-- Q29: Archive all orders from year 2020 or older: 
--      Insert them into a new table sales.orders_archive, then delete from sales.orders.

	CREATE TABLE sales.orders_archive
	(
	[order_id] [int]  NOT NULL,
	[customer_id] [int] NULL,
	[order_status] [tinyint] NOT NULL,
	[order_date] [date] NOT NULL,
	[required_date] [date] NOT NULL,
	[shipped_date] [date] NULL,
	[store_id] [int] NOT NULL,
	[staff_id] [int] NOT NULL,
	)

INSERT INTO [sales].[orders]
           (order_id, customer_id, order_status, order_date , required_date, shipped_date, store_id, staff_id)

SELECT 
       customer_id,
	   order_status,
	   order_date,
       required_date,
       shipped_date,
       store_id,
       staff_id
  FROM [sales].[orders] 
  WHERE YEAR(order_date) >= 2020;

  DELETE FROM sales.orders
  WHERE YEAR(order_date) <= 2020;




-- Q30: Add a CHECK constraint to production.products ensuring list_price >= 0 AND model_year BETWEEN 1900 AND YEAR(GETDATE())+1.

		ALTER TABLE production.products
		ADD CONSTRAINT CK_products_price_year
		CHECK (
		  list_price >= 0
		 AND model_year BETWEEN 1900 AND YEAR(GETDATE()) + 1
		);

		
		


-- ================================================================================
-- END OF HOMEWORK QUESTIONS
-- ================================================================================E