

select *
from "dwh"."gold"."dim_customers_current"
where customer_lastname != trim(customer_lastname)

