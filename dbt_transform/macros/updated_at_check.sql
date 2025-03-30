{% macro test_updated_at_check(model, updated_at_column, start_date_column, end_date_column) %}
SELECT *
FROM {{ model }}
WHERE NOT (
    CASE
        WHEN {{ end_date_column }} != '2099-12-31'::DATE AND {{ end_date_column }} is not null THEN {{ updated_at_column }} > {{ end_date_column }}
        WHEN {{ end_date_column }} = '2099-12-31'::DATE AND {{ start_date_column }} is not null THEN {{ updated_at_column }} > {{ start_date_column }}
        ELSE TRUE
    END
)
{% endmacro %}