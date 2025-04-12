ATTACH 'dwh.duckdb' AS db1;

/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
- To calculate aggregated metrics (e.g., totals, averages) for quick insights.
- To identify overall trends or spot anomalies.

SQL Functions Used:
- COUNT(), SUM(), AVG()
===============================================================================
 */
-- Find the Total Sales
SELECT
    SUM(sales_amount) AS total_sales
FROM
    gold.fact_sales;

-- 29,356,250
-- Find how many items are sold
SELECT
    SUM(sales_quantity) AS total_items_sold
FROM
    gold.fact_sales;

--60423
-- Find the average selling price
SELECT
    ROUND(AVG(sales_price), 2) AS avg_sale_price
FROM
    gold.fact_sales;

-- 486.04
-- Find the Total number of Orders
SELECT
    COUNT(DISTINCT sales_order_number) AS total_orders
FROM
    gold.fact_sales;

--27659
-- Find the total number of products
SELECT
    COUNT(product_key) AS total_products
FROM
    gold.dim_products;

-- 295
SELECT
    COUNT(DISTINCT product_key) AS total_products
FROM
    gold.fact_sales;

--130
-- Find the total number of customers
SELECT
    COUNT(customer_key) AS total_customers
FROM
    gold.dim_customers;

--18484
-- Find the total number of customers that has placed an order
SELECT
    COUNT(DISTINCT customer_key) AS total_customers
FROM
    gold.fact_sales;

--18484
-- Generate a Report that shows all key metrics of the business
SELECT
    'total_sales' AS measure_name,
    SUM(sales_amount) AS measure_value
FROM
    gold.fact_sales
UNION ALL
SELECT
    'total_items_sold' AS measure_name,
    SUM(sales_quantity) AS measure_value
FROM
    gold.fact_sales
UNION ALL
SELECT
    'avg_sale_price' AS measure_name,
    ROUND(AVG(sales_price), 2) AS measure_value
FROM
    gold.fact_sales
UNION ALL
SELECT
    'total_orders' AS measure_name,
    COUNT(DISTINCT sales_order_number) AS measure_value
FROM
    gold.fact_sales
UNION ALL
SELECT
    'total_products' AS measure_name,
    COUNT(product_key) AS measure_value
FROM
    gold.dim_products
UNION ALL
SELECT
    'total_customer' AS measure_name,
    COUNT(customer_key) AS measure_value
FROM
    gold.dim_customers
UNION ALL
SELECT
    'total_ordered_customer' AS measure_name,
    COUNT(DISTINCT customer_key) AS measure_value
FROM
    gold.fact_sales;

DETACH db1;