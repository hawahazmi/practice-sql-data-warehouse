/*
------------------------------------------------------------------------------------
DIMENSIONS EXPLORATION
------------------------------------------------------------------------------------
	Identify the unique values (or categories) in each dimension
		>> SELECT DISTINCT
	Recognize how data might be grouped or segmented (useful for later analysis)
*/

-- Explore all countries our customers come from
SELECT DISTINCT country
FROM gold.dim_customers;

-- Explore all product categories
SELECT DISTINCT
	category,
	subcategory,
	product_name
FROM gold.dim_products
ORDER BY 1, 2, 3;
