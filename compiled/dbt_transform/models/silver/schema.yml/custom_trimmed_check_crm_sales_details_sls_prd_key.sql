

select *
from "dwh"."silver"."crm_sales_details"
where sls_prd_key != trim(sls_prd_key)

