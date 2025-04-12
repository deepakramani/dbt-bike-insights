/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
- To rank items (e.g., products, customers) based on performance or other metrics.
- To identify top performers or laggards.

SQL Functions Used:
- Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
- Clauses: GROUP BY, ORDER BY
===============================================================================
 */
ATTACH 'dwh.duckdb' AS db1;

-- Ranking Analysis
-- Which top 5 products Generating the Highest Revenue?
SELECT
    dp.product_key,
    dp.product_name,
    dp.product_category,
    SUM(fs.sales_amount) AS total_sales_per_product
FROM
    gold.fact_sales fs
    LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
GROUP BY
    dp.product_key,
    dp.product_name,
    dp.product_category
ORDER BY
    total_sales_per_product desc
LIMIT
    5;

/*
product_key,product_name,product_category,total_sales_per_product
BK-M68B-46,Mountain-200 Black- 46,Bikes,1373454
BK-M68B-42,Mountain-200 Black- 42,Bikes,1363128
BK-M68S-38,Mountain-200 Silver- 38,Bikes,1339394
BK-M68S-46,Mountain-200 Silver- 46,Bikes,1301029
BK-M68B-38,Mountain-200 Black- 38,Bikes,1294854

 */
-- Complex but Flexibly Ranking Using Window Functions
WITH
    product_revenue AS (
        SELECT
            dp.product_name,
            SUM(fs.sales_amount) AS total_sales_per_product
        FROM
            gold.fact_sales fs
            LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
        GROUP BY
            dp.product_name
    ),
    ranked_products AS (
        SELECT
            product_name,
            total_sales_per_product,
            RANK() OVER (
                ORDER BY
                    total_sales_per_product desc
            ) AS ranked_products
        FROM
            product_revenue
    )
SELECT
    *
FROM
    ranked_products
WHERE
    ranked_products <= 5;

/*
product_name,total_sales_per_product,ranked_products
Mountain-200 Black- 46,1373454,1
Mountain-200 Black- 42,1363128,2
Mountain-200 Silver- 38,1339394,3
Mountain-200 Silver- 46,1301029,4
Mountain-200 Black- 38,1294854,5
 */
-- What are the 5 worst-performing products in terms of sales?
WITH
    product_revenue AS (
        SELECT
            dp.product_name,
            SUM(fs.sales_amount) AS total_sales_per_product,
            RANK() OVER (
                ORDER BY
                    SUM(fs.sales_amount) desc
            ) AS rank_products
        FROM
            gold.fact_sales fs
            LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
        GROUP BY
            dp.product_name
    )
SELECT
    *
FROM
    product_revenue
WHERE
    rank_products <= 5;

/*
product_name,total_sales_per_product,ranked_products
Racing Socks- L,2430,1
Racing Socks- M,2682,2
Patch Kit/8 Patches,6382,3
Bike Wash - Dissolver,7272,4
Touring Tire Tube,7440,5

 */
-- Find the top 10 customers who have generated the highest revenue
SELECT
    dc.customer_key,
    dc.customer_firstname,
    dc.customer_lastname,
    SUM(fs.sales_amount) AS total_revenue,
    DENSE_RANK() OVER (
        ORDER BY
            SUM(fs.sales_amount) desc
    ) AS ranked_customers_d,
    --rank() over(order by sum(fs.sales_amount) desc) as ranked_customers_r,
FROM
    gold.fact_sales fs
    LEFT JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key
GROUP BY
    dc.customer_key,
    dc.customer_firstname,
    dc.customer_lastname qualify ranked_customers_d <= 10;

-- The 3 customers with the fewest orders placed
WITH
    cte_ AS (
        SELECT
            dc.customer_id,
            dc.customer_firstname,
            dc.customer_lastname,
            COUNT(DISTINCT fs.sales_order_number) AS total_orders
        FROM
            gold.fact_sales fs
            LEFT JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key
        GROUP BY
            dc.customer_id,
            dc.customer_firstname,
            dc.customer_lastname
        ORDER BY
            total_orders
    )
SELECT
    *
FROM
    cte_
LIMIT
    3;

DETACH db1;