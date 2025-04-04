{% snapshot products_snapshot %}
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
FROM {{ ref('crm_prd_info') }} AS pi
LEFT JOIN {{ ref('erp_px_cat_g1v2') }} AS pc
    ON pi.cat_id = pc.id
{% endsnapshot %}