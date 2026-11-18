-- Which popular products are returned most often?
-- only products with 1000+ units sold, otherwise one return of a rare product looks like a huge %

WITH product_totals AS (
    SELECT
        p.stock_code,
        p.description,
        SUM(CASE WHEN i.is_cancelled = 0 THEN it.quantity ELSE 0 END) AS sold,
        SUM(CASE WHEN i.is_cancelled = 1 THEN -it.quantity ELSE 0 END) AS returned
    FROM invoice_items it
    JOIN invoices i ON i.invoice_no = it.invoice_no
    JOIN products p ON p.stock_code = it.stock_code
    GROUP BY p.stock_code, p.description
)
SELECT
    stock_code,
    description,
    sold,
    returned,
    ROUND(100.0 * returned / sold, 1) AS return_pct
FROM product_totals
WHERE sold >= 1000
ORDER BY return_pct DESC
LIMIT 15;
