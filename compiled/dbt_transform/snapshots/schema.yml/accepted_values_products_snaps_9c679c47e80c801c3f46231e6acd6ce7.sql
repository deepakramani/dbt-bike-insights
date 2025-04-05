
    
    

with all_values as (

    select
        erp_maintenance_status as value_field,
        count(*) as n_records

    from "dwh"."snapshots"."products_snapshot"
    group by erp_maintenance_status

)

select *
from all_values
where value_field not in (
    'Yes','No'
)


