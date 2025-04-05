



select
    1
from "dwh"."silver"."crm_prd_info"

where not(prd_end_date >= prd_start_date)

