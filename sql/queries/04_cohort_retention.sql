-- Cohort retention
-- cohort = month of the customer's first purchase
-- month_number = how many months after the first purchase the customer bought again (0 = first month)

WITH orders AS (
    SELECT DISTINCT customer_id, strftime('%Y-%m', invoice_date) AS order_month
    FROM invoices
    WHERE is_cancelled = 0 AND customer_id IS NOT NULL
),
first_month AS (
    SELECT customer_id, MIN(order_month) AS cohort
    FROM orders
    GROUP BY customer_id
),
joined AS (
    SELECT
        f.cohort,
        o.customer_id,
        -- difference in months: year * 12 + month
        (substr(o.order_month, 1, 4) * 12 + substr(o.order_month, 6, 2))
          - (substr(f.cohort, 1, 4) * 12 + substr(f.cohort, 6, 2)) AS month_number
    FROM orders o
    JOIN first_month f ON f.customer_id = o.customer_id
)
SELECT
    cohort,
    month_number,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM first_month WHERE first_month.cohort = joined.cohort), 1) AS retention_pct
FROM joined
GROUP BY cohort, month_number
ORDER BY cohort, month_number;
