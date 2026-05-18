/*
---------------------------------------------------------------------------------------------------
PART-TO-WHOLE ANALYSIS
---------------------------------------------------------------------------------------------------
	Proportional Analysis
		Analyze how an individual part is performing compared to the overall
	Allow us to understand which category has the greatest impact on the business
---------------------------------------------------------------------------------------------------
*/

-- Which categories contribute the most to the overall sales?

-- CTE to get the proportions
WITH category_sales AS (
	SELECT
		category,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY category
)
SELECT
	category,
	total_sales,
	-- window function to get total sales of the whole dataset
	SUM(total_sales) OVER () overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS perc_of_total
FROM category_sales
ORDER BY total_Sales DESC;
