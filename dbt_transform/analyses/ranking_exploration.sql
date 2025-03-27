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


-- Ranking Analysis

-- Which top 5 products Generating the Highest Revenue?
select
    dp.product_key,
    dp.product_name,
    dp.product_category,
    sum(fs.sales_amount) as total_sales_per_product
from {{ source('analytics_source', 'fact_sales') }} fs
left join {{ source('analytics_source', 'dim_products') }} dp on fs.product_skey = dp.product_skey
group by dp.product_key, dp.product_name, dp.product_category
order by total_sales_per_product desc
limit 5;

/*
 product_key,product_name,product_category,total_sales_per_product
BK-M68B-46,Mountain-200 Black- 46,Bikes,1373454
BK-M68B-42,Mountain-200 Black- 42,Bikes,1363128
BK-M68S-38,Mountain-200 Silver- 38,Bikes,1339394
BK-M68S-46,Mountain-200 Silver- 46,Bikes,1301029
BK-M68B-38,Mountain-200 Black- 38,Bikes,1294854

 */

-- Complex but Flexibly Ranking Using Window Functions
with product_revenue as (
    SELECT
        dp.product_name,
        sum(fs.sales_amount) as total_sales_per_product
    from {{ source('analytics_source', 'fact_sales') }} fs
    left join {{ source('analytics_source', 'dim_products') }} dp on fs.product_skey = dp.product_skey
    group by dp.product_name
),
ranked_products as (
    select
        product_name,
        total_sales_per_product,
        rank() over(order by total_sales_per_product desc) as ranked_products
    from product_revenue
)
select *
from ranked_products
where ranked_products <=5;
/*
product_name,total_sales_per_product,ranked_products
Mountain-200 Black- 46,1373454,1
Mountain-200 Black- 42,1363128,2
Mountain-200 Silver- 38,1339394,3
Mountain-200 Silver- 46,1301029,4
Mountain-200 Black- 38,1294854,5
*/

-- What are the 5 worst-performing products in terms of sales?
with product_revenue as (
    SELECT
        dp.product_name,
        sum(fs.sales_amount) as total_sales_per_product,
        rank() over (order by sum(fs.sales_amount) desc) as rank_products
    from {{ source('analytics_source', 'fact_sales') }} fs
    left join {{ source('analytics_source', 'dim_products') }} dp on fs.product_skey = dp.product_skey
    group by dp.product_name
)
select *
from product_revenue
where rank_products<=5;


/*
 product_name,total_sales_per_product,ranked_products
Racing Socks- L,2430,1
Racing Socks- M,2682,2
Patch Kit/8 Patches,6382,3
Bike Wash - Dissolver,7272,4
Touring Tire Tube,7440,5

 */

-- Find the top 10 customers who have generated the highest revenue
select dc.customer_key ,dc.customer_firstname, dc.customer_lastname,
       sum(fs.sales_amount) as total_revenue,
       dense_rank() over(order by sum(fs.sales_amount) desc) as ranked_customers_d,
        --rank() over(order by sum(fs.sales_amount) desc) as ranked_customers_r,
from {{ source('analytics_source', 'fact_sales') }} fs
left join {{ source('analytics_source', 'dim_customers') }} dc on fs.customer_skey = dc.customer_skey
group by dc.customer_key, dc.customer_firstname, dc.customer_lastname
qualify ranked_customers_d <=10;


-- The 3 customers with the fewest orders placed
with cte_ as (
    select  dc.customer_id ,dc.customer_firstname, dc.customer_lastname, count(distinct fs.sales_order_number) as total_orders
from {{ source('analytics_source', 'fact_sales') }} fs
left join {{ source('analytics_source', 'dim_customers') }} dc on fs.customer_skey = dc.customer_skey
group by dc.customer_id , dc.customer_firstname, dc.customer_lastname
order by  total_orders
)
select * from cte_
limit 3;
