



select
    1
from "dwh"."gold"."dim_products_hist"

where not(product_cost >= 0)

