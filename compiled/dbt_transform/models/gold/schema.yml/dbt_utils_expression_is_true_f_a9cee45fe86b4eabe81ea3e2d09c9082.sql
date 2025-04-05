



select
    1
from (select * from "dwh"."gold"."fact_sales" where sales_shipping_date IS NOT NULL AND sales_order_date IS NOT NULL) dbt_subquery

where not(sales_shipping_date >= sales_order_date)

