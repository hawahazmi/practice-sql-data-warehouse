/*
---------------------------------------------------------------------------------------------------
PERFORMANCE ANALYSIS
---------------------------------------------------------------------------------------------------
	Compare the current value to a target value (KPI)
	Helps measure success and compare performance
---------------------------------------------------------------------------------------------------
*/

-- Analyze the yearly performance of products by
-- comparing each product's sales to both its average sales performance and the prev year's sales
WITH yearly_product_sales AS ( -- CTE
	-- get total sales for the year
	SELECT
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL
	GROUP BY
		YEAR(f.order_date),
		p.product_name
)
SELECT
	order_year,
	product_name,
	current_sales,
	-- get average sales
	AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
	-- get difference of average sales and current sales (to compare)
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
	-- categorize the performance of the sales (above avg/below avg/avg)
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		 ELSE 'Avg'
	END AS avg_change,
	-- YEAR-OVER-YEAR ANALYSIS
	-- Get the previous value of the current sales
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) previous_sales,
	-- get the different between current year and previous year sales
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) AS diff_prev,
	-- categorize the performance of the previous year difference (increase/decrease/no change)
	CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) < 0 THEN 'Decrease'
		 ELSE 'No Change'
	END AS prev_change
FROM yearly_product_sales
ORDER BY product_name, order_year;

-- Change the above code for monthly analysis
WITH monthly_product_sales AS (
	-- get total sales for the month
	SELECT
		MONTH(f.order_date) AS order_month,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL
	GROUP BY
		MONTH(f.order_date),
		p.product_name
)
SELECT
	order_month,
	product_name,
	current_sales,
	-- get average sales
	AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
	-- get difference of average sales and current sales (to compare)
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
	-- categorize the performance of the sales (above avg/below avg/avg)
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		 ELSE 'Avg'
	END AS avg_change,
	-- MONTH-OVER-MONTH ANALYSIS
	-- Get the previous value of the current sales
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month ASC) previous_sales,
	-- get the different between current year and previous year sales
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month ASC) AS diff_prev,
	-- categorize the performance of the previous year difference (increase/decrease/no change)
	CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month ASC) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month ASC) < 0 THEN 'Decrease'
		 ELSE 'No Change'
	END AS prev_change
FROM monthly_product_sales
ORDER BY product_name, order_month
