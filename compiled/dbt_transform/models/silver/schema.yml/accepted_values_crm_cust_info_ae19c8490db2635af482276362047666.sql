
    
    

with all_values as (

    select
        cst_marital_status as value_field,
        count(*) as n_records

    from "dwh"."silver"."crm_cust_info"
    group by cst_marital_status

)

select *
from all_values
where value_field not in (
    'Married','Single','n/a'
)


