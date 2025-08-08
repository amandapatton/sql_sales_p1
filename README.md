# SQL Project 1 - Sales Analysis

This project showcases my SQL skills by analyzing a synthetic retail sales dataset in **Google BigQuery**. The dataset simulates e-commerce sales from 2022 and 2023 and includes detailed transaction data such as customer demographics, product categories, sale amounts, and cost of goods sold (COGS).

The project includes **data cleaning**, **exploratory analysis**, and **business question-solving**, with a focus on **profitability**, **customer segmentation**, and **year-over-year trends**.

---

## 🎯 Skills Demonstrated

- Data cleaning with `DELETE`, `ALTER TABLE`, and `RENAME COLUMN`
- Aggregation with `SUM`, `COUNT`, `AVG`, and `GROUP BY`
- Conditional logic using `CASE WHEN`
- Window functions like `RANK()`
- String formatting for business-friendly outputs using `FORMAT`, `CONCAT`, and `CAST`
- CTEs for modular, readable queries

---

## 📊 Dataset Overview

- **Table name**: `sql_sales_project1.sales1`
- **Timeframe**: 2022–2023
- **Columns**:
  - `transactions_id`: Transaction unique ID
  - `sale_date` / `sale_time`: Timestamp of sale
  - `customer_id`, `gender`, `age`: Customer information
  - `category`: Product category
  - `quantity`, `price_per_unit`, `cogs`, `total_sale`: Sales metrics
 
---
## Schema
```
    CREATE TABLE IF NOT EXISTS sql_sales_project1.sales1
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
```
### Note:  Column "quantiy" is misspelled. This is addressed as a data cleaning step below.

---

## 🧹 Data Cleaning Steps

- Checked for and removed rows with `NULL` values
- Fixed a misspelled column (`quantiy` → `quantity`)
  ```
    ALTER TABLE `sql_sales_project1.sales1`
    RENAME COLUMN quantiy TO quantity
  ```
- Verified row count and schema integrity

---

## 🔍 Questions Answered

1. **How many transactions per category in 2023?**
```
SELECT COUNT(transactions_id) AS total_sales_2023
FROM `sql_sales_project1.sales1`
WHERE EXTRACT(YEAR FROM sale_date) = 2023
```
<img width="389" height="122" alt="Screenshot 2025-08-07 at 7 43 01 PM" src="https://github.com/user-attachments/assets/cbbcf83c-a1a4-4dfa-8f92-bb2779cde0bc" />


2. **List all transactions for Clothing sales in November 2023 from highest to lowest sale price.**
```
SELECT *
FROM `sql_sales_project1.sales1`
WHERE EXTRACT(YEAR FROM sale_date) = 2023
  AND EXTRACT(MONTH FROM sale_date) = 11
  AND category = 'Clothing'
ORDER BY total_sale DESC
```
<img width="1412" height="322" alt="Screenshot 2025-08-07 at 8 29 59 PM" src="https://github.com/user-attachments/assets/9a1aacbf-b2f9-4b76-83c3-0277be0d4e5e" />



3. **Show total sales for each category. Display as USD without decimals.**
```
SELECT CONCAT('$',FORMAT("%'d",SUM(total_sale))) AS gross_sales,
  category
FROM `sql_sales_project1.sales1`
GROUP BY category
ORDER BY SUM(total_sale) DESC
```
<img width="468" height="118" alt="Screenshot 2025-08-07 at 7 45 34 PM" src="https://github.com/user-attachments/assets/241eb275-0733-46f3-ab24-18da9747bd7f" />


4. **Find the average age of customers who purchased items from the Beauty category.**
```
SELECT ROUND(AVG(age),0) as average_age
FROM `sql_sales_project1.sales1`
WHERE category = 'Beauty'
```
<img width="212" height="69" alt="Screenshot 2025-08-07 at 7 46 24 PM" src="https://github.com/user-attachments/assets/f23ba462-4cfd-4b07-b1bf-9e938f9daa14" />


