



select
    1
from "dwh"."gold"."dim_products_current"

where not(product_cost >= 0)

