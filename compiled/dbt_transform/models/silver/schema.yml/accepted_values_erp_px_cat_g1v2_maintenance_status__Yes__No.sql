
    
    

with all_values as (

    select
        maintenance_status as value_field,
        count(*) as n_records

    from "dwh"."silver"."erp_px_cat_g1v2"
    group by maintenance_status

)

select *
from all_values
where value_field not in (
    'Yes','No'
)


