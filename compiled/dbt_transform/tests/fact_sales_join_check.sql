SELECT 
    fs.*
FROM "dwh"."gold"."fact_sales" fs
LEFT JOIN "dwh"."gold"."dim_customers_current" dc 
    ON dc.customer_key = fs.customer_key
LEFT JOIN "dwh"."gold"."dim_products_current" dp 
    ON dp.product_key = fs.product_key
WHERE 
    dc.customer_key IS NULL 
    OR dp.product_key IS NULL