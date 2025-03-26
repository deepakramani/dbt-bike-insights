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
select
    year(sales_order_date) as order_year,
    --month(sales_order_date) as order_month,
    sum(sales_amount) as total_sales,
    count(distinct customer_skey) as total_customers,
    sum(sales_quantity) as total_items,
from gold.fact_sales
where sales_order_date is not null
group by order_year--, order_month
order by order_year;

/*
 order_year,total_sales,total_customers,total_items
2010,43419,14,14
2011,7075088,2216,2216
2012,5842231,3255,3397
2013,16344878,17427,52807
2014,45642,834,1970

 */
-- similarly if the trend is checked by month.
select
--     year(sales_order_date) as order_year,
    month(sales_order_date) as order_month,
    sum(sales_amount) as total_sales,
    count(distinct customer_skey) as total_customers,
    sum(sales_quantity) as total_items,
from gold.fact_sales
where sales_order_date is not null
group by order_month
order by order_month;

-- finds the month in which sales or customers are highest(dec) and next query lowest(feb).
with monthly_sales as (select
--     year(sales_order_date) as order_year,
    month(sales_order_date) as order_month,
    sum(sales_amount) as total_sales,
    count(distinct customer_skey) as total_customers,
    sum(sales_quantity) as total_items,
from gold.fact_sales
where sales_order_date is not null
group by order_month
order by order_month)
SELECT
    order_month,
    total_sales,
    total_customers,
    total_items,
    RANK() OVER (ORDER BY total_sales desc) AS sales_rank,
    RANK() OVER (ORDER BY total_customers desc) AS customer_rank
FROM monthly_sales
qualify sales_rank = 1 or customer_rank = 1
ORDER BY sales_rank, customer_rank;

--lowest
with monthly_sales as (select
--     year(sales_order_date) as order_year,
    month(sales_order_date) as order_month,
    sum(sales_amount) as total_sales,
    count(distinct customer_skey) as total_customers,
    sum(sales_quantity) as total_items,
from gold.fact_sales
where sales_order_date is not null
group by order_month
order by order_month)
SELECT
    order_month,
    total_sales,
    total_customers,
    total_items,
    RANK() OVER (ORDER BY total_sales asc) AS sales_rank,
    RANK() OVER (ORDER BY total_customers asc) AS customer_rank
FROM monthly_sales
qualify sales_rank = 1 or customer_rank = 1
ORDER BY sales_rank, customer_rank;


-- DATETRUNC() -- month argument gives the first day of the month, year first day of the year
select date_trunc('month',current_date);

-- status of total sales, customers and items sold at the beginning of each monthly
select
--     year(sales_order_date) as order_year,
    date_trunc('month',sales_order_date) as order_month,
    sum(sales_amount) as total_sales,
    count(distinct customer_skey) as total_customers,
    sum(sales_quantity) as total_items,
from gold.fact_sales
where sales_order_date is not null
group by order_month
order by order_month;