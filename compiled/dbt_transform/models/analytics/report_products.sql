/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale. use '2015-01-01' as current_date)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/


WITH dim_products_table AS (
    SELECT *
    FROM  "dwh"."gold"."dim_products_current"
),
fact_sales_table as (
    SELECT *
    FROM "dwh"."gold"."fact_sales"
),
product_base_query AS (
    SELECT
        dp.product_key,
        dp.product_code,
        dp.product_name,
        dp.product_cost,
        dp.product_category,
        dp.product_subcategory,
        dp.product_maintenance_status,
        fs.sales_order_date,
        fs.sales_quantity,
        fs.sales_order_number,
        fs.sales_amount,
        fs.customer_key
    FROM fact_sales_table fs
    left join dim_products_table dp on fs.product_key = dp.product_key
),
product_agg AS (
    SELECT
        row(
            product_key,
            product_code,
            product_name,
            product_cost,
            product_category,
            product_subcategory,
            product_maintenance_status
        )::analytics.product_struct
        AS product_info,
        sum(sales_amount) as total_sales,
        count(distinct sales_order_number) as total_orders,
        count(distinct customer_key) as total_customers,
        max(sales_order_date) as last_sale_date,
        date_diff('month', min(sales_order_date), max(sales_order_date)) as lifespan_in_month,
        avg(COALESCE(sales_amount/NULLIF(sales_quantity,0),0))::DECIMAL as avg_selling_price
    from product_base_query
    group by all
)
SELECT
    *,
    date_diff('month', last_sale_date, '2015-01-01'::DATE) AS recency_in_months,
    CASE
        WHEN recency_in_months BETWEEN 0 and 5 THEN 'Recently active'
        WHEN recency_in_months BETWEEN 6 and 12 THEN 'Moderately active'
        WHEN recency_in_months BETWEEN 13 and 24 THEN 'Possibly stagnate'
        ELSE 'Potentially discontinued/dormant'
    END AS recency_status,
	CASE
		WHEN total_sales > 50_000 THEN 'High-Performer'
		WHEN total_sales BETWEEN 10_000 AND 50_000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_status,
    -- Average Order Revenue (AOR)
	COALESCE(total_sales/NULLIF(total_orders,0), 0)::DECIMAL as avg_order_revenue,
	-- Average Monthly Revenue
    COALESCE(total_sales/NULLIF(lifespan_in_month,0), total_sales)::DECIMAL as avg_monthly_revenue
FROM product_agg