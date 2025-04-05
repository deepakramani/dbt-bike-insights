

select *
from "dwh"."gold"."dim_customers_hist"
where customer_firstname != trim(customer_firstname)

