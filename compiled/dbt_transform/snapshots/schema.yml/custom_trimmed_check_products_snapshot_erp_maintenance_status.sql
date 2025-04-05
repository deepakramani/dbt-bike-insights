

select *
from "dwh"."snapshots"."products_snapshot"
where erp_maintenance_status != trim(erp_maintenance_status)

