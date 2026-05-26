SELECT COUNT(*) AS raw_count FROM mock_data;

SELECT 'dim_product'  AS tbl, COUNT(*) AS cnt FROM dim_product  UNION ALL
SELECT 'dim_customer',         COUNT(*) FROM dim_customer UNION ALL
SELECT 'dim_date',             COUNT(*) FROM dim_date     UNION ALL
SELECT 'dim_store',            COUNT(*) FROM dim_store    UNION ALL
SELECT 'dim_supplier',         COUNT(*) FROM dim_supplier UNION ALL
SELECT 'fact_sales',           COUNT(*) FROM fact_sales;

SELECT p.product_name, p.category,
       SUM(f.total_amount)::NUMERIC(12,2) AS revenue,
       SUM(f.quantity) AS qty_sold
FROM fact_sales f
JOIN dim_product p USING (product_id)
GROUP BY 1, 2
ORDER BY revenue DESC
LIMIT 5;

SELECT d.year, COUNT(*) AS orders, SUM(f.total_amount)::NUMERIC(14,2) AS revenue
FROM fact_sales f
JOIN dim_date d USING (date_id)
GROUP BY d.year
ORDER BY d.year;


SELECT name FROM system.tables WHERE database = 'reports';

SELECT product_name, category, total_quantity, total_revenue, avg_rating
FROM reports.sales_by_product
ORDER BY revenue_rank
LIMIT 10;

SELECT category, SUM(total_revenue) AS cat_revenue
FROM reports.sales_by_product
GROUP BY category
ORDER BY cat_revenue DESC;

SELECT product_name, avg_rating, total_reviews
FROM reports.sales_by_product
ORDER BY avg_rating DESC
LIMIT 10;

SELECT full_name, country, total_spent, order_count, avg_check
FROM reports.sales_by_customer
ORDER BY spending_rank
LIMIT 10;

SELECT country, COUNT(*) AS customers, ROUND(SUM(total_spent), 2) AS total
FROM reports.sales_by_customer
GROUP BY country
ORDER BY total DESC;

SELECT period, total_revenue, total_orders, avg_order_size
FROM reports.sales_by_time
ORDER BY year, month;

SELECT year, SUM(total_revenue) AS annual_revenue, SUM(total_orders) AS annual_orders
FROM reports.sales_by_time
GROUP BY year
ORDER BY year;

SELECT store_name, city, country, total_revenue, total_orders, avg_check
FROM reports.sales_by_store
ORDER BY revenue_rank
LIMIT 5;

SELECT country, SUM(total_revenue) AS revenue, SUM(total_orders) AS orders
FROM reports.sales_by_store
GROUP BY country
ORDER BY revenue DESC;

SELECT supplier_name, country, total_revenue, avg_price, total_orders
FROM reports.sales_by_supplier
ORDER BY revenue_rank
LIMIT 5;

SELECT country, SUM(total_revenue) AS revenue
FROM reports.sales_by_supplier
GROUP BY country
ORDER BY revenue DESC;

SELECT product_name, category, avg_rating, total_reviews
FROM reports.product_quality
ORDER BY quality_rank
LIMIT 10;

SELECT product_name, category, avg_rating, total_reviews
FROM reports.product_quality
ORDER BY avg_rating ASC
LIMIT 10;

SELECT product_name, total_reviews, avg_rating, total_sales
FROM reports.product_quality
ORDER BY total_reviews DESC
LIMIT 10;

SELECT category,
       ROUND(AVG(avg_rating), 2) AS mean_rating,
       SUM(total_sales)          AS total_sales,
       ROUND(corr(avg_rating, total_sales), 4) AS rating_sales_corr
FROM reports.product_quality
GROUP BY category
ORDER BY rating_sales_corr DESC;
