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

with yearly_sales as (
select
    date_part('year', sales_order_date) as order_year,
    dp.product_name,
    sum(fs.sales_amount) as current_sales
from {{ source('analytics_source', 'fact_sales') }} fs
left join {{ source('analytics_source', 'dim_products') }} dp on fs.product_skey = dp.product_skey
where fs.sales_order_date is not null
group by order_year, dp.product_name
order by order_year
),
avg_prev_sales as (select
    order_year,
    product_name,
    current_sales,
    avg(current_sales) over(partition by product_name) as avg_sales,
    lag(current_sales) over(partition by product_name order by order_year) as prev_sales
from yearly_sales
order by product_name,order_year)
select
    *,
    current_sales - avg_sales as sales_avg_diff,
    case
        when (current_sales - avg_sales) > 0 then 'above average'
        when (current_sales - avg_sales) < 0 then 'below average'
        else 'average'
    end as avg_sales_change,
    current_sales - prev_sales as sales_diff,
    case
        when (current_sales - prev_sales) > 0 then 'increase'
        when (current_sales - prev_sales) < 0 then 'decrease'
        else 'no change'
    end as prev_sales_change
from avg_prev_sales;

--month-to-month analysis
with monthly_sales as (
select
    date_part('month', sales_order_date) as order_month,
    dp.product_name,
    sum(fs.sales_amount) as current_sales
from {{ source('analytics_source', 'fact_sales') }} fs
left join {{ source('analytics_source', 'dim_products') }} dp on fs.product_skey = dp.product_skey
where fs.sales_order_date is not null
group by order_month, dp.product_name
order by order_month
),
avg_prev_sales as (select
    order_month,
    product_name,
    current_sales,
    avg(current_sales) over(partition by product_name) as avg_sales,
    lag(current_sales) over(partition by product_name order by order_month) as prev_sales
from monthly_sales
order by product_name,order_month)
select
    *,
    current_sales - avg_sales as sales_avg_diff,
    case
        when (current_sales - avg_sales) > 0 then 'above average'
        when (current_sales - avg_sales) < 0 then 'below average'
        else 'average'
    end as avg_sales_change,
    current_sales - prev_sales as sales_diff,
    case
        when (current_sales - prev_sales) > 0 then 'increase'
        when (current_sales - prev_sales) < 0 then 'decrease'
        else 'no change'
    end as prev_sales_change
from avg_prev_sales;
