{% macro test_relationships_active_products(model, column_name, ref_model, ref_column) %}

WITH model_data AS (
    SELECT {{ column_name }} AS product_cat_id
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL
),

reference_data AS (
    SELECT DISTINCT {{ ref_column }} AS product_cat_id
    FROM {{ ref_model }}
    WHERE prd_end_dt IS NULL
),

invalid_records AS (
    SELECT md.*
    FROM model_data md
    LEFT JOIN reference_data rd 
    ON md.product_cat_id = rd.product_cat_id
    WHERE rd.product_cat_id IS NULL
)

SELECT * FROM invalid_records

{% endmacro %}
