
    
    

with all_values as (

    select
        cntry as value_field,
        count(*) as n_records

    from "dwh"."silver"."erp_loc_a101"
    group by cntry

)

select *
from all_values
where value_field not in (
    'Australia','Canada','France','Germany','United Kingdom','United States','n/a'
)


