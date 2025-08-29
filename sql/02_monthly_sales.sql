-- 1) Calculate the number of orders by year, month
SELECT
 COUNT(order_id) AS order_count,
 EXTRACT(YEAR FROM created_at) AS year,
 EXTRACT(MONTH FROM created_at) AS month
FROM bigquery-public-data.thelook_ecommerce.orders
GROUP BY year, month 
ORDER BY year, month
 
-- 2) Calculate total sales and average by year, month
 SELECT
 ROUND(SUM(sale_price),2) AS total_sales,
 ROUND(AVG(sale_price),2) AS avd_sales,
 EXTRACT(YEAR FROM created_at) AS year,
 EXTRACT(MONTH FROM created_at) AS month
FROM bigquery-public-data.thelook_ecommerce.order_items
GROUP BY year, month 
ORDER BY year, month;

-- 3) Calculate the number of orders by weekday
SELECT 
  COUNT(order_id) AS order_count,
  EXTRACT(DAYOFWEEK FROM created_at) AS day_of_week -- 1= Sunday, 7= Saturday
FROM bigquery-public-data.thelook_ecommerce.orders
GROUP BY day_of_week
ORDER BY day_of_week;

-- 4) Calculate growth rate by month
WITH monthly_orders AS
(
  SELECT 
    FORMAT_DATE('%Y-%m',DATE(created_at)) AS year_month,  -- Change date format 
    COUNT(order_id) AS order_count
  FROM bigquery-public-data.thelook_ecommerce.orders
  GROUP BY year_month
)

SELECT
  year_month,
  monthly_orders.order_count,
  LAG(monthly_orders.order_count) OVER (ORDER BY year_month) AS prev_month,   -- order count of prev month
  ROUND(SAFE_DIVIDE(order_count - LAG(monthly_orders.order_count) OVER (ORDER BY year_month),  
              LAG(monthly_orders.order_count) OVER (ORDER BY year_month)),4)*100 AS growth_rate_pct   -- Growth Rate
FROM monthly_orders
ORDER BY year_month;

** Short Summary**
-- The number of orders are growing 
-- Weekend is popular for customers

-- 5) Calculte top 5 products by year and month
WITH 
 total_sales_per_product AS(    --- Create CTE for total sales per product by year and month
  SELECT
  product_id,
  EXTRACT(YEAR FROM created_at) AS created_year,
  EXTRACT(MONTH FROM created_at) AS created_month,
  SUM(sale_price) AS total_sales
 FROM bigquery-public-data.thelook_ecommerce.order_items
 GROUP BY product_id, created_year, created_month
 ORDER BY created_year, created_month, total_sales DESC)
,
ranked AS(                    --- Create CTE for calculateing total sales rank in month
  SELECT
    product_id,
    created_year,
    created_month,
    total_sales,
    RANK()OVER(
      PARTITION BY created_year, created_month
      ORDER BY total_sales DESC) AS rank_in_month
  FROM total_sales_per_product
  )
SELECT
  product_id,
  created_year,
  created_month,
  total_sales
FROM ranked
WHERE rank_in_month <= 5    --- Limit 5 for each product in month and year
ORDER BY created_year, created_month, rank_in_month;


-- 6) Calculate total sales by customer type per month
-- Customer type Definition: Monthly Perspective
WITH items AS  -- Create CTE for fastest 
(
  SELECT
   user_id,
   sale_price,
   DATE_TRUNC(created_at, MONTH) AS order_month
FROM `bigquery-public-data.thelook_ecommerce.order_items` 
),
first_m AS
(
  SELECT
    user_id,
    MIN(items.order_month) AS first_order    
  FROM items
  GROUP BY user_id
),
monthly_sales AS
(
 SELECT
   IF(items.order_month = first_m.first_order, 'one_time','repeat') AS customer_type,
   EXTRACT(YEAR FROM order_month) AS year,
   EXTRACT(MONTH FROM order_month) AS month,
   ROUND(SUM(sale_price),2) AS total_sales
 FROM items
 JOIN first_m
 ON items.user_id = first_m.user_id
 GROUP BY customer_type, year, month
)
SELECT
  customer_type,
  year,
  month,
  total_sales,
  LAG(total_sales)OVER(ORDER BY year,month) AS pre_month,
  ROUND(SAFE_DIVIDE(total_sales - LAG(total_sales)OVER(ORDER BY year,month),LAG(total_sales)OVER(ORDER BY year,month)),2) AS growth_rate
FROM monthly_sales
ORDER BY year, month;
