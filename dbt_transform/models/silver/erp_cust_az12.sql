WITH source as (
    SELECT 
        *
    FROM {{ source('silver_source','erp_cust_az12') }}
),
cleaned_erp_cust as (
    SELECT 
        CASE
            WHEN cid LIKE 'NAS%' THEN Substr(cid, 4, Length(cid))
            ELSE cid
            END AS cid,
            CASE
            WHEN bdate > Now() :: DATE THEN NULL
            ELSE bdate
            END AS bdate,
            CASE
            WHEN Upper(Trim(gen)) IN ( 'M', 'MALE' ) THEN 'Male'
            WHEN Upper(Trim(gen)) IN ( 'F', 'FEMALE' ) THEN 'Female'
            ELSE 'n/a'
            END AS gen
    FROM source
)
SELECT 
    *,
    now() AS dwh_create_date 
FROM cleaned_erp_cust