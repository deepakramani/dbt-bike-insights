



select
    1
from (select * from "dwh"."gold"."fact_sales" where sales_quantity IS NOT NULL) dbt_subquery

where not(sales_quantity >= 0)

