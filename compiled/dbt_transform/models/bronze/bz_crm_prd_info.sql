

WITH source AS (
    SELECT 
        prd_id,
        prd_key,
        prd_nm,
        COALESCE(prd_cost, 0) AS prd_cost,  -- Schema evolution
        prd_line,
        prd_start_dt,
        prd_end_dt,
        ingested_at,
        CURRENT_TIMESTAMP::TIMESTAMP AS updated_at -- for snapshot tracking
    FROM "sql_dwh_db"."raw"."raw_crm_prd_info"
    WHERE prd_id IS NOT NULL
)
SELECT 
    *
FROM source
