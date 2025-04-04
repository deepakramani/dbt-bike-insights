{{
    config(
        unique_key='sls_ord_num'
    )
}}
WITH source AS (
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
        WHEN sls_order_dt::VARCHAR ~ '^[0-9]{8}$' 
        THEN TO_DATE(sls_order_dt::VARCHAR, 'YYYYMMDD')
        ELSE NULL
    END AS sls_order_dt,
    CASE 
        WHEN sls_ship_dt::VARCHAR ~ '^[0-9]{8}$' 
        THEN TO_DATE(sls_ship_dt::VARCHAR, 'YYYYMMDD')
        ELSE NULL
    END AS sls_ship_dt,
    CASE 
        WHEN sls_due_dt::VARCHAR ~ '^[0-9]{8}$' 
        THEN TO_DATE(sls_due_dt::VARCHAR, 'YYYYMMDD')
        ELSE NULL
    END AS sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price,
    ingested_at,
    CURRENT_TIMESTAMP AS updated_at -- for snapshot tracking
    FROM {{ source('bronze_source', 'raw_crm_sales_details') }}
)
SELECT 
    *
FROM source
{% if is_incremental() %}
WHERE ingested_at > (SELECT MAX(ingested_at) FROM {{ this }})
{% endif %}