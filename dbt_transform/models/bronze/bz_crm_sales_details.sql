WITH source AS (
    SELECT 
        *,--(has ingested_at for incremental filtering)
        CURRENT_TIMESTAMP AS updated_at -- for snapshot tracking
    FROM {{ source('bronze_source', 'raw_crm_sales_details') }}
)
SELECT 
    *
FROM source