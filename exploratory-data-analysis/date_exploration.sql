ATTACH 'dwh.duckdb' as db1;

-- date exploration
/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

--find the first and last order date
select 
  min(sales_order_date) as first_order_date,
  max(sales_order_date) as last_order_date
from gold.fact_sales;

-- find the oldest and youngest customers and their age, difference
select 
  min(customer_birthdate) as oldest_customer, 
  date_diff('year', min(customer_birthdate), current_date) as oldest_age,
  max(customer_birthdate) as youngest_customer,
  date_diff('year', max(customer_birthdate), current_date) as youngest_age,
  age(min(customer_birthdate)) as oldest_age1_pg,--, max(customer_birthdate))
  date_part('year', min(customer_birthdate)) as oldest_year_pg,
  extract(year from age(max(customer_birthdate),min(customer_birthdate))) as diff_age_pg
  -- date_part('year', max(customer_birthdate) - min(customer_birthdate)) as youngest_age1
from gold.dim_customers;


-- how many years of sales are available
select 
  min(sales_order_date) as first_ord_date,
  max(sales_order_date) as last_ord_date,
  date_diff('year', min(sales_order_date),max(sales_order_date)) as order_range_years,
  date_diff('month', min(sales_order_date),max(sales_order_date)) as order_range_months,
from gold.fact_sales;

DETACH db1;