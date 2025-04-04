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

select
    sum(sales_amount) as total_sales
from {{ source('analytics_source','fact_sales') }}; -- 29,356,250

-- Find how many items are sold
select
    sum(sales_quantity) as total_items_sold
from {{ source('analytics_source','fact_sales') }}; --60423

-- Find the average selling price
select
    round(avg(sales_price),2) as avg_sale_price
from {{ source('analytics_source','fact_sales') }}; -- 486.04

-- Find the Total number of Orders
select
    count(distinct sales_order_number) as total_orders
from {{ source('analytics_source','fact_sales') }}; --27659

-- Find the total number of products
select
    count( product_key) as total_products
from {{ source('analytics_source','dim_products_current') }}; -- 295
select
    count( distinct product_skey) as total_products
from {{ source('analytics_source','fact_sales') }}; --130

-- Find the total number of customers
select
    count(customer_skey) as total_customers
from {{ source('analytics_source','dim_customers_current') }}; --18484

-- Find the total number of customers that has placed an order
select
    count( distinct customer_skey) as total_customers
from {{ source('analytics_source','fact_sales') }}; --18484



-- Generate a comprehensive business metrics 
with customer_source as (
    Select * from {{ source('analytics_source','dim_customers_current') }}
),
products_source as (
    Select * from {{ source('analytics_source','dim_products_current') }}
),
sales_source as (
    Select * from {{ source('analytics_source','fact_sales') }}
),
sales_metrics as (
    select
        sum(sales_amount) as total_sales,
        sum(sales_quantity) as total_items_sold,
        round(avg(sales_price),2) as avg_sale_price,
        count(distinct sales_order_number) as total_orders
    from sales_source
),
product_metrics as (
    select 
        count(product_key) as total_products
    from products_source
),
customer_metrics as (
    select 
        count(customer_skey) as total_customers,
        (select count(distinct customer_skey) from sales_source) as total_ordered_customers
    from customer_source
),
business_metrics as (
    select 'total_sales' as measure_name, total_sales as measure_value from sales_metrics
    UNION ALL
    select 'total_items_sold', total_items_sold from sales_metrics
    UNION ALL
    select 'avg_sale_price', avg_sale_price from sales_metrics
    UNION ALL
    select 'total_orders', total_orders from sales_metrics
    UNION ALL
    select 'total_products', total_products from product_metrics
    UNION ALL
    select 'total_customer', total_customers from customer_metrics
    UNION ALL
    select 'total_ordered_customer', total_ordered_customers from customer_metrics
)
select * from business_metrics;
