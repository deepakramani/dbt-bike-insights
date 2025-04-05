



select
    1
from "dwh"."silver"."crm_sales_details"

where not(sls_quantity >= 0)

