
WITH source AS (
    SELECT 
        *,--(has ingested_at for incremental filtering)
        CURRENT_TIMESTAMP::TIMESTAMP AS updated_at -- for snapshot tracking
    FROM "sql_dwh_db"."raw"."raw_erp_px_cat_g1v2"
)
SELECT 
    *
FROM source
