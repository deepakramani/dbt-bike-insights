



select
    1
from (select * from "dwh"."gold"."dim_customers_hist" where customer_birthdate IS NOT NULL) dbt_subquery

where not(customer_birthdate <= CURRENT_DATE - INTERVAL '18 years')

