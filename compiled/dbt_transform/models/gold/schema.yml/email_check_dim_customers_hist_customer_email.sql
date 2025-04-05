
SELECT 
    *
FROM "dwh"."gold"."dim_customers_hist"
WHERE 
    customer_email IS NOT NULL
    AND customer_email != 'unknown'
    AND customer_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
