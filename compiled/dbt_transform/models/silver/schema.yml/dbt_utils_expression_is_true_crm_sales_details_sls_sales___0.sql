



select
    1
from "dwh"."silver"."crm_sales_details"

where not(sls_sales >= 0)

