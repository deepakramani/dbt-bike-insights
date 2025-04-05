
    
    



select dbt_updated_at
from "dwh"."snapshots"."customers_snapshot"
where dbt_updated_at is null


