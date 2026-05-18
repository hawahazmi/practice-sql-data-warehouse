/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

-- Check if view already exists
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

-- Create view for product report
CREATE VIEW gold.report_products AS

WITH base_query AS (
/*
----------------------------------
BASE QUERY (GET COLUMNS NEEDED)
----------------------------------
*/
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

product_aggregation AS (
    /*
    Aggregates product-level metrics:
           - total orders
           - total sales
           - total quantity sold
           - total customers (unique)
           - lifespan (in months)
    */
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        -- total orders
        COUNT(DISTINCT order_number) AS total_orders,
        -- total sales
        SUM(sales_amount) AS total_sales,
        -- total quantity sold
        SUM(quantity) AS total_qty_sold,
        -- total customers (unique)
        COUNT(DISTINCT customer_key) AS total_customers,
        -- lifespan (oldest order until newest order)
        MAX(order_date) AS last_order,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        -- average selling price
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)
/*
FINAL QUERY:
Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    total_sales,

    -- revenue segmentation
    CASE WHEN total_sales < 10000 THEN 'Low-Performer'
         WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid-Range'
         ELSE 'High-Performer'
    END AS revenue_group,

    total_orders,
    -- calculate average order revenue
    CASE WHEN total_orders = 0 THEN 0
         ELSE total_sales / total_orders
    END AS avg_order_revenue,

    total_qty_sold,
    total_customers
    avg_selling_price,

    -- calculate average monthly revenue
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE total_sales / lifespan
    END AS avg_monthly_revenue,

    last_order,
    lifespan,
    -- calculate recency (months since last order)
    DATEDIFF(MONTH, last_order, GETDATE())  AS recency_months

FROM product_aggregation;
