{{ config(
    depends_on=['{{ ref("dim_customers") }}', '{{ ref("dim_products") }}']
) }}

WITH customer_dim AS (
    SELECT *
    FROM {{ ref('dim_customers') }}
),
products_dim AS (
    SELECT *
    FROM {{ ref('dim_products') }}
),
source_sales_data AS (
    SELECT *
    FROM {{ source('gold_source', 'crm_sales_details') }}
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
        dp.product_skey,
        dc.customer_skey
    FROM source_sales_data sd
    LEFT JOIN customer_dim dc ON sd.sls_cust_id = dc.customer_id
    LEFT JOIN products_dim dp ON sd.sls_prd_key = dp.product_key
)
SELECT
    MD5(sales_order_number || product_skey::VARCHAR || customer_skey::VARCHAR) AS sales_details_skey,
    product_skey,
    customer_skey,
    sales_order_number,
    sales_order_date,
    sales_shipping_date,
    sales_due_date,
    sales_amount,
    sales_quantity,
    sales_price
FROM aggregated_sales_data