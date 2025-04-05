

select *
from "dwh"."silver"."crm_cust_info"
where cst_firstname != trim(cst_firstname)

