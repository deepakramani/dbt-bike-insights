

select *
from "dwh"."gold"."dim_products_current"
where product_name != trim(product_name)

