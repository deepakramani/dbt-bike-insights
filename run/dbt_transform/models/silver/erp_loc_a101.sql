
      
  
    

  create  table "sql_dwh_db"."silver"."erp_loc_a101"
  
  
    as
  
  (
    
WITH source AS (
    SELECT
        * 
    FROM "sql_dwh_db"."bronze"."bz_erp_loc_a101"
),
cleaned_erp_loc as (
    SELECT
        replace (cid, '-', '') AS cid,
        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = ''
            OR TRIM(cntry) IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry,
        ingested_at,
        updated_at
    FROM source
)
SELECT 
    *
FROM cleaned_erp_loc


  );
  
  