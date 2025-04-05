
      
  
    

  create  table "sql_dwh_db"."snapshots"."customers_snapshot"
  
  
    as
  
  (
    
    

    select *,
        md5(coalesce(cast(cst_id as varchar ), '')
         || '|' || coalesce(cast(snapshot_updated_at as varchar ), '')
        ) as dbt_scd_id,
        snapshot_updated_at as dbt_updated_at,
        snapshot_updated_at as dbt_valid_from,
        
  
  coalesce(nullif(snapshot_updated_at, snapshot_updated_at), '9999-12-31'::timestamp)
  as dbt_valid_to
, 'False' as dbt_is_deleted
      from (
        

SELECT
    ci.cst_id,
    ci.cst_code,
    ci.cst_firstname,
    ci.cst_lastname,
    ea.bdate AS erp_birthdate,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_email,
    ci.cst_place,
    el.cntry AS erp_country,
    ci.cst_postal_code,
    ea.gen AS erp_gender,
    ci.cst_create_date,
    GREATEST(ci.updated_at, ea.updated_at, el.updated_at) AS snapshot_updated_at
FROM "sql_dwh_db"."silver"."crm_cust_info" ci
LEFT JOIN "sql_dwh_db"."silver"."erp_cust_az12" ea
    ON ci.cst_code = ea.cid
LEFT JOIN "sql_dwh_db"."silver"."erp_loc_a101" el
    ON ci.cst_code = el.cid

    ) sbq



  );
  
  