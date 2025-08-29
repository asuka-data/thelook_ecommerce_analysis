# Ecommerce Data Cleaning and Analysis

## 1. Data Preparation
- comfirm which tables are necessary for this analysis
- Pick up 3 tables; orders, order_items, products
  
## 2. Data Cleaning Steps
- Check each tables' structures
- Check data types
- Find common columns for further analysis
- Check duplicate and invalid data

## 3. Data Exploration Summary
### Data Volume
- Total rows (orders): **125,135**
- Total rows (order_items): **181,272**
- Total_rows (products): **291,120**

### Data Range
- orders: 2019_01_01-2025-08-01
- order_items: 2019_01_01-2025_09_01

### Sales Trend per Year

** SQL used**
```sql
-- Count number of orders, Total sales and Average sales per year
SELECT
 COUNT(DISTINCT order_id) AS order_count,
 ROUND(SUM(sale_price),2) AS total_sales,
 ROUND(AVG(sale_price),2) AS avg_sales,
 EXTRACT(YEAR FROM created_at) AS year
FROM bigquery-public-data.thelook_ecommerce.order_items
GROUP BY year 
ORDER BY year;

| order_count | total_sales | avd_sales | year |
|-------------|-------------|-----------|------|
| 1438        | 122254.52   | 59.81     | 2019 |
| 4819        | 406611.28   | 58.84     | 2020 |
| 8616        | 746537.69   | 60.33     | 2021 |
| 13626       | 1163347.96  | 59.77     | 2022 |
| 20753       | 1817921.15  | 60.3      | 2023 |
| 33014       | 2859942.85  | 59.65     | 2024 |
| 43039       | 3740016.71  | 59.95     | 2025 |
```
#### Short summary
-- The number of orders and total sales are growing
-- The average sales are stable but still room for improving


### Customer segmentation and anlysis

**Overall Perspective**
```sql
-- Calculate *total_orders* and *total_amount* by user
WITH user_details AS(
 SELECT
   user_id,
   COUNT(DISTINCT order_id) AS total_orders,  -- Unique number of total orders by user
   SUM(sale_price) AS total_amount,  -- Total amount of orders by user
 FROM bigquery-public-data.thelook_ecommerce.order_items
 GROUP BY user_id
),
-- Categorize user into 'repeat' and 'one_time'
labeled AS(
  SELECT
    user_id,
    CASE WHEN total_orders >1 THEN 'repeat'
         WHEN total_orders =1 THEN 'one_time'
         ELSE NULL END AS customer_type,
    total_amount,
    total_orders
  FROM user_details 
)
SELECT
  customer_type,
  COUNT(DISTINCT user_id) AS number_of_customers,  -- Count unique user 
  ROUND(SUM(total_amount),2) AS total_amount,  -- Total amount of orders by customer type
  ROUND(AVG(total_amount),2) AS avg_amount  -- Average amount of orders by customer type
FROM labeled
GROUP BY customer_type;

| customer_type | number_of_customers | total_amount | avg_amount |
|---------------|---------------------|--------------|------------|
| one_time      | 49829               | 4306721.61   | 86.43      |
| repeat        | 30025               | 6549910.56   | 218.15     |
```

#### Short summary
- Repeat customer spend much money than one_time customer


### Top common selling products for both customer type

**Overall Perspective**
```sql
-- Find the commmon products for both customer_type
WITH top10 AS 
(
  SELECT 
  *
  FROM `famous-cache-463121-g6.ecomm_data.vw_per_type` 
  QUALIFY RANK() OVER (PARTITION BY customer_type ORDER BY total_amount DESC) <= 10
),

common_id AS
(
  SELECT
    product_id
  FROM top10  GROUP BY product_id
  HAVING COUNT(DISTINCT customer_type) = 2  -- Common id for both custtomer type
)
-- Find products name by using products table 
SELECT
  id AS product_id,
  name AS product_name
FROM bigquery-public-data.thelook_ecommerce.products
JOIN common_id
ON id = product_id

| product_id | product_name                      |
|------------|-----------------------------------|
| 24042      | Canada Goose Men's Langford Parka |
```

#### Short Summary
- For marketing point, there should be needed how to deal with this item

