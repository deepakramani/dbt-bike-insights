/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/

with product_segments as (
SELECT
    product_name,
    product_key,
    product_category,
    product_cost,
    CASE
        WHEN product_cost < 100 then 'BELOW 100'
        WHEN product_cost between 100 and 500 then '100-500'
        WHEN product_cost between 500  and 1000 then '500-1000'
        ELSE 'above 1000'
    END  as product_cost_range
from gold.dim_products
)
select
    product_cost_range,
    count(product_key) as total_products
from product_segments
group by product_cost_range
order by total_products desc;


/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/


WITH customer_spending as (
    SELECT
    dc.customer_key,
    sum(fs.sales_amount) as total_spending,
    min(sales_order_date) as first_order,
    max(sales_order_date) as last_order,
    datediff('month', min(sales_order_date), max(sales_order_date) ) as lifespan
from gold.fact_sales fs
left join gold.dim_customers dc on fs.customer_skey = dc.customer_skey
group by dc.customer_key
),
customer_seg as (
select
    *,
    CASE
        WHEN lifespan >=12 AND total_spending > 5000 then 'VIP'
        WHEN lifespan >=12 AND total_spending <= 5000 then 'Regular'
        ELSE 'NEW'
    END as customer_status
from customer_spending
)
select
    customer_status,
    count(customer_key) as total_customers
from customer_seg
group by customer_status
order by  total_customers desc;