SELECT
    YEAR (sales_order_date) AS order_year,
    --month(sales_order_date) as order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_quantity) AS total_items,
FROM
    "dwh"."gold"."fact_sales"
    -- where sales_order_date is not null
GROUP BY
    order_year --, order_month
ORDER BY
    order_year;

-- product category sales BY YEAR
WITH
    sales_by_category AS (
        SELECT
            YEAR (fs.sales_order_date) AS order_year,
            dp.product_category,
            SUM(fs.sales_quantity) AS total_items
        FROM
            "dwh"."gold"."fact_sales" fs
            LEFT JOIN "dwh"."gold"."dim_products_current" dp ON fs.product_key = dp.product_key
        WHERE
            fs.sales_order_date IS NOT NULL
        GROUP BY
            order_year,
            dp.product_category
    )
SELECT
    order_year,
    SUM(
        CASE
            WHEN product_category = 'Bikes' THEN total_items
            ELSE 0
        END
    ) AS bike_items,
    SUM(
        CASE
            WHEN product_category = 'Components' THEN total_items
            ELSE 0
        END
    ) AS component_items,
    SUM(
        CASE
            WHEN product_category = 'Accessories' THEN total_items
            ELSE 0
        END
    ) AS accessory_items,
    SUM(total_items) AS total_items
FROM
    sales_by_category
GROUP BY
    order_year
ORDER BY
    order_year;


-- BEST sells month
with monthly_sales as (select
--     year(sales_order_date) as order_year,
    month(sales_order_date) as order_month,
    sum(sales_amount) as total_sales,
    count(distinct customer_key) as total_customers,
    sum(sales_quantity) as total_items,
from  "dwh"."gold"."fact_sales"
where sales_order_date is not null
group by order_month
order by order_month
),
ranked_months as (SELECT
    order_month,
    total_sales,
    total_customers,
    total_items,
    RANK() OVER (ORDER BY total_sales desc) AS sales_rank,
    RANK() OVER (ORDER BY total_customers desc) AS customer_rank
FROM monthly_sales
)
SELECT order_month as 'best_selling_month', total_sales, total_customers, total_items
FROM ranked_months
WHERE sales_rank=1 or customer_rank=1
ORDER BY sales_rank, customer_rank;

--Worst sells month
with monthly_sales as (select
--     year(sales_order_date) as order_year,
    month(sales_order_date) as order_month,
    sum(sales_amount) as total_sales,
    count(distinct customer_key) as total_customers,
    sum(sales_quantity) as total_items,
from  "dwh"."gold"."fact_sales"
where sales_order_date is not null
group by order_month
order by order_month
),
ranked_months as (SELECT
    order_month,
    total_sales,
    total_customers,
    total_items,
    RANK() OVER (ORDER BY total_sales) AS sales_rank,
    RANK() OVER (ORDER BY total_customers) AS customer_rank
FROM monthly_sales
)
SELECT order_month as 'worst_selling_month', total_sales, total_customers, total_items
FROM ranked_months
WHERE sales_rank=1 or customer_rank=1
ORDER BY sales_rank, customer_rank;