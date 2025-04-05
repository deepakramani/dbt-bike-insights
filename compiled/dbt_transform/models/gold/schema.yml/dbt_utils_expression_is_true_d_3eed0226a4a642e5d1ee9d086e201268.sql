



select
    1
from "dwh"."gold"."dim_products_hist"

where not(valid_to >= valid_from)

