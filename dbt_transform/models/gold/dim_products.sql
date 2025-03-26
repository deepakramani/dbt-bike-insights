WITH product_data AS (
    SELECT *
    FROM {{ source('gold_source','crm_prd_info') }}
),
product_category_info AS (
    SELECT *
    FROM {{ source('gold_source','erp_px_cat_g1v2') }} 
), 
aggregated_product_data AS (
    SELECT
        pi.prd_id AS product_id,
        pi.prd_key AS product_key,
        pi.prd_nm AS product_name,
        pi.cat_id AS product_cat_id,
        pc.cat AS product_category,
        pc.subcat AS product_subcategory,
        pc.maintenance_status AS product_maintenance_status,
        pi.prd_cost AS product_cost,
        pi.prd_line AS product_line,
        pi.prd_start_date AS product_start_date
    FROM product_data pi
    LEFT JOIN product_category_info pc ON pi.cat_id = pc.id
    WHERE pi.prd_end_dt IS NULL -- filter out historical data
)
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_skey,
    *
FROM aggregated_product_data