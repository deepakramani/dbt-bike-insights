{% macro create_product_struct() %}
  {% if not execute %}
    {{ return('') }}
  {% endif %}

  {% set check_type_sql %}
    SELECT 1 FROM duckdb_types WHERE type_name = 'product_struct' AND schema_name = 'analytics';
  {% endset %}

  {% set results = run_query(check_type_sql) %}

  {% if results.rows|length == 0 %}
    {% set create_type_sql %}
      CREATE SCHEMA IF NOT EXISTS analytics;
      CREATE TYPE analytics.product_struct AS STRUCT (
        product_key VARCHAR,
        product_code VARCHAR,
        product_name VARCHAR,
        product_cost INT,
        product_category VARCHAR,
        product_subcategory VARCHAR,
        product_maintenance_status VARCHAR
      );
    {% endset %}
    {% do run_query(create_type_sql) %}
  {% endif %}
{% endmacro %}