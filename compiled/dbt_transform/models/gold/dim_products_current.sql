WITH aggregated_product_data AS (
    SELECT
        prd_id AS product_id,
        prd_code AS product_code,
        prd_nm AS product_name,
        cat_id AS product_cat_id,
        erp_cat AS product_category,
        erp_subcat AS product_subcategory,
        erp_maintenance_status AS product_maintenance_status,
        prd_cost AS product_cost,
        prd_line AS product_line,
        prd_start_date AS product_start_date,
        prd_end_date AS product_end_date
    FROM "dwh"."snapshots"."products_snapshot"
    WHERE dbt_valid_to = '9999-12-31'
)
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,
    *
FROM aggregated_product_data