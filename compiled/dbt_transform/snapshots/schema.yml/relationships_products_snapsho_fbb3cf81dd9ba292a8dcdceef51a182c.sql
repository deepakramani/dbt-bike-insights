
    
    

with child as (
    select cat_id as from_field
    from "dwh"."snapshots"."products_snapshot"
    where cat_id is not null
),

parent as (
    select id as to_field
    from "dwh"."silver"."erp_px_cat_g1v2"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


