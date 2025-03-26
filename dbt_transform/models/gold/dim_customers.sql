WITH customer_basic_data AS (
    SELECT *
    FROM {{ source('gold_source','crm_cust_info') }}
),
customer_erp_data AS (
    SELECT *
    FROM {{ source('gold_source','erp_cust_az12') }} 
), 
customer_erp_location AS (
    SELECT *
    FROM {{ source('gold_source','erp_loc_a101') }} 
),
aggregated_customer_data AS (
    SELECT
        ci.cst_id AS customer_id,
        ci.cst_key AS customer_key,
        ci.cst_firstname AS customer_firstname,
        ci.cst_lastname AS customer_lastname,
        ca.bdate AS customer_birthdate,
        CASE
            WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
            ELSE COALESCE(ca.gen, 'n/a')
        END AS customer_gender,
        ci.cst_marital_status AS customer_marital_status,
        la.cntry AS customer_country,
        ci.cst_create_date AS customer_create_date
    FROM customer_basic_data AS ci
    LEFT JOIN customer_erp_data ca ON ci.cst_key= ca.cid
    LEFT JOIN customer_erp_location la ON ci.cst_key = la.cid
)
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_skey,
    *
FROM aggregated_customer_data