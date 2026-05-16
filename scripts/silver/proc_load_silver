/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.

	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_batch DATETIME, @end_batch DATETIME;

	BEGIN TRY
		
		SET @start_batch = GETDATE();
		PRINT '=================================================';
		PRINT 'Loading Silver Layer';
		PRINT '=================================================';

		PRINT '-------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-------------------------------------------------';

		/*
		======================================================================================
		TABLE 1: CRM_CUST_INFO
		======================================================================================
		*/
		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>>> Inserting Data Into: silver.crm_cust_info';
		PRINT '>>> Cleaning Data: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname, -- remove any unwanted spaces
			TRIM(cst_lastname) AS cst_lastname,
			CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' -- replace abbreviated terms with readable words (normalization)
				 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				 ELSE 'n/a'
			END cst_marital_status,
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' -- replace abbreviated terms with readable words (normalization)
				 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				 ELSE 'n/a'
			END _cst_gndr,
			cst_create_date
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last -- check if the data is the latest for the customer
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		)t WHERE flag_last = 1; -- get only the latest data for each customer (remove duplicates in PK column)
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------------------';
	

		/*
		======================================================================================
		TABLE 2: CRM_PRD_INFO
		======================================================================================
		*/
		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>>> Inserting Data Into: silver.crm_prd_info';
		PRINT '>>> Cleaning Data: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			/*
			derive product category id column from the product key (to link with product category table),
			and replace dash with underscore to match with the data in the product category table
				SUBSTRING(column, start index, end index)
				REPLACE(data, character to be replaced, character to replace it with)
			*/
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
			-- derive product key column (the second half part of the original prd_key column)
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost, -- replace all NULLS data with 0 (for aggregation)
			-- replace abbreviated terms with readable words (normalization)
			CASE UPPER(TRIM(prd_line))
				 WHEN 'M' THEN 'Mountain' 
				 WHEN 'R' THEN 'Road'
				 WHEN 'S' THEN 'Other Sales'
				 WHEN 'T' THEN 'Touring'
				 ELSE 'n/a'
			END AS prd_line,
			CAST (prd_start_dt AS DATE) AS prd_start_dt, -- data type casting (datetime to date)
			-- data enrichment: adding new, relevant data to enhance the dataset for analysis
			CAST(
				LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1
				AS DATE
			) AS prd_end_dt
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------------------';


		/*
		======================================================================================
		TABLE 3: CRM_SALES_DETAILS
		======================================================================================
		*/
		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>>> Inserting Data Into: silver.crm_sales_details';
		PRINT '>>> Cleaning Data: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			-- Handle the invalid order date and change the data type from int to date
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			-- Handle the invalid shipping date and change the data type from int to date
			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			-- Handle the invalid due date and change the data type from int to date
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,

			/*
			Rules:
			>>> If Sales is negative, zero, or null, derive it using Quantity and Price
			>>> If Price is zero or null, calculate it using Sales and Quantity
			>>> If Price is Negative, convert it to a positive value
			*/

			CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				 THEN sls_quantity * ABS(sls_price)
				 ELSE sls_sales
			END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
			sls_quantity,
			CASE WHEN sls_price IS NULL OR sls_price <= 0
				 THEN sls_sales / NULLIF(sls_quantity, 0)
				 ELSE sls_price
			END AS sls_price -- Derive price if original value is invalid
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------------------';

		PRINT '-------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-------------------------------------------------';

		/*
		======================================================================================
		TABLE 4: ERP_CUST_AZ12
		======================================================================================
		*/
		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>>> Inserting Data Into: silver.erp_cust_az12';
		PRINT '>>> Cleaning Data: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
			-- Remove the "NAS" at the beginning of some customer id (to make it the same as in crm_cust_info table)
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
			END AS cid,
			-- Replace the birthdate that are in the future with NULL
			CASE WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,
			-- Normalize gender values and handle unknown cases
			CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				 ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------------------';


		/*
		======================================================================================
		TABLE 5: ERP_LOC_A101
		======================================================================================
		*/
		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>>> Inserting Data Into: silver.erp_loc_a101';
		PRINT '>>> Cleaning Data: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT
			-- handled invalid values to make the data format the same as in crm_cust_info
			REPLACE (cid, '-', '') cid,
			-- normalize and handle missing or blank country codes
			CASE WHEN TRIM(cntry)= 'DE' THEN 'Germany'
				 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				 ELSE TRIM(cntry)
			END AS cntry
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------------------';


		/*
		======================================================================================
		TABLE 6: ERP_PX_CAT_G1V2
		======================================================================================
		*/
		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>>> Inserting Data Into: silver.erp_px_cat_g1v2';
		PRINT '>>> NO DATA CLEANING NEEDED';
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		-- no data cleaning needed; table is already clean and ready for next stage
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------------------------------------------';

		PRINT '';

		SET @end_batch = GETDATE();
		PRINT '=================================================';
		PRINT 'Loading Silver Layer is Completed!';
		PRINT '>> Total Load Duration: ' +  CAST(DATEDIFF(second, @start_batch, @end_batch) AS NVARCHAR) + ' seconds';
		PRINT '=================================================';
	END TRY

	BEGIN CATCH
		PRINT '=======================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=======================================';
	END CATCH

END
