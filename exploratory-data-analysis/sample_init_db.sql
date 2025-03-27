ATTACH 'dwh.duckdb' as dwh;
DETACH dwh;


SELECT * FROM duckdb_extensions();
INSTALL postgres;
LOAD postgres;
unload postgres;
UNINSTALL postgres_scanner;
SELECT * FROM duckdb_extensions();

export PGPASSWORD="secret"
export PGHOST=localhost
export PGUSER=owner
export PGDATABASE=mydatabase

ATTACH '' AS pg (TYPE postgres);
DETACH pg;
from pg.gold.dim_customers limit 10; -- to verify connection

--duckdb part
drop schema if exists gold cascade;
create schema if not exists db1.gold;
create table db1.gold.dim_customers as select * from pg.gold.dim_customers;
create table db1.gold.dim_products as select * from pg.gold.dim_products;
create table db1.gold.fact_sales as select * from pg.gold.fact_sales;
from db1.gold.dim_products limit 10; -- to verify at duckdb side