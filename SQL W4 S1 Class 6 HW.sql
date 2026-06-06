-- ============================================================
--  HOMEWORK: Indexes & Stored Procedures
--  Topic   : SQL Indexes + Stored Procedures
--  Level   : Beginner to Intermediate
-- ============================================================


-- ============================================================
--  PART A: INDEXES
-- ============================================================

-- Q1.
-- Write a query to create a non-clustered index on the
-- last_name column of sales.customers.
-- Then write a SELECT statement that would benefit from it.
-- Hint: Think about which queries filter by last name.

-- Your answer here:

CREATE INDEX indx_customername_last ON [sales].[customers](last_name);

select * from sales.customers
where last_name = 'Prince' ;



-- Q2.
-- Create a composite index on sales.orders using
-- customer_id and order_date.
-- Write a query that filters on both columns and benefits
-- from this index.
-- Hint: Composite indexes work best when you filter on both columns.

-- Your answer here:

CREATE INDEX indx_customer_order ON [sales].[orders] (customer_id, order_date);

select * from sales.orders
where customer_id = '80' and year(order_date) = '2018' ;

-- Q3.
-- A teammate suggests adding a unique index on
-- sales.customers(phone_number).
-- What could go wrong with this?
-- What assumption must be true for this to be safe?
-- Hint: Think about duplicate or missing (NULL) values.

-- Your answer here (write as a comment):

-- Adding a UNIQUE index on phone_number can cause problems if:
-- 1. Multiple customers share the same phone (e.g., family members, store landline).
-- 2. Phone numbers are missing (NULL). A UNIQUE index allows only one NULL, so more NULLs would fail.
-- 3. Formatting differences (like +92-300 vs 0300...) could look different but represent the same number.

-- The assumption that must be true for this to be safe:
-- → Every customer must always have a phone number, and each phone number must be unique to one customer.



-- Q4.
-- Look at the columns below from a sales.orders table.
-- Decide which columns SHOULD have an index and which should NOT.
-- Explain your reasoning for each as a comment.
--
--   order_id     (Primary Key)
--   status       (only 3 values: Pending, Shipped, Delivered)
--   customer_id  (Foreign Key)
--   notes        (free text, rarely searched)

-- Your answer here (write as a comment):

-- order_id (Primary Key)
-- Should have an index automatically because PRIMARY KEY creates a clustered index.
-- This ensures fast lookups by order_id and guarantees uniqueness.

-- status (only 3 values: Pending, Shipped, Delivered)
-- Should NOT have an index. With only 3 possible values, the column has very low selectivity.
-- Indexing here would not improve performance much, since queries would still scan many rows.

-- customer_id (Foreign Key)
-- Should have an index. Foreign keys are often used in JOINs (e.g., joining orders to customers).
-- Indexing speeds up lookups and improves referential integrity checks.

-- notes (free text, rarely searched)
-- Should NOT have an index. Free text fields are large and rarely filtered in queries.
-- Indexing would waste space and slow down inserts/updates without real benefit.



-- Q5.
-- Write the command to check existing indexes on production.products.
-- Then describe (as a comment) what the output columns tell you.
-- Hint: Use sp_helpindex.

-- Your answer here:

EXEC sp_helpindex '[production].[products]';


-- Output shows:
-- 1. Index name (system or user defined)
-- 2. Index description (clustered/non‑clustered, unique, primary key, etc.)
-- 3. Indexed columns (which columns are covered)



-- ============================================================
--  PART B: STORED PROCEDURES
-- ============================================================

-- Q6.
-- Create a stored procedure called sp_GetCustomerOrders
-- that accepts a @CustomerID parameter and returns all orders
-- for that customer showing: order_id, order_date, order_status.
-- Test it using EXEC after you create it.

-- Your answer here:

CREATE PROCEDURE sp_GetCustomerOrders
		@CustomerID INT

AS 
BEGIN

		SELECT  order_id,
				order_date,
				order_status 
		FROM sales.orders
		WHERE customer_id = @CustomerID;

END;

EXEC sp_GetCustomerOrders @CustomerID = 5;



-- Q7.
-- Modify sp_GetCustomerOrders from Q6 so that if no orders
-- are found for the given customer, it returns the message:
-- 'No orders found for this customer'
-- Hint: Use IF EXISTS or check @@ROWCOUNT.

-- Your answer here:

ALTER PROCEDURE sp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT 
        order_id,
        order_date,
        order_status
    FROM sales.orders 
    WHERE customer_id = @CustomerID;

    IF @@ROWCOUNT = 0
        PRINT 'No orders found for this customer';
END;
GO

EXEC sp_GetCustomerOrders @CustomerID = 111; 




-- Q8.
-- Create a stored procedure sp_ProductsByCategory that accepts:
--   @CategoryID  INT
--   @MaxPrice    DECIMAL(10,2)  with a default value of 9999
-- It should return all matching products ordered by price (low to high).
-- Hint: Use a default parameter value like you saw with @threshold.

-- Your answer here:

		
CREATE PROCEDURE sp_ProductsByCategory
    @CategoryID INT,
    @MaxPrice DECIMAL(10,2) = 9999   
AS
BEGIN
    SELECT 
        p.product_id,
        p.product_name,
        p.list_price,
        p.category_id
    FROM production.products p
    WHERE p.category_id = @CategoryID
      AND p.list_price <= @MaxPrice
    ORDER BY p.list_price ASC;   
END;
GO


EXEC sp_ProductsByCategory @CategoryID = 3;              
EXEC sp_ProductsByCategory @CategoryID = 3, @MaxPrice=500; 




-- ============================================================
--  PART C: MIXED / THINK QUESTIONS
-- ============================================================

-- Q9.
-- You have a sales.orders table with 2 million rows.
-- A stored procedure filters by store_id and order_date.
-- It runs very slowly.
-- What TWO things would you do to fix it, and why?
-- Hint: Think about both indexes and procedure logic.

-- Your answer here (write as a comment):

-- Two fixes:
-- 1. Create a composite non‑clustered index on (store_id, order_date).
--    This speeds up filtering because SQL Server can quickly locate rows
--    matching both conditions instead of scanning 2 million rows.
--
-- 2. Review the stored procedure logic:
--    • Select only needed columns (avoid SELECT *).
--    • Use sargable conditions (e.g., store_id = @id AND order_date >= @date).
--    This reduces I/O and makes the query optimizer use the index efficiently.



-- Q10.
-- A junior developer creates indexes on EVERY column of a table
-- to "make everything faster".
-- Write a short explanation (3-5 sentences) of why this is
-- actually a bad idea.
-- Hint: Think about how INSERT, UPDATE, and DELETE are affected.

-- Your answer here (write as a comment):


-- Indexing every column is a bad idea because:
-- 1. Each INSERT, UPDATE, or DELETE must also update all indexes, slowing performance.
-- 2. Indexes take extra storage space and add overhead.
-- 3. Many columns (like low‑selectivity or rarely queried ones) don’t benefit from indexing.
-- Good practice is to index only columns frequently used in WHERE, JOIN, or ORDER BY.



-- ============================================================
--  END OF HOMEWORK
-- ============================================================