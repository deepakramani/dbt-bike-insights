
    
    



select dbt_scd_id
from "dwh"."snapshots"."customers_snapshot"
where dbt_scd_id is null


