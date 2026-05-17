/*
------------------------------------------------------------------------------------
DATES EXPLORATION
------------------------------------------------------------------------------------
	Identify the earliest and latest dates (boundaries)
	Understand the scope of data and the timespan
		>> MIN/MAX [Date Dimension]
*/

-- Find the date of the first and last order
-- How many years of sales are available
SELECT
	MIN(order_date) first_order_date,
	MAX(order_date) last_order_date,
	DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;


-- Find the youngest and oldest customer
SELECT
	MIN(birthdate) oldest_customer,
	DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
	MAX(birthdate) youngest_customer,
	DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;
