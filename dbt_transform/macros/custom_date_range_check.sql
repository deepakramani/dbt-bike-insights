{% macro test_custom_date_range_check(model, column_name, min_date, max_date, expected_count) %}

SELECT COUNT(*) AS num_violations
FROM {{ model }}
WHERE {{ column_name }} IS NULL
   OR {{ column_name }} < '{{ min_date }}'
   OR {{ column_name }} > '{{ max_date }}'
HAVING COUNT(*) != {{ expected_count }}

{% endmacro %}
