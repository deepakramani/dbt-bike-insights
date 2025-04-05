
    
    

with all_values as (

    select
        product_maintenance_status as value_field,
        count(*) as n_records

    from "dwh"."gold"."dim_products_current"
    group by product_maintenance_status

)

select *
from all_values
where value_field not in (
    'Yes','No'
)


