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

### Sales Trend

** SQL used**
```sql
-- Count number of orders, Total sales and Average sales per year
SELECT
 COUNT(DISTINCT order_id) AS order_count,
 ROUND(SUM(sale_price),2) AS total_sales,
 ROUND(AVG(sale_price),2) AS avd_sales,
 EXTRACT(YEAR FROM created_at) AS year
FROM bigquery-public-data.thelook_ecommerce.order_items
GROUP BY year 
ORDER BY year;


  
