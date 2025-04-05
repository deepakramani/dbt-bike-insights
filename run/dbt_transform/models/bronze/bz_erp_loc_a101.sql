
      
  
    

  create  table "sql_dwh_db"."bronze"."bz_erp_loc_a101"
  
  
    as
  
  (
    
WITH source AS (
    SELECT 
        *,--(has ingested_at for incremental filtering)
        CURRENT_TIMESTAMP::TIMESTAMP AS updated_at -- for snapshot tracking
    FROM "sql_dwh_db"."raw"."raw_erp_loc_a101"
)
SELECT 
    *
FROM source

  );
  
  