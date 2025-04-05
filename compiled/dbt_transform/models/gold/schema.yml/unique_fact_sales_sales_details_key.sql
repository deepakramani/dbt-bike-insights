
    
    

select
    sales_details_key as unique_field,
    count(*) as n_records

from "dwh"."gold"."fact_sales"
where sales_details_key is not null
group by sales_details_key
having count(*) > 1


