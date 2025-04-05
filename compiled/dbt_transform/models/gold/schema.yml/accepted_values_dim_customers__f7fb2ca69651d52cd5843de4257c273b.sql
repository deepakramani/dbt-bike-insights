
    
    

with all_values as (

    select
        customer_marital_status as value_field,
        count(*) as n_records

    from "dwh"."gold"."dim_customers_hist"
    group by customer_marital_status

)

select *
from all_values
where value_field not in (
    'Married','Single','n/a'
)


