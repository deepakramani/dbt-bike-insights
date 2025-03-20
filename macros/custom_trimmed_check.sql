{% macro test_custom_trimmed_check(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} != trim({{ column_name }})

{% endmacro %}