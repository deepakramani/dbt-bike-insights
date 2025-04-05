



select
    1
from "dwh"."snapshots"."products_snapshot"

where not(prd_cost >= 0)

