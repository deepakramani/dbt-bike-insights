
    
    

with all_values as (

    select
        gen as value_field,
        count(*) as n_records

    from "dwh"."silver"."erp_cust_az12"
    group by gen

)

select *
from all_values
where value_field not in (
    'Male','Female','n/a'
)


