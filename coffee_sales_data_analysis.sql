-- Data Analysis

SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;


-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT
	city_name,
	ROUND((population * 0.25)/1000000,2) AS consumers_mln,
	city_rank
FROM city
ORDER BY 2 DESC;



-- What is the total revenue across all cities in Q4 of 2023?
SELECT 
	SUM(total) AS total_revenue
FROM sales
WHERE 
	EXTRACT(YEAR from sales_date) = 2023
	AND
	EXTRACT(QUARTER from sales_date) = 4


SELECT
	cty.city_name,
	SUM(s.total) AS total_revenue
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as cty
ON cty.city_id = c.city_id
WHERE 
	EXTRACT(YEAR from s.sales_date) = 2023
	AND
	EXTRACT(QUARTER from s.sales_date) = 4
GROUP BY 1
ORDER BY 2 DESC;






-- How many units of each product have been sold?

SELECT 
	p.product_name,
	COUNT(s.sales_id) AS total_orders
FROM products AS p
JOIN sales as s
ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC;


SELECT * FROM sales;







-- What is the average sales amount per customer of each city?

SELECT
	cty.city_name,
	SUM(s.total) AS total_revenue,
	COUNT(DISTINCT c.customer_id) AS total_customer,
	ROUND(SUM(s.total)::NUMERIC/COUNT(DISTINCT c.customer_id)::NUMERIC,2) AS avg_sales_per_customer
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as cty
ON cty.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;








-- List the cities and their population, along with the estimated coffee consumers being 25% of each city's population

-- SELECT * FROM city;


WITH city_table AS (
	SELECT 
		city_name,
		ROUND(population*0.25/1000000,2) million_coffee_consumers
	FROM city
),
customers_table AS(
	SELECT 
		cty.city_name,
		COUNT(DISTINCT c.customer_id) AS customer_count
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as cty
	ON cty.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
)
SELECT 
	cty_tab.city_name,
	cty_tab.million_coffee_consumers,
	cust_tab.customer_count
FROM city_table AS cty_tab
JOIN customers_table AS cust_tab
ON cust_tab.city_name = cty_tab.city_name;








-- What are the top 3 selling products in each city?


SELECT *
FROM(
	SELECT 
		cty.city_name,
		p.product_name,
		COUNT(s.sales_id) AS total_orders,
		DENSE_RANK() OVER(PARTITION BY cty.city_name ORDER BY COUNT(s.sales_id) DESC) AS rank
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as cty
	ON cty.city_id = c.city_id
	GROUP BY 1,2
	-- ORDER BY 1,3 DESC;
) AS t1
WHERE rank <=3;







-- How many unique customers are there in each city?
SELECT 
	cty.city_name,
	COUNT(DISTINCT c.customer_id) AS customer_count
FROM city as cty
JOIN customers as c
ON c.city_id = cty.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id IN(1,2,3,4,5,6,7,8,9,10,11,12,13,14)
GROUP BY 1;






-- Find each city's average sales per customer and average rent per customer

WITH city_table AS(
	SELECT
		cty.city_name,
		COUNT(DISTINCT s.customer_id) AS total_customer,
		ROUND(SUM(s.total)::NUMERIC/COUNT(DISTINCT s.customer_id)::NUMERIC,2) AS avg_sales_per_customer
	FROM sales AS s
	JOIN customers AS c
	ON s.customer_id = c.customer_id
	JOIN city AS cty
	ON cty.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS (
	SELECT 
		city_name,
		estimated_rent
	FROM city
)
SELECT
	cty_rnt.city_name,
	cty_rnt.estimated_rent,
	cty_tab.total_customer,
	cty_tab.avg_sales_per_customer,
	ROUND(cty_rnt.estimated_rent::NUMERIC/cty_tab.total_customer::NUMERIC,2) AS avg_rent_per_customer
FROM city_rent AS cty_rnt
JOIN city_table AS cty_tab
ON cty_rnt.city_name = cty_tab.city_name
ORDER BY 4 DESC;
	





-- Calculate the percentage changes in monthly sales 


WITH monthly_sales AS (
	SELECT 
		cty.city_name,
		EXTRACT(MONTH FROM sales_date) AS month,
		EXTRACT(YEAR FROM sales_date) AS year,
		SUM(s.total) AS total_sales
	FROM sales AS s
	JOIN customers AS c
	ON c.customer_id = s.customer_id
	JOIN city AS cty
	ON cty.city_id = c.city_id
	GROUP BY 1,2,3
	ORDER BY 1,3,2
),
percentage_change_rate AS (
	SELECT
		city_name,
		month,
		year,
		total_sales as current_month_sales,
		LAG(total_sales, 1) OVER(PARTITION BY city_name ORDER BY 3,2) AS previous_month_sales
	FROM monthly_sales
)
SELECT
	city_name,
	month,
	year,
	current_month_sales,
	previous_month_sales,
	ROUND((current_month_sales - previous_month_sales)::NUMERIC/previous_month_sales::NUMERIC*100,2) AS percentage_change_rate
FROM percentage_change_rate
WHERE previous_month_sales IS NOT NULL;





-- Identify the top 3 cities ranked by highest sales


WITH city_table AS(
	SELECT
		cty.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT s.customer_id) AS total_customer,
		ROUND(SUM(s.total)::NUMERIC/COUNT(DISTINCT s.customer_id)::NUMERIC,2) AS avg_sales_per_customer
	FROM sales AS s
	JOIN customers AS c
	ON s.customer_id = c.customer_id
	JOIN city AS cty
	ON cty.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS (
	SELECT 
		city_name,
		estimated_rent,
		ROUND((population * 0.25)/1000000,4) AS million_coffee_consumer
	FROM city
)
SELECT
	cty_rnt.city_name,
	total_revenue,
	cty_rnt.estimated_rent AS total_rent,
	cty_tab.total_customer,
	million_coffee_consumer,
	cty_tab.avg_sales_per_customer,
	ROUND(cty_rnt.estimated_rent::NUMERIC/cty_tab.total_customer::NUMERIC,2) AS avg_rent_per_customer
FROM city_rent AS cty_rnt
JOIN city_table AS cty_tab
ON cty_rnt.city_name = cty_tab.city_name
ORDER BY 2 DESC;




/*
--------------------------------
-- CONCLUSION & RECOMMENDATION
--------------------------------

Based on the analysis, the top 3 cities that are worthy of business investment:

1. Pune: High avg sales/customers, Highest total revenue, Low rent/customer
2. Delhi: Highest number of coffee consumers, Highest total number of customers, Low rent/customer
3. Jaipur: Highest total number of customers, Low rent/customer, High sales/customer


*/
