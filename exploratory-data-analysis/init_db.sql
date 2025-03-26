ATTACH 'dwh.duckdb' as db1;
-- DETACH db1;


SELECT * FROM duckdb_extensions();
INSTALL LOAD postgres;
SELECT * FROM duckdb_extensions();

export PGPASSWORD="secret"
export PGHOST=localhost
export PGUSER=owner
export PGDATABASE=mydatabase

ATTACH '' AS pg (TYPE postgres);
-- DETACH pg;
from pg.gold.dim_customers limit 10; -- to verify connection

--duckdb part
create schema if not exists gold;
create table gold.dim_customers as select * from pg.gold.dim_customers;
create table gold.dim_products as select * from pg.gold.dim_products;
create table gold.fact_sales as select * from pg.gold.fact_sales;
from gold.dim_products limit 10; -- to verify at duckdb side