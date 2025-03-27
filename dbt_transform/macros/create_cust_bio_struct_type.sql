{% macro create_customer_bio_struct() %}
  {% if not execute %}
    {{ return('') }}
  {% endif %}

  {% set check_type_sql %}
    SELECT 1 FROM duckdb_types WHERE type_name = 'customer_bio_struct' AND schema_name = 'analytics';
  {% endset %}

  {% set results = run_query(check_type_sql) %}

  {% if results.rows|length == 0 %}
    {% set create_type_sql %}
      CREATE SCHEMA IF NOT EXISTS analytics;
      CREATE TYPE analytics.customer_bio_struct AS STRUCT (
        customer_name VARCHAR,
        customer_key VARCHAR,
        customer_age INT,
        customer_birthdate DATE,
        customer_gender VARCHAR,
        customer_country VARCHAR,
        customer_marital_status VARCHAR
      );
    {% endset %}
    {% do run_query(create_type_sql) %}
  {% endif %}
{% endmacro %}