{{ config(
    unique_key= 'cid'
) }}

WITH source as (
    SELECT 
        *
    FROM {{ ref('bz_erp_cust_az12') }}

),
cleaned_erp_cust as (
    SELECT 
        CASE
            WHEN cid LIKE 'NAS%' THEN Substr(cid, 4, Length(cid))
            ELSE cid
            END AS cid,
            CASE
            WHEN bdate > CURRENT_DATE THEN NULL
            ELSE bdate
            END AS bdate,
            CASE
            WHEN Upper(Trim(gen)) IN ( 'M', 'MALE' ) THEN 'Male'
            WHEN Upper(Trim(gen)) IN ( 'F', 'FEMALE' ) THEN 'Female'
            ELSE 'n/a'
            END AS gen,
            ingested_at,
            updated_at
    FROM source
)
SELECT 
    *
FROM cleaned_erp_cust
{% if is_incremental() %}
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}