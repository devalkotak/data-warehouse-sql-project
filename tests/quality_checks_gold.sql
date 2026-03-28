-- check customer_key is unique
SELECT customer_key, COUNT(*) AS cnt
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- check product_key is unique
SELECT product_key, COUNT(*) AS cnt
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- check fact_sales connects properly to both dims
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p  ON p.product_key  = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;
