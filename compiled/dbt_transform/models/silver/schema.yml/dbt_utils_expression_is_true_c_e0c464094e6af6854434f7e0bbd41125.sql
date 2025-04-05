



select
    1
from "dwh"."silver"."crm_sales_details"

where not(ABS(sls_sales - (sls_quantity * sls_price)) < 0.01)

