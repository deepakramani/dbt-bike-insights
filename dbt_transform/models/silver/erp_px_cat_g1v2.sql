{{
    config(
        unique_key='id'
    )
}}
WITH source AS (
    SELECT
        * 
    FROM {{ ref('bz_erp_px_cat_g1v2') }}
),
cleaned_prd_cat AS (
    SELECT
        TRIM(id) AS id,
        TRIM(cat) AS cat,
        TRIM(subcat) AS subcat,
        TRIM(maintenance) AS maintenance_status,
        ingested_at,
        updated_at
    FROM source
)
SELECT 
    *
FROM cleaned_prd_cat
{% if is_incremental() %}
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}