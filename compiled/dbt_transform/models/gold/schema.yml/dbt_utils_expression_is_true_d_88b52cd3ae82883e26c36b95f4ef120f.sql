



select
    1
from "dwh"."gold"."dim_customers_hist"

where not(valid_to >= valid_from)

