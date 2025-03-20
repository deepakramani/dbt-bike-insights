WITH source AS (
    SELECT 
        *
    FROM {{ source('silver_source','crm_prd_info')}}
),
cleaned_prd_info AS (
    SELECT
        prd_id,
        REPLACE(SUBSTR(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTR(prd_key, 7, LENGTH(prd_key)) AS prd_key,
        prd_nm,
        COALESCE(prd_cost, 0) AS prd_cost,
        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountains'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_date
    FROM source
),
final_prd_info AS (
    SELECT
        *,
        LEAD(prd_start_date, 1) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_date
        ) - 1 AS prd_end_dt,
        now() as dwh_create_date
    FROM cleaned_prd_info
)
SELECT * FROM final_prd_info