/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
- To track trends, growth, and changes in key metrics over time.
- For time-series analysis and identifying seasonality.
- To measure growth or decline over specific periods.

SQL Functions Used:
- Date Functions: DATEPART(), DATETRUNC(), FORMAT()
- Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
 */
-- Analyse sales performance over time
-- Quick Date Functions
SELECT
    YEAR (sales_order_date) AS order_year,
    --month(sales_order_date) as order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_quantity) AS total_items,
FROM
    gold.fact_sales
WHERE
    sales_order_date IS NOT NULL
GROUP BY
    order_year --, order_month
ORDER BY
    order_year;

/*
order_year,total_sales,total_customers,total_items
2010,43419,14,14
2011,7075088,2216,2216
2012,5842231,3255,3397
2013,16344878,17427,52807
2014,45642,834,1970

 */
-- similarly if the trend is checked by month.
SELECT
    --     year(sales_order_date) as order_year,
    MONTH (sales_order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_quantity) AS total_items,
FROM
    gold.fact_sales
WHERE
    sales_order_date IS NOT NULL
GROUP BY
    order_month
ORDER BY
    order_month;

-- finds the month in which sales or customers are highest(dec) and next query lowest(feb).
WITH
    monthly_sales AS (
        SELECT
            --     year(sales_order_date) as order_year,
            MONTH (sales_order_date) AS order_month,
            SUM(sales_amount) AS total_sales,
            COUNT(DISTINCT customer_key) AS total_customers,
            SUM(sales_quantity) AS total_items,
        FROM
            gold.fact_sales
        WHERE
            sales_order_date IS NOT NULL
        GROUP BY
            order_month
        ORDER BY
            order_month
    )
SELECT
    order_month,
    total_sales,
    total_customers,
    total_items,
    RANK() OVER (
        ORDER BY
            total_sales desc
    ) AS sales_rank,
    RANK() OVER (
        ORDER BY
            total_customers desc
    ) AS customer_rank
FROM
    monthly_sales qualify sales_rank = 1
    OR customer_rank = 1
ORDER BY
    sales_rank,
    customer_rank;

--lowest
WITH
    monthly_sales AS (
        SELECT
            --     year(sales_order_date) as order_year,
            MONTH (sales_order_date) AS order_month,
            SUM(sales_amount) AS total_sales,
            COUNT(DISTINCT customer_key) AS total_customers,
            SUM(sales_quantity) AS total_items,
        FROM
            gold.fact_sales
        WHERE
            sales_order_date IS NOT NULL
        GROUP BY
            order_month
        ORDER BY
            order_month
    )
SELECT
    order_month,
    total_sales,
    total_customers,
    total_items,
    RANK() OVER (
        ORDER BY
            total_sales asc
    ) AS sales_rank,
    RANK() OVER (
        ORDER BY
            total_customers asc
    ) AS customer_rank
FROM
    monthly_sales qualify sales_rank = 1
    OR customer_rank = 1
ORDER BY
    sales_rank,
    customer_rank;

-- DATETRUNC() -- month argument gives the first day of the month, year first day of the year
SELECT
    date_trunc ('month', CURRENT_DATE);

-- status of total sales, customers and items sold at the beginning of each monthly
SELECT
    --     year(sales_order_date) as order_year,
    date_trunc ('month', sales_order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_quantity) AS total_items,
FROM
    gold.fact_sales
WHERE
    sales_order_date IS NOT NULL
GROUP BY
    order_month
ORDER BY
    order_month;