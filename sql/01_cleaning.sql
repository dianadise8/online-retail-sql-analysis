-- Cleaning the raw data
-- raw_sales -> clean_sales

-- What I remove:
--   - service codes that are not products (postage, bank charges, amazon fee, manual corrections...)
--   - rows with price 0 or less
--   - negative quantity on normal invoices (these are stock corrections, not returns)
--   - exact duplicate rows
-- What I keep:
--   - cancellations (invoice starts with 'C'), I need them for the returns analysis
--   - rows without Customer ID, they still count for revenue

DROP TABLE IF EXISTS clean_sales;

CREATE TABLE clean_sales AS
SELECT DISTINCT
    Invoice AS invoice_no,
    UPPER(TRIM(StockCode)) AS stock_code,
    UPPER(TRIM(Description)) AS description,
    Quantity AS quantity,
    InvoiceDate AS invoice_date,
    Price AS price,
    CAST("Customer ID" AS INTEGER) AS customer_id,   -- 17850.0 -> 17850
    TRIM(Country) AS country,
    CASE WHEN Invoice LIKE 'C%' THEN 1 ELSE 0 END AS is_cancelled
FROM raw_sales
WHERE UPPER(StockCode) NOT IN ('POST', 'DOT', 'M', 'D', 'C2', 'CRUK', 'S', 'B', 'PADS',
                               'BANK CHARGES', 'AMAZONFEE', 'ADJUST', 'ADJUST2')
  AND UPPER(StockCode) NOT LIKE 'GIFT%'
  AND UPPER(StockCode) NOT LIKE 'TEST%'
  AND Price > 0
  AND (Quantity > 0 OR Invoice LIKE 'C%');
