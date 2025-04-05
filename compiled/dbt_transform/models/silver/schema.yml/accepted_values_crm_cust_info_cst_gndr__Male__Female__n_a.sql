
    
    

with all_values as (

    select
        cst_gndr as value_field,
        count(*) as n_records

    from "dwh"."silver"."crm_cust_info"
    group by cst_gndr

)

select *
from all_values
where value_field not in (
    'Male','Female','n/a'
)


