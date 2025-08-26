--- Data cleaning for **order_items**

-- 1) Count products and rows for each order
SELECT
  order_id,
  COUNT(DISTINCT product_id) AS product_count,
  COUNT(*) AS row_count
FROM  bigquery-public-data.thelook_ecommerce.order_items
GROUP BY order_id
ORDER BY product_count DESC
LIMIT 20;

-- 2) Select example of orders including duplicate products
SELECT
 order_id, 
 user_id,
 product_id, 
 sale_price
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE 
  order_id IN(
    SELECT order_id
    FROM bigquery-public-data.thelook_ecommerce.order_items
    GROUP BY order_id
    HAVING COUNT(DISTINCT product_id) >1
  )
ORDER BY order_id
LIMIT 50;

-- 3) Check data structure by counting duplicate rows
SELECT 
  order_id,
  product_id,
  COUNT(*) AS item_count,
  SUM(sale_price) AS total_price
FROM bigquery-public-data.thelook_ecommerce.order_items
GROUP BY order_id, product_id
ORDER BY item_count DESC;

-- 4) Check NULL or invalid data 
SELECT
 *
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE sale_price IS NULL OR sale_price < 0
LIMIT 200;

-- Data cleanig for **orders**

-- 1) Check duplicate of *order_id*
SELECT 
 order_id,
 COUNT(order_id) AS count
FROM `bigquery-public-data.thelook_ecommerce.orders` 
GROUP BY order_id
HAVING count > 1;

-- 2) Calculate number of orders by each user
SELECT
  user_id,
  COUNT(*) AS order_count
FROM  bigquery-public-data.thelook_ecommerce.orders
GROUP BY user_id
ORDER BY order_count DESC
LIMIT 200;
