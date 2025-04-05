

select *
from "dwh"."gold"."dim_products_hist"
where product_name != trim(product_name)

