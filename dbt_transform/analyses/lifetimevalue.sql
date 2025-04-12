WITH customer_ltv AS (
    SELECT
        fs.customer_key,
        SUM(fs.sales_amount) AS lifetime_value,
        COUNT(DISTINCT fs.sales_order_number) AS order_count,
        MIN(fs.sales_order_date) AS first_purchase_date,
        DATEDIFF('year', MIN(fs.sales_order_date), '2014-02-01') AS customer_tenure_years
    FROM {{ source('analytics_source', 'fact_sales') }} fs
    WHERE fs.sales_order_date IS NOT NULL
    GROUP BY fs.customer_key
),
ltv_distribution AS (
    SELECT
        customer_key,
        lifetime_value,
        order_count,
        customer_tenure_years,
        ROUND(lifetime_value::FLOAT / NULLIF(customer_tenure_years, 0), 2) AS avg_annual_value,
        NTILE(5) OVER (ORDER BY lifetime_value) AS ltv_quintile
    FROM customer_ltv
)
SELECT
    ltv_quintile,
    COUNT(customer_key) AS customer_count,
    ROUND(AVG(lifetime_value), 2) AS avg_ltv,
    ROUND(MIN(lifetime_value), 2) AS min_ltv,
    ROUND(MAX(lifetime_value), 2) AS max_ltv,
    ROUND(AVG(avg_annual_value), 2) AS avg_annual_ltv,
    ROUND(AVG(order_count), 2) AS avg_orders
FROM ltv_distribution
GROUP BY ltv_quintile
ORDER BY ltv_quintile;