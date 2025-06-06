{{ config(
    unique_key= 'cid'
) }}
WITH source AS (
    SELECT 
        *,--(has ingested_at for incremental filtering)
        CURRENT_TIMESTAMP::TIMESTAMP AS updated_at -- for snapshot tracking
    FROM {{ source('bronze_source', 'raw_erp_loc_a101') }}
)
SELECT 
    *
FROM source
{% if is_incremental() %}
WHERE ingested_at > (SELECT MAX(ingested_at) FROM {{ this }})
{% endif %}