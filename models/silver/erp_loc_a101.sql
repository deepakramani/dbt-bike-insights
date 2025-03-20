WITH source AS (
    SELECT
        * 
    FROM {{ source('silver_source','erp_loc_a101') }}
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
        END AS cntry
    FROM source
)
SELECT 
    *,
    now() AS dwh_create_date 
FROM cleaned_erp_loc