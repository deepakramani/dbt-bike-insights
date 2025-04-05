
    
    

with all_values as (

    select
        customer_gender as value_field,
        count(*) as n_records

    from "dwh"."gold"."dim_customers_current"
    group by customer_gender

)

select *
from all_values
where value_field not in (
    'Male','Female','n/a'
)


