{% macro test_email_check(model, column_name) %}
SELECT 
    *
FROM {{ model }}
WHERE 
    {{ column_name }} IS NOT NULL
    AND {{ column_name }} != 'unknown'
    AND {{ column_name }} !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
{% endmacro %}