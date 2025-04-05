



select
    1
from (select * from "dwh"."silver"."crm_sales_details" where sls_order_dt IS NOT NULL AND sls_ship_dt IS NOT NULL AND sls_due_dt IS NOT NULL) dbt_subquery

where not(sls_order_dt <= sls_ship_dt AND sls_order_dt <= sls_due_dt)

