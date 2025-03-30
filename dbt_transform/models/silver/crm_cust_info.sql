WITH source AS (
    SELECT 
        *
    FROM {{ source('silver_source', 'crm_cust_info') }}
),
latest_customer AS (
    SELECT
        *,
        ROW_NUMBER() OVER ( PARTITION BY cst_id ORDER BY cst_create_date desc) as  flag_latest
    FROM
        source
    WHERE
        cst_id IS NOT NULL
), 
cleaned_customer AS (
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date::DATE as cst_create_date,
        cst_create_date + INTERVAL '1 day' as updated_at
    FROM
        latest_customer
    WHERE
        flag_latest = 1
)
SELECT
    *
FROM
    cleaned_customer