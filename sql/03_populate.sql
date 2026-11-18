-- Filling the 4 tables from clean_sales

-- customers
-- 8 customers have 2 countries, for them I just take one (MAX)
INSERT INTO customers (customer_id, country)
SELECT customer_id, MAX(country)
FROM clean_sales
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

-- products
-- some codes have several descriptions (typos, small changes),
-- so I take the description that appears most often
INSERT INTO products (stock_code, description)
SELECT stock_code, description
FROM (
    SELECT
        stock_code,
        description,
        ROW_NUMBER() OVER (PARTITION BY stock_code ORDER BY COUNT(*) DESC) AS rn
    FROM clean_sales
    GROUP BY stock_code, description
)
WHERE rn = 1;

-- invoices
-- some invoices have rows with a 1 minute difference in time, so I take the first time
INSERT INTO invoices (invoice_no, customer_id, invoice_date, country, is_cancelled)
SELECT invoice_no, MAX(customer_id), MIN(invoice_date), MAX(country), MAX(is_cancelled)
FROM clean_sales
GROUP BY invoice_no;

-- invoice lines
INSERT INTO invoice_items (invoice_no, stock_code, quantity, price)
SELECT invoice_no, stock_code, quantity, price
FROM clean_sales;
