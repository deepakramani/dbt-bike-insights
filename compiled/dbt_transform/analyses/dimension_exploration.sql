/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- explore all the main categories of the products
WITH product_source as (
    SELECT * FROM "dwh"."gold"."dim_products_current"
)
select distinct product_category, product_subcategory, product_name
from product_source --gold.dim_products
order by 1,2,3;