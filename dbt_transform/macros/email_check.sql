{% macro test_email_check(model, col_name) %}

SELECT 
    *
FROM {{ model }}
WHERE {{ col_name }} ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'


{% endmacro %}