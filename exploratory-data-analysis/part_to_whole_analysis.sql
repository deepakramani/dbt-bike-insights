/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales and overall orders?
with category_sales_orders as (
select
    dp.product_category,
    sum(fs.sales_amount) as total_sales,
    count(fs.sales_order_number) as total_orders
from gold.fact_sales fs
left join gold.dim_products dp on fs.product_key = dp.product_key
group by dp.product_category
),
overall_calc as (
select *,
       sum(total_sales) over() as overall_sales,
       sum(total_orders) over() as overall_orders
from category_sales_orders
)
select *,
       concat(round((total_sales::float/overall_sales)*100,2) , '%') as percentage_of_total,
       concat(round((total_orders::float/overall_orders)*100,2) , '%') as percentage_of_orders
from overall_calc
order by total_sales desc;

-- bikes contributes more to sales even if it is only 25% of the order.
--    accessories have the highest order percentage buy brings in only 2.3% of the revenue.
