WITH order_products AS (
    SELECT
        fs.sales_order_number,
        dp.product_category,
        COUNT(DISTINCT dp.product_key) AS product_count
    FROM {{ source('analytics_source','fact_sales') }} fs
    LEFT JOIN {{ source('analytics_source','dim_products_current') }} dp
        ON fs.product_key = dp.product_key
    WHERE fs.sales_order_date IS NOT NULL
    GROUP BY fs.sales_order_number, dp.product_category
),
product_pairs AS (
    SELECT
        a.product_category AS category_1,
        b.product_category AS category_2,
        COUNT(DISTINCT a.sales_order_number) AS order_count
    FROM order_products a
    JOIN order_products b
        ON a.sales_order_number = b.sales_order_number
        AND a.product_category < b.product_category  -- Avoid duplicates (e.g., Bikes-Accessories vs. Accessories-Bikes)
    GROUP BY a.product_category, b.product_category
),
total_orders AS (
    SELECT COUNT(DISTINCT sales_order_number) AS overall_orders
    FROM {{ source('analytics_source','fact_sales') }}
)
SELECT
    p.category_1,
    p.category_2,
    p.order_count,
    t.overall_orders,
    ROUND((p.order_count::FLOAT / t.overall_orders) * 100, 2) AS affinity_percentage
FROM product_pairs p
CROSS JOIN total_orders t
WHERE p.order_count > 10  -- Filter for meaningful pairs
ORDER BY p.order_count DESC;