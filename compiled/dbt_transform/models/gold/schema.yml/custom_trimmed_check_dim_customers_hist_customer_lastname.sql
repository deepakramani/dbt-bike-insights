

select *
from "dwh"."gold"."dim_customers_hist"
where customer_lastname != trim(customer_lastname)

