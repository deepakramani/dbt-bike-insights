{{ config(
    unique_key='prd_id'
) }}

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
    FROM {{ source('bronze_source', 'raw_crm_prd_info') }}
    WHERE prd_id IS NOT NULL
)
SELECT 
    *
FROM source
{% if is_incremental() %}
WHERE ingested_at > (SELECT MAX(ingested_at) FROM {{ this }})
{% endif %}