/*
---------------------------------------------------------------------------------------------------
CUMULATIVE ANALYSIS
---------------------------------------------------------------------------------------------------
	Aggregate data progressively over time
	Helps understand whether business is growing/declining
---------------------------------------------------------------------------------------------------
*/

-- Calculate the total sales per month and the running total of sales over time
SELECT
	order_date,
	total_sales,
	-- window function to get total cumulative sales over time
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	-- Running total sales over time, restarting evcry year (partition by year)
	SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS partitioned_running_total_sales
	FROM
	(
		SELECT
			DATETRUNC(month, order_date) AS order_date,
			-- get total sales per month
			SUM(sales_amount) AS total_sales
		FROM gold.fact_sales
		WHERE order_date IS NOT NULL
		GROUP BY DATETRUNC(month, order_date)
	)t;

-- Calculate: total sales per year, the running total of sales over time, moving average price
SELECT
	order_date,
	total_sales,
	-- window function to get total cumulative sales over time
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	-- window function to get moving average of the price
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_avg_price
	FROM
	(
		SELECT
			DATETRUNC(year, order_date) AS order_date,
			-- get total sales per year
			SUM(sales_amount) AS total_sales,
			-- get average price per year
			AVG(sales_amount) AS avg_price
		FROM gold.fact_sales
		WHERE order_date IS NOT NULL
		GROUP BY DATETRUNC(year, order_date)
	)t;
