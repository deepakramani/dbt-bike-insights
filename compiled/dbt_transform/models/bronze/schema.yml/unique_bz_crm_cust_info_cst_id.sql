
    
    

select
    cst_id as unique_field,
    count(*) as n_records

from "dwh"."bronze"."bz_crm_cust_info"
where cst_id is not null
group by cst_id
having count(*) > 1


