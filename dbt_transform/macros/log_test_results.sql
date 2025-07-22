{% macro log_test_results() %}
  {% if execute %}
    {% set results_query %}
      INSERT INTO {{ var('dbt_artifacts_database') }}.{{ var('dbt_artifacts_schema') }}.dbt_test_results 
      (invocation_id, unique_id, test_name, model_name, test_type, status, 
       rows_affected, execution_time_seconds, run_started_at, run_completed_at)
      VALUES 
      {% for result in results %}
        ('{{ invocation_id }}', '{{ result.node.unique_id }}', 
         '{{ result.node.name }}', '{{ result.node.refs[0].name if result.node.refs else "" }}',
         '{{ result.node.test_metadata.name if result.node.test_metadata else "singular" }}',
         '{{ result.status }}', {{ result.failures if result.failures else 0 }},
         {{ result.execution_time }}, '{{ result.timing[0].started_at }}', 
         '{{ result.timing[-1].completed_at }}')
         {%- if not loop.last -%},{%- endif -%}
      {% endfor %};
    {% endset %}
    {% do run_query(results_query) %}
  {% endif %}
{% endmacro %}