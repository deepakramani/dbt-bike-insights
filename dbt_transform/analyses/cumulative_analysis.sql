/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month 
-- and the running total of sales over time .
with monthly_sales as (
select
    date_trunc('month', sales_order_date) as order_month,
    sum(sales_amount) as total_sales_per_month,
    round(avg(sales_price),2) as avg_sales_price_per_month
from {{ source('analytics_source', 'fact_sales') }}
where sales_order_date is not null
group by order_month
)
select
    order_month,
    total_sales_per_month,
    sum(total_sales_per_month) over (partition by order_month order by order_month) as running_total_sales,
    round(avg(avg_sales_price_per_month) over(partition by order_month order by order_month),2) as moving_avg_month
from monthly_sales
order by order_month;

-- by year and over time
with yearly_sales as (
select
    date_trunc('year', sales_order_date) as order_year,
    sum(sales_amount) as total_sales_per_year,
    round(avg(sales_price),2) as avg_sales_price_per_year
from  {{ source('analytics_source', 'fact_sales') }}
where sales_order_date is not null
group by order_year
)
select
    order_year,
    total_sales_per_year,
    sum(total_sales_per_year) over ( order by order_year) as running_total_sales_year,
    round(avg(avg_sales_price_per_year) over( order by order_year),2) as moving_avg_year
from yearly_sales
order by order_year;
