
WITH deduped AS (
    SELECT 
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date,
        CASE 
            WHEN COALESCE(unaccent(email), 'unknown') = 'unknown' THEN 'unknown'
            ELSE REGEXP_REPLACE(
                LOWER(
                    -- Remove spaces in the local part (before @)
                    REGEXP_REPLACE(
                        COALESCE(unaccent(email), 'unknown'),
                        '([^@]+)( )([^@]*@.*)',
                        '\1.\3'
                    )
                ),
                ' ',
                '.'
            )
        END AS cst_email, -- schema evolution
        COALESCE(place_of_residence, NULL) AS cst_place,
        COALESCE(postal_code, NULL) AS cst_postal_code,
        ingested_at,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY ingested_at DESC, cst_create_date DESC) AS rn
    FROM "sql_dwh_db"."raw"."raw_crm_cust_info"
    WHERE cst_id IS NOT NULL
)
SELECT 
    *,
    CURRENT_TIMESTAMP::TIMESTAMP AS updated_at -- for snapshot tracking. Typecasting to avoid timezone
FROM deduped
WHERE rn = 1
