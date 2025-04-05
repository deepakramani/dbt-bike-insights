



select
    1
from "dwh"."gold"."fact_sales"

where not(sales_order_date <= CURRENT_DATE)

