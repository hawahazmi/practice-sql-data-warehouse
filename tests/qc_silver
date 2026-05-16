/*
DATA EXPLORATION FOR CHECKING QUALITY ISSUES

bronze layer -> raw data
silver layer -> cleaned, transformed data
*/

/*
======================================================================================
TABLE 1: CRM_CUST_INFO
======================================================================================
*/

-- 1. Check for Nulls or Duplicates in Primary Key (Expectation: No Nulls/Duplicates)
SELECT
	cst_id,
	COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- 2. Check for unwanted spaces in string values (Expectation: No Results)
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname); -- TRIM function will remove any leading and trailing spaces

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

SELECT cst_key
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key);


-- 3. Check the consistency of values in low cardinality columns (Data Standardization & Consistency)
-- In data warehouse, we aim to store clear and meaningful values rather than using abbreviated terms (F/M for gender)
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;

SELECT * FROM bronze.crm_cust_info;

/*
======================================================================================
TABLE 2: CRM_PRD_INFO
======================================================================================
*/

-- 1. Check for Nulls or Duplicates in Primary Key (Expectation: No Nulls/Duplicates)
SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- 2. Check for unwanted spaces in string values (Expectation: No Results)
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm); -- TRIM function will remove any leading and trailing spaces

-- 3. Check for NULLS or negative numbers (Expectation: No Results)
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- 4. Check the consistency of values in low cardinality columns (Data Standardization & Consistency)
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- 5. Check for Invalid Date Orders
-- end date is earlier than start date (solution: replace the end date with the start date of the 'NEXT' record - 1)
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

SELECT * FROM silver.crm_prd_info;

/*
======================================================================================
TABLE 3: CRM_SALES_DETAILS
======================================================================================
*/

SELECT * FROM bronze.crm_sales_details;

-- 1. Check for unwanted spaces
SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- 2. Check data integrity of the PK (make sure data is in the related tables)
SELECT sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM bronze.crm_prd_info);

SELECT sls_cust_id
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM bronze.crm_cust_info);

-- 3. Check for invalid dates
SELECT NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE 
	sls_order_dt <= 0
	OR
	-- Length of int that represents date must be 8 (4 for year, 2 for month, 2 for days)
	LEN(sls_order_dt) != 8
	OR
	-- Check for date boundaries (date must be after company creation, and does not pass a certain date)
	sls_order_dt > 20500101
	OR
	sls_order_dt < 19000101;

SELECT NULLIF(sls_ship_dt, 0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE 
	sls_ship_dt <= 0
	OR
	LEN(sls_ship_dt) != 8
	OR
	sls_ship_dt > 20500101
	OR
	sls_ship_dt < 19000101;

SELECT NULLIF(sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details
WHERE 
	sls_due_dt <= 0
	OR
	LEN(sls_due_dt) != 8
	OR
	sls_due_dt > 20500101
	OR
	sls_due_dt < 19000101;

SELECT *
FROM bronze.crm_sales_details
-- Check if order date is higher than the ship date or due date
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

/* 4. Check data consistency between Sales, Quantity, and Price
		Sales = Quantity * Price
		Values must not be NULL, zero, or negative

		Solution #1: Communicate with the system owner, and the data issues will be fixed direct in source system
		Solution #2: Data issues have to be fixed in the data warehouse (supported by the source expert)
*/

SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE 
	sls_sales != sls_quantity * sls_price
	OR
	sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	or
	sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

/*
======================================================================================
TABLE 4: ERP_CUST_AZ12
======================================================================================
*/

-- 1. Check if cid is the same as cust_key in crm_cust_info (for table relations)
SELECT
	cid
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%';

SELECT * FROM silver.crm_cust_info;

-- 2. Identify out-of-range dates
SELECT DISTINCT bdate
FROM bronze.erp_cust_az12
-- customer max age is 100, and the birthdate cannot be in the future
WHERE bdate < '1926-01-01' OR bdate > GETDATE();

-- 3. Data Standardization & Consistency
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;


/*
======================================================================================
TABLE 5: ERP_LOC_A101
======================================================================================
*/

-- 1. Check if cid in erp_loc_a101 is the same as in crm_cust_info (for table relations)
SELECT
	cid,
	cntry
FROM bronze.erp_loc_a101;

SELECT cst_key FROM silver.crm_cust_info;

-- 2. Data Standardization & Consistency
SELECT DISTINCT
	cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;


/*
======================================================================================
TABLE 6: ERP_PX_CAT_G1V2
======================================================================================
*/

SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;

-- 1. Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- 2. Standardization
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;

