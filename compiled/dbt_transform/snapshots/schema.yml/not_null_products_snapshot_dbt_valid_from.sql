
    
    



select dbt_valid_from
from "dwh"."snapshots"."products_snapshot"
where dbt_valid_from is null


