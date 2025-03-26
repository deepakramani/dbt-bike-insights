ATTACH 'dwh.duckdb' as db1;

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
select distinct product_category, product_subcategory, product_name
from gold.dim_products
order by 1,2,3;



DETACH db1;