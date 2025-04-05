
    
    

select
    product_key as unique_field,
    count(*) as n_records

from "dwh"."gold"."dim_products_hist"
where product_key is not null
group by product_key
having count(*) > 1


