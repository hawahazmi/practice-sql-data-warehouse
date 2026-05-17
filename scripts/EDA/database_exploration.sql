/*
------------------------------------------------------------------------------------
DATABASE EXPLORATION
------------------------------------------------------------------------------------
	Understand all of the tables/views that exist in the database
	Understand all columns of the tables/views in the database
*/

-- Explore all objects in the database
SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- Explore all columns in the database
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
