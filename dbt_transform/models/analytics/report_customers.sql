/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order. Use '2015-01-01' as current_date)
		- average order value
		- average monthly spend
===============================================================================
*/
{{ config(
    materialized='view',
    pre_hook=[
        "{{ create_customer_bio_struct() }}"
    ]
) }}

WITH dim_customers_table AS (
    SELECT *
    FROM {{ source('analytics_source','dim_customers') }}
),
fact_sales_table as (
    SELECT *
    FROM {{ source('analytics_source', 'fact_sales') }}
), 
customer_base_query as(
    SELECT
        CONCAT(dc.customer_firstname, ' ', dc.customer_lastname) as customer_name,
        dc.customer_key,
        dc.customer_birthdate,
        dc.customer_gender,
        dc.customer_country,
        dc.customer_marital_status,
        date_diff('year', dc.customer_birthdate, current_date()) as age_in_years,
        fs.product_skey,
        fs.sales_order_number,
        fs.sales_order_date,
        fs.sales_amount,
        fs.sales_quantity
    from fact_sales_table fs
    left join dim_customers_table dc on fs.customer_skey = dc.customer_skey
    where fs.sales_order_date is not null
),
customer_agg as (
    select
        row(customer_name,
            customer_key,
            age_in_years,
            customer_birthdate,
            customer_gender,
            customer_country,
            customer_marital_status)::analytics.customer_bio_struct
        as customer_bio,
        sum(sales_amount) as total_spending,
        count(distinct sales_order_number) as total_orders,
        sum(sales_quantity) as total_quantity,
        COUNT(DISTINCT product_skey) AS total_products,
	    MAX(sales_order_date) AS last_order_date,
	    date_diff('month', MIN(sales_order_date), MAX(sales_order_date)) AS lifespan_in_months
    from customer_base_query
    group by all
)
select
    customer_bio,
    CASE
        WHEN customer_bio.customer_age < 20 THEN 'LESS THAN 20'
        WHEN customer_bio.customer_age BETWEEN 20 and 29 THEN '20-29'
        WHEN customer_bio.customer_age BETWEEN 30 and 39 THEN '30-39'
        WHEN customer_bio.customer_age BETWEEN 40 and 49 THEN '40-49'
        WHEN customer_bio.customer_age BETWEEN 50 and 59 THEN '50-59'
        ELSE 'Above 60'
    END as age_group,
    lifespan_in_months,
    CASE
        WHEN lifespan_in_months >=12 AND total_spending > 5000 then 'VIP'
        WHEN lifespan_in_months >=12 AND total_spending <= 5000 then 'Regular'
        ELSE 'NEW'
    END as customer_status,
    last_order_date,
    date_diff('month', last_order_date, '2015-01-01'::DATE) as recency_in_months,
    CASE
        WHEN recency_in_months BETWEEN 0 and 3 THEN 'Recently active'
        WHEN recency_in_months BETWEEN 4 and 10 THEN 'Moderately active'
        WHEN recency_in_months BETWEEN 11 and 24 THEN 'Rarely active'
        ELSE 'Potentially inactive'
    END AS recency_status,
    total_orders,
    total_products,
    total_quantity,
    total_spending,
    -- Compute average order value (AVO)
    COALESCE(total_spending/NULLIF(total_orders,0),0)::DECIMAL as avg_order_value,
    -- compute average monthly spend
    COALESCE(total_spending/NULLIF(lifespan_in_months,0),total_orders)::DECIMAL as avg_monthly_spend,
from customer_agg
