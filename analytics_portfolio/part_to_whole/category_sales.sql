---- part to whole. bikes contributes more to sales even if it is only 25% of the order.
-- --    accessories have the highest order percentage buy brings in only 2.3% of the revenue.

with category_sales_orders as (
select
    dp.product_category,
    sum(fs.sales_amount) as total_sales,
    count(fs.sales_order_number) as total_orders
from "dwh"."gold"."fact_sales" fs
left join "dwh"."gold"."dim_products_current" dp on fs.product_key = dp.product_key
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

WITH subcategory_sales_orders AS (
    SELECT
        dp.product_category,
        dp.product_subcategory,
        SUM(fs.sales_amount) AS total_sales,
        COUNT(DISTINCT fs.sales_order_number) AS total_orders,
        SUM(fs.sales_quantity) AS total_items,  -- Add items sold
        COUNT(DISTINCT fs.customer_key) AS total_customers,  -- Add unique customers
        ROUND(AVG(fs.sales_price), 2) AS avg_price_per_item  -- Add avg price per item
    FROM "dwh"."gold"."fact_sales" fs
    LEFT JOIN "dwh"."gold"."dim_products_current" dp
        ON fs.product_key = dp.product_key
    WHERE fs.sales_order_date IS NOT NULL
    GROUP BY dp.product_category, dp.product_subcategory
),
overall_calc AS (
    SELECT *,
        SUM(total_sales) OVER () AS overall_sales,
        SUM(total_orders) OVER () AS overall_orders,
        SUM(total_items) OVER () AS overall_items,
        SUM(total_customers) OVER () AS overall_customers
    FROM subcategory_sales_orders
)
SELECT
    product_category,
    product_subcategory,
    total_sales,
    total_orders,
    total_items,
    total_customers,
    overall_sales,
    overall_orders,
    overall_items,
    overall_customers,
    CONCAT(ROUND((total_sales::FLOAT / overall_sales) * 100, 2), '%') AS percentage_of_total_sales,
    CONCAT(ROUND((total_orders::FLOAT / overall_orders) * 100, 2), '%') AS percentage_of_orders,
    CONCAT(ROUND((total_items::FLOAT / overall_items) * 100, 2), '%') AS percentage_of_items,
    CONCAT(ROUND((total_customers::FLOAT / overall_customers) * 100, 2), '%') AS percentage_of_customers,
    ROUND(total_sales::FLOAT / total_orders, 2) AS avg_sales_per_order,
    avg_price_per_item
FROM overall_calc
ORDER BY total_sales DESC;