-- CREATE DATABASE
CREATE DATABASE sales_data;

-- CHECK ALL EXISTING DATABASES
SELECT datname FROM pg_database;

-- CREATE TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales(
	transaction_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(15),
	age INT,
	category VARCHAR(15),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
)

SELECT * FROM retail_sales;

DROP TABLE retail_sales;


COPY retail_sales
FROM '/data/retail-sales-2022.csv' 
DELIMITER ',' 
CSV HEADER;


SELECT * FROM retail_sales;


SELECT * FROM retail_sales LIMIT 10;



SELECT COUNT(*) FROM retail_sales;


SELECT * FROM retail_sales
WHERE transaction_id IS NULL;


SELECT * FROM retail_sales
WHERE sale_date IS NULL;

SELECT * FROM retail_sales
WHERE transaction_id IS NULL
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL
OR age IS NULL
OR category IS NULL
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL;


DELETE FROM retail_sales
WHERE transaction_id IS NULL
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL
-- OR age IS NULL
OR category IS NULL
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL;


WITH average_age AS (
    SELECT AVG(age) as mean_age 
    FROM retail_sales
)
UPDATE retail_sales
SET age = average_age.mean_age
FROM average_age
WHERE age IS NULL;


-- EDA


-- Total Number of Sales
SELECT COUNT(*) FROM retail_sales;


-- How many unique customers are there?
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;


-- How ma