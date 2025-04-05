
    
    



select dbt_valid_to
from "dwh"."snapshots"."products_snapshot"
where dbt_valid_to is null


