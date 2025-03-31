{% macro copy_all_from_postgres_gold(tables) %}
    {%- for table in tables %}
        {%- set pg_schema = table.pg_schema -%}
        {%- set pg_table = table.pg_table -%}
        {%- set duckdb_schema = table.duckdb_schema -%}
        {%- set duckdb_table = table.duckdb_table -%}
        {% set sql %}
            CREATE SCHEMA IF NOT EXISTS gold;
            DROP TABLE IF EXISTS {{ duckdb_schema }}.{{ duckdb_table }};
            CREATE TABLE {{ duckdb_schema }}.{{ duckdb_table }} AS
            SELECT * 
            FROM postgres_scan(
                'postgresql://{{ env_var('POSTGRES_USER') }}:{{ env_var('POSTGRES_PASSWORD') }}@{{ env_var('POSTGRES_HOST') }}:{{ env_var('POSTGRES_PORT') }}/{{ env_var('POSTGRES_DB') }}',
                '{{ pg_schema }}',
                '{{ pg_table }}'
            )
        {% endset %}
        {%- do run_query(sql) -%}
    {% endfor %}
    -- Return a dummy result to satisfy dbt
    SELECT 1 AS status
{% endmacro %}