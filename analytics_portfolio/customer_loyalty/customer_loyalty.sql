WITH customer_orders AS (
    SELECT
        fs.customer_key,
        COUNT(DISTINCT fs.sales_order_number) AS order_count,
        COUNT(DISTINCT fs.sales_order_date) AS unique_purchase_days,
        SUM(fs.sales_amount) AS total_spent,
        MIN(fs.sales_order_date) AS first_purchase_date,
        MAX(fs.sales_order_date) AS last_purchase_date
    FROM "dwh"."gold"."fact_sales" fs
    WHERE fs.sales_order_date IS NOT NULL
    GROUP BY fs.customer_key
)
SELECT
    customer_key,
    order_count,
    unique_purchase_days,
    total_spent,
    first_purchase_date,
    last_purchase_date,
    CASE
        WHEN order_count = 1 THEN 'One-Time'
        WHEN order_count BETWEEN 2 AND 5 THEN 'Occasional'
        WHEN order_count > 5 THEN 'Loyal'
    END AS loyalty_segment,
    ROUND(total_spent::FLOAT / order_count, 2) AS avg_spend_per_order
FROM customer_orders
ORDER BY order_count DESC;