5. **List the transactions for the top 10 sales by sale amount. Sort by descending transaction amount.**
```
SELECT *
FROM `sql_sales_project1.sales1`
ORDER BY total_sale DESC
LIMIT 10
```
<img width="1491" height="306" alt="Screenshot 2025-08-07 at 7 47 43 PM" src="https://github.com/user-attachments/assets/e9e98e49-e472-4053-886d-aa8a55992a25" />

6. **Show average sale as USD by age group, and total number of transactions. Age groups are as follows:
   <= 19 = Adolescents, 20-39 = Early Adult, 40-59 = Middle Adult, >60 = Senior Adult, all other ages = Other**
```
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
```
<img width="586" height="145" alt="Screenshot 2025-08-07 at 7 49 04 PM" src="https://github.com/user-attachments/assets/eb47d350-2fb2-4d5b-bc64-a7bf4a2580a2" />


6.1. **Explore data for customers in "Other" age group from Question 6.
-- Findings:  Line 116 (previous query) should have been >= 60. There was a single customer, aged 60 years old, being grouped in the "Other" age group.**
```
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
```

7. **List the total number of transactions per gender in each category.**
```
SELECT
  category,
  gender,
  COUNT(transactions_id) as transaction_count,
FROM `sql_sales_project1.sales1`
GROUP BY category, gender
ORDER BY category, gender
```
<img width="591" height="194" alt="Screenshot 2025-08-07 at 7 51 08 PM" src="https://github.com/user-attachments/assets/38bd74fa-4c64-41f3-a9c2-d0a2b4a8f871" />


8. **Calculate the average sale for each month. Find the best selling month in each year.**
```
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
```
<img width="648" height="100" alt="Screenshot 2025-08-07 at 7 55 03 PM" src="https://github.com/user-attachments/assets/6ed46581-93c0-483d-8b87-4b11e2aeaeff" />

9. **Find the top 5 customers based on the highest total sales.**
```
SELECT
  customer_id,
  CONCAT('$',FORMAT("%'d",SUM(total_sale))) AS total_sales
FROM `sql_sales_project1.sales1`
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC
LIMIT 5
```
<img width="415" height="166" alt="Screenshot 2025-08-07 at 7 55 56 PM" src="https://github.com/user-attachments/assets/674c1936-e297-4fa3-87c6-1f8354f13842" />

10. **Show net profit by category as USD in descending order.**
```
-- Calculate net_profit as total_sale - cogs
-- Display net_profit as USD with comma for readability
SELECT 
  category,
  CONCAT('$',FORMAT("%'d",SUM(total_sale - CAST(cogs AS INT64)))) AS net_profit
FROM `sql_sales_project1.sales1`
GROUP BY 1
ORDER BY net_profit DESC
```
<img width="472" height="116" alt="Screenshot 2025-08-07 at 7 57 37 PM" src="https://github.com/user-attachments/assets/ab85738c-45cf-4e8d-94ea-bfbe68a9f19c" />

10.1 **Show net profit by category, by year as USD in descending order.**
```
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
```
<img width="660" height="199" alt="Screenshot 2025-08-07 at 7 58 53 PM" src="https://github.com/user-attachments/assets/67714c92-9044-4176-a22d-66c63a958160" />

---

## 💡 Highlight: Year-Over-Year Profit Change by Category

Used **Common Table Expressions (CTEs)** to:
- Calculate net profit per category for 2022 and 2023
- Join the results and display net profit in raw dollars
- Showcase clean financial formatting using `FORMAT()` and `CONCAT()` in BigQuery

---

## 🛠️ Tools Used

- **Google BigQuery**
- **Standard SQL**
- **Google Sheets** (for manual validation)

---

## 📁 File Structure

- `sql_sales_p1.sql`: Full project code, from cleaning to analysis




---

## ✅ Next Steps

- Add data visualizations in Looker Studio
- Explore customer lifetime value metrics
- Build dashboards from these SQL outputs

---

## 🔗 Connect with Me

If you'd like to collaborate, provide feedback, just have a chat, feel free to reach out.

www.linkedin.com/in/amandarushpatton

---

## 📌 Notes

This dataset is fictional and used strictly for learning and portfolio purposes. The project is designed to demonstrate end-to-end SQL problem solving.
