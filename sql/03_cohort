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

| customer type | num of customer | total amount | avg amount |
| --- | --- | --- | --- |
| repeat | 29,990| 6,470,204.06 | 215.75 |
| one_time | 50,100 | 4,308,151.76 | 85.99 |

** Short Summary **  
- avg amount of repeater is much higher than newey
- there would be a chance to convert more newey into repeater

-- Calculate TOP 5 products  by 'customer_type'

WITH user_details AS(
  SELECT
    user_id,
    COUNT(product_id) AS number_of_products,     -- Number of products
    COUNT(DISTINCT order_id) AS total_orders,    -- Unique number of total orders by user
    SUM(sale_price) AS total_amount              -- Total amount of orders by user
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
    total_orders,
    total_amount
  FROM user_details
),
-- Calculate total sales per product by each user
product AS(
  SELECT  
    user_id,
    product_id,
    SUM(sale_price) AS total_product_sales
  FROM bigquery-public-data.thelook_ecommerce.order_items
  GROUP BY user_id,product_id
),
-- Join product information into **labeled**
customer_sales AS(
  SELECT
   customer_type,
   COUNT(DISTINCT labeled.user_id) AS number_of_customer,
   product_id,
   SUM(product.total_product_sales) AS total_amount
  FROM  labeled
  JOIN  product
  ON labeled.user_id = product.user_id
  GROUP BY customer_type, product_id
)
-- Pick up top 5 products per *customer_type* 
SELECT
  customer_type,
  product_id,
  number_of_customer,
  ROUND(total_amount,2) AS total_amount
FROM customer_sales
QUALIFY RANK() OVER (PARTITION BY customer_type ORDER BY total_amount DESC) <= 5  -- Including same ranking 
ORDER BY customer_type, total_amount DESC;

** Short Summary ** 
-- 2 products are ranked in top 5 for both *customer_type*
-- Next action is to find the products name
-- Created view for the further analysis (See in the View file)

WITH top5 AS 
(
  SELECT 
  *
  FROM `famous-cache-463121-g6.ecomm_data.vw_per_type` 
  QUALIFY RANK() OVER (PARTITION BY customer_type ORDER BY total_amount DESC) <= 5
),

common_id AS
(
  SELECT
    product_id
  FROM top5
  GROUP BY product_id
  HAVING COUNT(DISTINCT customer_type) = 2  -- Common id for both custtomer type
)
-- Find products name by using products table 
SELECT
  id AS product_id,
  name AS product_name
FROM bigquery-public-data.thelook_ecommerce.products
JOIN common_id
ON id = product_id

| product_id | product_name |
| --- | --- |
| 17094 | The North Face Apex Bionic Soft Shell Jacket - Men's |
| 22927 | AIR JORDAN DOMINATE SHORTS MENS 465071-100 |

** Short Summary ** 
-- These 2 items are common for both customer type
-- Both items are in men's clothing category



