SELECT 
    fs.*
FROM {{ ref('fact_sales') }} fs
LEFT JOIN {{ ref('dim_customers') }} dc 
    ON dc.customer_skey = fs.customer_skey
LEFT JOIN {{ ref('dim_products') }} dp 
    ON dp.product_skey = fs.product_skey
WHERE 
    dc.customer_skey IS NULL 
    OR dp.product_skey IS NULL
