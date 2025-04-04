{% snapshot customers_snapshot %}

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
FROM {{ ref('crm_cust_info') }} ci
LEFT JOIN {{ ref('erp_cust_az12') }} ea
    ON ci.cst_code = ea.cid
LEFT JOIN {{ ref('erp_loc_a101') }} el
    ON ci.cst_code = el.cid

{% endsnapshot %}