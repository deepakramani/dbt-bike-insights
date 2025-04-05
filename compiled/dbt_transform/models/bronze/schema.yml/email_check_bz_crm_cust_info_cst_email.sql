
SELECT 
    *
FROM "dwh"."bronze"."bz_crm_cust_info"
WHERE 
    cst_email IS NOT NULL
    AND cst_email != 'unknown'
    AND cst_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
