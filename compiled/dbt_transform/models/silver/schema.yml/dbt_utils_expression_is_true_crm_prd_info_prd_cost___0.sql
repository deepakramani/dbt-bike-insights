



select
    1
from "dwh"."silver"."crm_prd_info"

where not(prd_cost >= 0)

