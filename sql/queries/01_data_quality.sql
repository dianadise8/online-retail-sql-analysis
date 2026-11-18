-- What is wrong with the raw data and how many rows does each problem affect?
-- (one row can have more than one problem)

SELECT 'all rows' AS problem, COUNT(*) AS n_rows FROM raw_sales
UNION ALL
SELECT 'no Customer ID', COUNT(*) FROM raw_sales WHERE "Customer ID" IS NULL
UNION ALL
SELECT 'cancellation (kept)', COUNT(*) FROM raw_sales WHERE Invoice LIKE 'C%'
UNION ALL
SELECT 'price 0 or less', COUNT(*) FROM raw_sales WHERE Price <= 0
UNION ALL
SELECT 'negative quantity, not a cancellation', COUNT(*) FROM raw_sales
WHERE Quantity <= 0 AND Invoice NOT LIKE 'C%'
UNION ALL
SELECT 'service code, not a product', COUNT(*) FROM raw_sales
WHERE UPPER(StockCode) IN ('POST', 'DOT', 'M', 'D', 'C2', 'CRUK', 'S', 'B', 'PADS',
                           'BANK CHARGES', 'AMAZONFEE', 'ADJUST', 'ADJUST2')
   OR UPPER(StockCode) LIKE 'GIFT%' OR UPPER(StockCode) LIKE 'TEST%'
UNION ALL
SELECT 'exact duplicate', (SELECT COUNT(*) FROM raw_sales) - (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM raw_sales));
