
SELECT 
    *
FROM "dwh"."bronze"."bz_crm_sales_details"
WHERE 
    sls_ship_dt IS NOT NULL
    AND sls_ship_dt::TEXT !~ '^[0-9]{8}$'
