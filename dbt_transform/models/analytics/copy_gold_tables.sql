/*
  Model: copy_gold_tables

  Description:
    Syncs gold-layer tables from PostgreSQL to DuckDB by invoking the `copy_all_from_postgres_gold` macro.
    Copies `fact_sales`, `dim_customers`, and `dim_products` from the Postgres `gold` schema to the DuckDB `gold` schema.
    Materializes a dummy table (`gold.copy_gold_tables`) with a single row to satisfy dbt.

  Dependencies:
    - Macro: `copy_all_from_postgres_gold` (defined in macros/copy_all_from_postgres_gold.sql).
    - Environment variables: POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_HOST, POSTGRES_PORT, POSTGRES_DB.
    - DuckDB `postgres_scanner` extension (auto-installed).

  Usage:
    Run via dbt: `dbt run --select copy_gold_tables --profile dbt_duckdb`

  Output:
    - Creates/replaces DuckDB tables: `gold.fact_sales`, `gold.dim_customers`, `gold.dim_products`.
    - Materializes `gold.copy_gold_tables` with one row (`status = 1`).
*/
{% if target.type == 'duckdb' %} -- for dbt docs generate errors
  {{ copy_all_from_postgres_gold([
      {'pg_schema': 'gold', 'pg_table': 'fact_sales', 'duckdb_schema': 'gold', 'duckdb_table': 'fact_sales'},
      {'pg_schema': 'gold', 'pg_table': 'dim_customers', 'duckdb_schema': 'gold', 'duckdb_table': 'dim_customers'},
      {'pg_schema': 'gold', 'pg_table': 'dim_products', 'duckdb_schema': 'gold', 'duckdb_table': 'dim_products'}
  ]) }}
{% else %}
  -- This query will be used for documentation generation but never executed
  SELECT 
      1 as placeholder_col
  WHERE FALSE
{% endif %}