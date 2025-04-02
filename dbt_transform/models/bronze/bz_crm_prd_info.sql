{{ config(
    unique_key='prd_id'
) }}

WITH source AS (
    SELECT 
        *,--(has ingested_at for incremental filtering)
        CURRENT_TIMESTAMP AS updated_at -- for snapshot tracking
    FROM {{ source('bronze_source', 'raw_crm_prd_info') }}
)
SELECT 
    *
FROM source
{% if is_incremental() %}
WHERE ingested_at > (SELECT MAX(ingested_at) FROM {{ this }})
{% endif %}