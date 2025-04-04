{% macro test_valid_date_format(model, column_name) %}
SELECT 
    *
FROM {{ model }}
WHERE 
    {{ column_name }} IS NOT NULL
    AND {{ column_name }}::TEXT !~ '^[0-9]{8}$'
{% endmacro %}