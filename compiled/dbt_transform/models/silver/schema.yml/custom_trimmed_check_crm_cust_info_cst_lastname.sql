

select *
from "dwh"."silver"."crm_cust_info"
where cst_lastname != trim(cst_lastname)

