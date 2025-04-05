

select *
from "dwh"."silver"."crm_sales_details"
where sls_ord_num != trim(sls_ord_num)

