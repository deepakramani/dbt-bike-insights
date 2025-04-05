WITH customers_snapshot_h AS (
    SELECT 
        cst_id,
        cst_code,
        cst_firstname,
        cst_lastname,
        erp_birthdate,
        cst_marital_status,
        cst_gndr,
        cst_email,
        cst_place,
        erp_country,
        cst_postal_code,
        erp_gender,
        cst_create_date,
        dbt_valid_from,
        dbt_valid_to
    FROM "dwh"."snapshots"."customers_snapshot"
),
aggregated_customer_data AS (
    SELECT
        cst_id AS customer_id,
        cst_code AS customer_code,
        cst_firstname AS customer_firstname,
        cst_lastname AS customer_lastname,
        erp_birthdate AS customer_birthdate,
        CASE
            WHEN cst_gndr != 'n/a' THEN cst_gndr
            ELSE COALESCE(erp_gender, 'n/a')
        END AS customer_gender,
        cst_marital_status AS customer_marital_status,
        erp_country AS customer_country,
        cst_email AS customer_email,
        cst_place AS customer_place,
        cst_postal_code AS customer_postal_code,
        cst_create_date AS customer_create_date,
        dbt_valid_from AS valid_from,
        dbt_valid_to AS valid_to
    FROM customers_snapshot_h
)
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id, valid_from) AS customer_key,
    *
FROM aggregated_customer_data