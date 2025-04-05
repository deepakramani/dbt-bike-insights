



select
    1
from "dwh"."gold"."dim_products_current"

where not(product_end_date >= product_start_date)

