/*
------------------------------------------------------------------------------------
MEASURES EXPLORATION
------------------------------------------------------------------------------------
	Calculate key metric of the business
*/


SELECT
	-- Find the total sales
	SUM(sales_amount) AS total_sales,

	-- Find how many items are sold
	SUM(quantity) AS total_quantity,

	-- Find the average of selling price
	AVG(price) AS average_price,

	-- Find the total number of orders (Use DISTINCT to make sure each order is only counted once
	COUNT(DISTINCT order_number) AS total_orders

	-- Find the total number of customers that has placed an order (Use distinct to make sure each customer are only counted once)
	COUNT(DISTINCT customer_key) AS total_customers

FROM gold.fact_sales;

-- Find the total number of products
SELECT COUNT(product_key) AS total_products FROM gold.dim_products;

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;

-- Generate report that shows all key metrics of the business
SELECT
	'Total Sales' as measure_name,
	SUM(sales_amount) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT
	'Total Quantity',
	SUM(quantity)
FROM gold.fact_sales
UNION ALL
SELECT
	'Average Price',
	AVG(price)
FROM gold.fact_sales
UNION ALL
SELECT
	'Total Orders',
	COUNT(DISTINCT order_number)
FROM gold.fact_sales
UNION ALL
SELECT
	'Total Products',
	COUNT(product_key)
FROM gold.dim_products
UNION ALL
SELECT
	'Total Customers',
	COUNT(customer_key)
FROM gold.dim_customers;
