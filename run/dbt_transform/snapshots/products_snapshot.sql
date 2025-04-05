
      
  
    

  create  table "sql_dwh_db"."snapshots"."products_snapshot"
  
  
    as
  
  (
    
    

    select *,
        md5(coalesce(cast(prd_id as varchar ), '')
         || '|' || coalesce(cast(snapshot_updated_at as varchar ), '')
        ) as dbt_scd_id,
        snapshot_updated_at as dbt_updated_at,
        snapshot_updated_at as dbt_valid_from,
        
  
  coalesce(nullif(snapshot_updated_at, snapshot_updated_at), '9999-12-31'::timestamp)
  as dbt_valid_to
, 'False' as dbt_is_deleted
      from (
        
SELECT 
    pi.prd_id,
    pi.prd_code,
    pi.cat_id,
    pc.cat AS erp_cat,
    pc.subcat AS erp_subcat,
    pi.prd_nm,
    pi.prd_line,
    pi.prd_cost,
    pc.maintenance_status AS erp_maintenance_status,
    pi.prd_start_date,
    pi.prd_end_date,
    GREATEST(pi.updated_at, pc.updated_at) AS snapshot_updated_at
FROM "sql_dwh_db"."silver"."crm_prd_info" AS pi
LEFT JOIN "sql_dwh_db"."silver"."erp_px_cat_g1v2" AS pc
    ON pi.cat_id = pc.id
    ) sbq



  );
  
  