{{
    config(
        unique_key='cid'
    )
}}
WITH source AS (
    SELECT
        * 
    FROM {{ ref('bz_erp_loc_a101') }}
),
cleaned_erp_loc as (
    SELECT
        replace (cid, '-', '') AS cid,
        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = ''
            OR TRIM(cntry) IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry,
        ingested_at,
        updated_at
    FROM source
)
SELECT 
    *
FROM cleaned_erp_loc

{% if is_incremental() %}
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}