



select
    1
from (select * from "dwh"."gold"."fact_sales" where sales_amount IS NOT NULL) dbt_subquery

where not(sales_amount  >= 0)

