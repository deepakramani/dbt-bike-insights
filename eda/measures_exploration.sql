ATTACH 'dwh.duckdb' as db1;
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
from gold.fact_sales; -- 29,356,250

-- Find how many items are sold
select
    sum(sales_quantity) as total_items_sold
from gold.fact_sales; --60423

-- Find the average selling price
select
    round(avg(sales_price),2) as avg_sale_price
from gold.fact_sales; -- 486.04

-- Find the Total number of Orders
select
    count(distinct sales_order_number) as total_orders
from gold.fact_sales; --27659

-- Find the total number of products
select
    count( product_key) as total_products
from gold.dim_products; -- 295
select
    count( distinct product_skey) as total_products
from gold.fact_sales; --130

-- Find the total number of customers
select
    count(customer_skey) as total_customers
from gold.dim_customers; --18484

-- Find the total number of customers that has placed an order
select
    count( distinct customer_skey) as total_customers
from gold.fact_sales; --18484

-- Generate a Report that shows all key metrics of the business
select
    'total_sales' as measure_name,
    sum(sales_amount) as measure_value
from gold.fact_sales
UNION ALL
select
    'total_items_sold' as measure_name,
    sum(sales_quantity) as measure_value
from gold.fact_sales
UNION ALL
select
    'avg_sale_price' as measure_name,
    round(avg(sales_price),2) as measure_value
from gold.fact_sales
UNION ALL
SELECT
    'total_orders' as measure_name,
    count(distinct sales_order_number) as measure_value
from gold.fact_sales
UNION ALL
select
    'total_products' as measure_name,
    count( product_key) as measure_value
from gold.dim_products
UNION ALL
select
    'total_customer' as measure_name,
    count(customer_skey) as measure_value
from gold.dim_customers
UNION ALL
select
    'total_ordered_customer' as measure_name,
    count( distinct customer_skey) as measure_value
from gold.fact_sales;

DETACH db1;