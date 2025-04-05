
    
    

select
    cst_email as unique_field,
    count(*) as n_records

from "dwh"."silver"."crm_cust_info"
where cst_email is not null
group by cst_email
having count(*) > 1


