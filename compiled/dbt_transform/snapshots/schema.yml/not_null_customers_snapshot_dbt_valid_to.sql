
    
    



select dbt_valid_to
from "dwh"."snapshots"."customers_snapshot"
where dbt_valid_to is null


