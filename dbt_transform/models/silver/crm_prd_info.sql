WITH source_table AS (
    SELECT 
        *
    FROM {{ source('silver_source','crm_prd_info')}}
),
ranked_data AS (
    SELECT
        prd_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        CASE
            WHEN prd_end_dt IS NOT NULL AND prd_end_dt < prd_start_dt THEN prd_end_dt
        ELSE prd_start_dt
        END AS prd_start_date,
        CASE
            WHEN prd_end_dt IS NOT NULL AND prd_end_dt < prd_start_dt THEN prd_start_dt
            WHEN prd_end_dt IS NULL THEN '2099-12-31' -- Far Future Date
            ELSE prd_end_dt
        END AS prd_end_date,
        ROW_NUMBER() OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS rn
    FROM source_table
),
adjusted_dates as(
    SELECT
        rd.*,
        LAG(prd_end_date, 1) OVER (PARTITION BY prd_key ORDER BY prd_start_date) AS prev_end_dt
    FROM ranked_data rd
),
final_dates as (SELECT
    ad.prd_id,
    replace(substr(prd_key, 1,5),'-','_') as cat_id,
    substr(prd_key, 7, length(prd_key)) as prd_key,
    prd_nm,
    coalesce(prd_cost,0) as prd_cost,
    case
       when upper(trim(prd_line)) = 'M' then 'Mountains'
       when upper(trim(prd_line)) = 'R' then 'Road'
       when upper(trim(prd_line)) = 'S' then 'Sales'
       when upper(trim(prd_line)) = 'T' then 'Touring'
       else 'n/a'
    end as prd_line,
    CASE
        WHEN ad.prev_end_dt IS NOT NULL AND ad.prev_end_dt > ad.prd_start_date THEN ad.prev_end_dt -- - INTERVAL '1 day'
        ELSE ad.prd_start_date
    END AS prd_start_date,
    CASE
        WHEN ad.prev_end_dt IS NULL AND ad.prd_end_date <> '2099-12-31'::DATE
             THEN ad.prd_end_date - INTERVAL '1 minute'
        ELSE ad.prd_end_date
    END AS prd_end_date
    FROM adjusted_dates ad
    order by prd_id
)
select
    *,
    case
        when prd_end_date = '2099-12-31' then prd_start_date + interval '1' day
        else prd_end_date + interval '1' day
    end as updated_at
from final_dates