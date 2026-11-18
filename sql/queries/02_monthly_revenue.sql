-- Revenue by month, cancellations and growth compared to the previous month

WITH monthly AS (
    SELECT
        strftime('%Y-%m', i.invoice_date) AS month,
        SUM(CASE WHEN i.is_cancelled = 0 THEN it.quantity * it.price ELSE 0 END) AS revenue,
        SUM(CASE WHEN i.is_cancelled = 1 THEN -it.quantity * it.price ELSE 0 END) AS cancelled,
        COUNT(DISTINCT i.invoice_no) AS n_invoices
    FROM invoices i
    JOIN invoice_items it ON it.invoice_no = i.invoice_no
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue) AS revenue,
    ROUND(cancelled) AS cancelled,
    ROUND(100.0 * cancelled / revenue, 1) AS cancel_pct,
    n_invoices,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month), 1) AS growth_pct
FROM monthly
ORDER BY month;
