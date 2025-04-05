

select *
from "dwh"."silver"."crm_cust_info"
where cst_place != trim(cst_place)

