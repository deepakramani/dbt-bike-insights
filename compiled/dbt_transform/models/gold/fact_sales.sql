

WITH customer_dim AS (
    SELECT *
    FROM "dwh"."gold"."dim_customers_current"
),
products_dim AS (
    SELECT *
    FROM "dwh"."gold"."dim_products_current"
),
source_sales_data AS (
    SELECT *
    FROM "dwh"."silver"."crm_sales_details"
),
aggregated_sales_data AS (
    SELECT
        sd.sls_ord_num AS sales_order_number,
        sd.sls_order_dt AS sales_order_date,
        sd.sls_ship_dt AS sales_shipping_date,
        sd.sls_due_dt AS sales_due_date,
        sd.sls_sales AS sales_amount,
        sd.sls_quantity AS sales_quantity,
        sd.sls_price AS sales_price,
        dp.product_key,
        dc.customer_key
    FROM source_sales_data sd
    LEFT JOIN customer_dim dc ON sd.sls_cust_id = dc.customer_id
    LEFT JOIN products_dim dp ON sd.sls_prd_key = dp.product_code
)
SELECT
    MD5(COALESCE(sales_order_number, '') || COALESCE(product_key::VARCHAR, '0') || COALESCE(customer_key::VARCHAR, '0')) AS sales_details_key,  -- Fixed name and null handling
    product_key,
    customer_key,
    sales_order_number,
    sales_order_date,
    sales_shipping_date,
    sales_due_date,
    sales_amount,
    sales_quantity,
    sales_price
FROM aggregated_sales_data