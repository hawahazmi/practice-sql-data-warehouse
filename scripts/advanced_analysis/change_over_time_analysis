/*
---------------------------------------------------------------------------------------------------
CHANGE-OVER-TIME ANALYSIS
---------------------------------------------------------------------------------------------------
	Analyze how a measure evolves over time
	Helps track trends and identify seasonality in your data

	Example:
		1. Total sales by year
		2. Average cost by year
		3. Total customers by year
---------------------------------------------------------------------------------------------------
*/

-- Sales performance over time (year)
SELECT
	YEAR(order_date) AS order_year,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

-- Sales performance over time (month)
SELECT
	DATETRUNC(month, order_date) as order_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- Sales performance over time
-- (Format Date in desired style -> will return month in string, so cannot be sorted properly)
SELECT
	FORMAT(order_date, 'yyyy-MMM') as order_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM')
