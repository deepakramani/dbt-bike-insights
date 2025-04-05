
    
    



select dbt_updated_at
from "dwh"."snapshots"."products_snapshot"
where dbt_updated_at is null


