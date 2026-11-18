-- RFM segments
-- R = days since last purchase, F = number of orders, M = money spent
-- R and M get a score 1-5 with NTILE (5 = best).
-- For F I used fixed limits, because most customers have 1 order and
-- NTILE would split people with the same number of orders into different groups.

WITH rfm AS (
    SELECT
        i.customer_id,
        -- "today" = the day after the last invoice in the data (2011-12-10)
        CAST(julianday('2011-12-10') - julianday(MAX(i.invoice_date)) AS INTEGER) AS recency,
        COUNT(DISTINCT i.invoice_no) AS frequency,
        SUM(it.quantity * it.price) AS monetary
    FROM invoices i
    JOIN invoice_items it ON it.invoice_no = i.invoice_no
    WHERE i.is_cancelled = 0 AND i.customer_id IS NOT NULL
    GROUP BY i.customer_id
),
scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r,
        CASE
            WHEN frequency >= 10 THEN 5
            WHEN frequency >= 5 THEN 4
            WHEN frequency >= 3 THEN 3
            WHEN frequency = 2 THEN 2
            ELSE 1
        END AS f,
        NTILE(5) OVER (ORDER BY monetary) AS m
    FROM rfm
),
segments AS (
    SELECT
        *,
        CASE
            WHEN r >= 4 AND f >= 4 THEN 'Champions'
            WHEN r >= 3 AND f >= 3 THEN 'Loyal'
            WHEN r >= 4 AND f = 1 THEN 'New'
            WHEN r >= 3 THEN 'Potential loyalists'
            WHEN f >= 3 THEN 'At risk'
            ELSE 'Hibernating'
        END AS segment
    FROM scores
)
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM segments), 1) AS pct_customers,
    ROUND(AVG(recency)) AS avg_recency,
    ROUND(AVG(frequency), 1) AS avg_orders,
    ROUND(AVG(monetary)) AS avg_spent,
    ROUND(100.0 * SUM(monetary) / (SELECT SUM(monetary) FROM segments), 1) AS pct_revenue
FROM segments
GROUP BY segment
ORDER BY pct_revenue DESC;
