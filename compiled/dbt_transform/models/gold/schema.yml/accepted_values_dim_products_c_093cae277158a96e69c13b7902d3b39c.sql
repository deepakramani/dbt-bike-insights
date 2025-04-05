
    
    

with all_values as (

    select
        product_line as value_field,
        count(*) as n_records

    from "dwh"."gold"."dim_products_current"
    group by product_line

)

select *
from all_values
where value_field not in (
    'Mountains','Road','Sales','Touring','n/a'
)


