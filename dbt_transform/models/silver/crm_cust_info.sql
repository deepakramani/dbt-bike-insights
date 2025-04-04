{{ config(
    unique_key= 'cst_id'
) }}
WITH source AS (
    SELECT 
        *
    FROM {{ ref('bz_crm_cust_info') }}
),
cleaned_customer AS (
    SELECT
        cst_id,
        cst_key AS cst_code,
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
        COALESCE(TRIM(cst_email), 'unknown') AS cst_email,
        COALESCE(cst_place, 'unknown') AS cst_place,
        COALESCE(TRIM(CAST(cst_postal_code AS VARCHAR)), 'unknown') AS cst_postal_code,
        ingested_at,
        updated_at
    FROM
        source
)
SELECT
    *
FROM
    cleaned_customer

{% if is_incremental() %}
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}