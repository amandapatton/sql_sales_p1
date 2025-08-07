CREATE TABLE IF NOT EXISTS sql_sales_project1.sales
      (
        transactions_id INT64,
        sale_date DATE,
        sale_time TIME,
        customer_id INT64,
        gender STRING,
        age INT64,
        category STRING,
        quantiy INT64,
        price_per_unit FLOAT64,
        cogs FLOAT64,
        total_sale FLOAT64,
        PRIMARY KEY (transactions_id) NOT ENFORCED)

-- DATA CLEANING --

SELECT *
FROM `sql_sales_project1.sales1`
LIMIT 10

-- Verify count of rows & cross-check with Excel / Google Sheets
SELECT COUNT(*)
FROM `sql_sales_project1.sales1`

-- Check columns for null values
SELECT *
FROM `sql_sales_project1.sales1`
WHERE transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantiy IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL


-- Delete rows with null values
DELETE
FROM `sql_sales_project1.sales1`
WHERE transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantiy IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL

-- Fix misspelled column name from "quantiy" to "quantity"
ALTER TABLE `sql_sales_project1.sales1`
RENAME COLUMN quantiy TO quantity

-- DATA EXPLORATION --

-- How many total transactions in 2023?
SELECT COUNT(transactions_id) AS total_sales_2023
FROM `sql_sales_project1.sales1`
WHERE EXTRACT(YEAR FROM sale_date) = 2023

-- How many unique customers in 2023?
SELECT COUNT(DISTINCT customer_id) AS unique_customers_2023
FROM `sql_sales_project1.sales1`
WHERE EXTRACT(YEAR FROM sale_date) = 2023


-- DATA ANALYSIS & SOLVING BUSINESS QUESTIONS --

-- Q1:  How many transactions per category in 2023?
SELECT COUNT(transactions_id) as total_sales_2023,
  category
FROM `sql_sales_project1.sales1`
WHERE EXTRACT(YEAR FROM sale_date) = 2023
GROUP BY category
ORDER BY COUNT(transactions_id) DESC

-- Q2:  List all transactions for Clothing sales in November 2023 from highest to lowest sale price.
SELECT *
FROM `sql_sales_project1.sales1`
WHERE EXTRACT(YEAR FROM sale_date) = 2023
  AND EXTRACT(MONTH FROM sale_date) = 11
  AND category = 'Clothing'
ORDER BY total_sale DESC

-- Q3:  Show total sales for each category. Display as USD without decimals.
SELECT CONCAT('$',FORMAT("%'d",SUM(total_sale))) AS gross_sales,
  category
FROM `sql_sales_project1.sales1`
GROUP BY category
ORDER BY SUM(total_sale) DESC

-- Q4: Find the average age of customers who purchased items from the Beauty category.
SELECT ROUND(AVG(age),0) as average_age
FROM `sql_sales_project1.sales1`
WHERE category = 'Beauty'

-- Q5: List the transactions for the top 10 sales by sale amount. Sort by descending transaction amount.
SELECT *
FROM `sql_sales_project1.sales1`
ORDER BY total_sale DESC
LIMIT 10

-- Q6:  Show average sale as USD by age group, and total number of transactions. Age groups are as follows:  <= 19 = Adolescents, 20-39 = Early Adult, 40-59 = Middle Adult, >60 = Senior Adult, all other ages = Other
SELECT 
  CASE
    WHEN age <= 19 THEN 'Adolescents'
    WHEN age >= 20 AND age <= 39 THEN 'Early Adult'
    WHEN age >= 40 AND age <= 59 THEN 'Middle Adult'
    WHEN age >= 60 THEN 'Senior Adult'
    ELSE 'Other'
    END AS age_group,
  CONCAT('$',ROUND(AVG(total_sale),0)) AS average_sale,
  COUNT(transactions_id) AS transaction_count
FROM `sql_sales_project1.sales1`
GROUP BY age_group
ORDER BY average_sale DESC

-- Q6.1:  Explore data for customers in "Other" age group.
-- Findings:  Line 116 (previous query) should have been >= 60. There was a single customer, aged 60 years old, being grouped in the "Other" age group.
SELECT age,
  CASE
    WHEN age <= 19 THEN 'Adolescents'
    WHEN age >= 20 AND age <= 39 THEN 'Early Adult'
    WHEN age >= 40 AND age <= 59 THEN 'Middle Adult'
    WHEN age > 60 THEN 'Senior Adult'
    ELSE 'Other'
    END AS age_group,
  CONCAT('$',ROUND(AVG(total_sale),0)) AS average_sale
FROM `sql_sales_project1.sales1`
GROUP BY age_group, age
HAVING age_group = 'Other'
--ORDER BY average_sale DESC

-- Q7:  List the total number of transactions per gender in each category.
SELECT
  category,
  gender,
  COUNT(transactions_id) as transaction_count,
FROM `sql_sales_project1.sales1`
GROUP BY category, gender
ORDER BY category, gender

-- Q8. Calculate the average sale for each month. Find the best selling month in each year.
SELECT *
FROM
  (SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    CONCAT('$',ROUND(AVG(total_sale),0)) AS avg_sales,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY CONCAT('$',ROUND(AVG(total_sale),0)) DESC) AS rank
FROM `sql_sales_project1.sales1`
GROUP BY sale_date)
AS ranked_sales
WHERE rank = 1


-- Q9:  Find the top 5 customers based on the highest total sales
SELECT
  customer_id,
  CONCAT('$',FORMAT("%'d",SUM(total_sale))) AS total_sales
FROM `sql_sales_project1.sales1`
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC
LIMIT 5


-- Q10:  Show net profit by category as USD in descending order.
-- Calculate net_profit as total_sale - cogs
-- Display net_profit as USD with comma for readability
SELECT 
  category,
  CONCAT('$',FORMAT("%'d",SUM(total_sale - CAST(cogs AS INT64)))) AS net_profit
FROM `sql_sales_project1.sales1`
GROUP BY 1
ORDER BY total_profit DESC

-- Q10.1:  Show net profit by category, by year as USD in descending order.
-- Create CTEs for years 2022 & 2023
WITH cte_2022 AS (
SELECT 
  category,
  SUM(total_sale - CAST(cogs AS INT64)) AS profit
FROM `sql_sales_project1.sales1`
WHERE EXTRACT(YEAR FROM sale_date) = 2022
GROUP BY category),

cte_2023 AS (
SELECT 
  category,
  SUM(total_sale - CAST(cogs AS INT64)) AS profit
FROM `sql_sales_project1.sales1`
WHERE EXTRACT(YEAR FROM sale_date) = 2023
GROUP BY category)

  SELECT
    category,
    '2022' AS year,
    CONCAT('$', FORMAT("%'d",profit)) AS net_profit
  FROM cte_2022

UNION ALL

  SELECT
    category,
    '2023' AS year,
    CONCAT('$', FORMAT("%'d",profit)) AS net_profit
  FROM cte_2023

ORDER BY category, year


-- END OF PROJECT -- 