

select *
from "dwh"."gold"."dim_customers_current"
where customer_firstname != trim(customer_firstname)

