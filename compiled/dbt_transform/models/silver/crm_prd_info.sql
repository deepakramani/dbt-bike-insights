

WITH source_table AS (
    SELECT 
        *
    FROM "dwh"."bronze"."bz_crm_prd_info"
),
cleaned_data AS (
    SELECT
        prd_id,
        replace(substr(prd_key, 1,5),'-','_') as cat_id,
        substr(prd_key, 7, length(prd_key)) as prd_code,
        prd_nm,
        prd_cost,
        case
            when upper(trim(prd_line)) = 'M' then 'Mountains'
            when upper(trim(prd_line)) = 'R' then 'Road'
            when upper(trim(prd_line)) = 'S' then 'Sales'
            when upper(trim(prd_line)) = 'T' then 'Touring'
            else 'n/a'
        end as prd_line,
        CASE
            WHEN prd_start_dt IS NULL THEN '2006-01-01'  -- Default for missing start
            WHEN prd_end_dt IS NOT NULL AND prd_end_dt < prd_start_dt THEN prd_end_dt
            ELSE prd_start_dt
        END AS prd_start_date,
        CASE
            WHEN prd_end_dt IS NULL THEN '9999-12-31'  -- Default for missing end
            WHEN prd_end_dt < prd_start_dt THEN prd_start_dt
            ELSE prd_end_dt
        END AS prd_end_date,
        ingested_at, -- remove if irrelevant downstream
        updated_at
    FROM source_table
)
SELECT 
    *
FROM cleaned_data
