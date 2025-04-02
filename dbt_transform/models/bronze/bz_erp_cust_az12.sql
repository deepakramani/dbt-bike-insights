WITH source AS (
    SELECT 
        *,--(has ingested_at for incremental filtering)
        CURRENT_TIMESTAMP AS updated_at -- for snapshot tracking
    FROM {{ source('bronze_source', 'raw_erp_cust_az12') }}
)
SELECT 
    *
FROM source