
WITH source AS (
    SELECT 
        *,--(has ingested_at for incremental filtering)
        CURRENT_TIMESTAMP::TIMESTAMP AS updated_at -- for snapshot tracking
    FROM "sql_dwh_db"."raw"."raw_erp_cust_az12"
    WHERE cid IS NOT NULL  -- Basic validation
)
SELECT 
    *
FROM source
