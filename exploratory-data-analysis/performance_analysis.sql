/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
- To measure the performance of products, customers, or regions over time.
- For benchmarking and identifying high-performing entities.
- To track yearly trends and growth.

SQL Functions Used:
- LAG(): Accesses data from previous rows.
- AVG() OVER(): Computes average values within partitions.
- CASE: Defines conditional logic for trend analysis.
===============================================================================
 */
/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH
    yearly_sales AS (
        SELECT
            date_part ('year', sales_order_date) AS order_year,
            dp.product_name,
            SUM(fs.sales_amount) AS current_sales
        FROM
            gold.fact_sales fs
            LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
        WHERE
            fs.sales_order_date IS NOT NULL
        GROUP BY
            order_year,
            dp.product_name
        ORDER BY
            order_year
    ),
    avg_prev_sales AS (
        SELECT
            order_year,
            product_name,
            current_sales,
            AVG(current_sales) OVER (
                PARTITION BY
                    product_name
            ) AS avg_sales,
            lag (current_sales) OVER (
                PARTITION BY
                    product_name
                ORDER BY
                    order_year
            ) AS prev_sales
        FROM
            yearly_sales
        ORDER BY
            product_name,
            order_year
    )
SELECT
    *,
    current_sales - avg_sales AS sales_avg_diff,
    CASE
        WHEN (current_sales - avg_sales) > 0 THEN 'above average'
        WHEN (current_sales - avg_sales) < 0 THEN 'below average'
        ELSE 'average'
    END AS avg_sales_change,
    current_sales - prev_sales AS sales_diff,
    CASE
        WHEN (current_sales - prev_sales) > 0 THEN 'increase'
        WHEN (current_sales - prev_sales) < 0 THEN 'decrease'
        ELSE 'no change'
    END AS prev_sales_change
FROM
    avg_prev_sales;

--month-to-month analysis
WITH
    monthly_sales AS (
        SELECT
            date_part ('month', sales_order_date) AS order_month,
            dp.product_name,
            SUM(fs.sales_amount) AS current_sales
        FROM
            gold.fact_sales fs
            LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
        WHERE
            fs.sales_order_date IS NOT NULL
        GROUP BY
            order_month,
            dp.product_name
        ORDER BY
            order_month
    ),
    avg_prev_sales AS (
        SELECT
            order_month,
            product_name,
            current_sales,
            AVG(current_sales) OVER (
                PARTITION BY
                    product_name
            ) AS avg_sales,
            lag (current_sales) OVER (
                PARTITION BY
                    product_name
                ORDER BY
                    order_month
            ) AS prev_sales
        FROM
            monthly_sales
        ORDER BY
            product_name,
            order_month
    )
SELECT
    *,
    current_sales - avg_sales AS sales_avg_diff,
    CASE
        WHEN (current_sales - avg_sales) > 0 THEN 'above average'
        WHEN (current_sales - avg_sales) < 0 THEN 'below average'
        ELSE 'average'
    END AS avg_sales_change,
    current_sales - prev_sales AS sales_diff,
    CASE
        WHEN (current_sales - prev_sales) > 0 THEN 'increase'
        WHEN (current_sales - prev_sales) < 0 THEN 'decrease'
        ELSE 'no change'
    END AS prev_sales_change
FROM
    avg_prev_sales;