
    
    

with child as (
    select customer_code as from_field
    from "dwh"."gold"."dim_customers_current"
    where customer_code is not null
),

parent as (
    select cid as to_field
    from "dwh"."silver"."erp_cust_az12"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


