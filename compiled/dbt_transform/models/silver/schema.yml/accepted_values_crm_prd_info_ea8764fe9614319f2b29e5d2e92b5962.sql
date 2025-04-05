
    
    

with all_values as (

    select
        prd_line as value_field,
        count(*) as n_records

    from "dwh"."silver"."crm_prd_info"
    group by prd_line

)

select *
from all_values
where value_field not in (
    'Mountains','Road','Sales','Touring','n/a'
)


