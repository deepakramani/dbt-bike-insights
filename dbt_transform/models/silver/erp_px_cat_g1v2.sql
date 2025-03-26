WITH source AS (
    SELECT
        * 
    FROM {{ source('silver_source','erp_px_cat_g1v2') }}
),
cleaned_prd_cat AS (
    SELECT
        TRIM(id) AS id,
        TRIM(cat) AS cat,
        TRIM(subcat) AS subcat,
        TRIM(maintenance) AS maintenance_status
    FROM source
)
SELECT 
    *,
    now() AS dwh_create_date
FROM cleaned_prd_cat