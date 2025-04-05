
    
    



select dbt_valid_from
from "dwh"."snapshots"."customers_snapshot"
where dbt_valid_from is null


