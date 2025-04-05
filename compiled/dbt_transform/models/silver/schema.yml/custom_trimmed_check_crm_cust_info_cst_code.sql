

select *
from "dwh"."silver"."crm_cust_info"
where cst_code != trim(cst_code)

