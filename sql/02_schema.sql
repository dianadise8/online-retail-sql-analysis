-- Splitting the big table into 4 tables:
-- customers - invoices - invoice_items - products

DROP TABLE IF EXISTS invoice_items;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    country TEXT
);

CREATE TABLE products (
    stock_code TEXT PRIMARY KEY,
    description TEXT
);

CREATE TABLE invoices (
    invoice_no TEXT PRIMARY KEY,
    customer_id INTEGER,          -- can be empty (guest customer)
    invoice_date TEXT,
    country TEXT,
    is_cancelled INTEGER,         -- 1 = cancellation
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);

CREATE TABLE invoice_items (
    item_id INTEGER PRIMARY KEY,
    invoice_no TEXT,
    stock_code TEXT,
    quantity INTEGER,             -- negative for cancellations
    price REAL,
    FOREIGN KEY (invoice_no) REFERENCES invoices (invoice_no),
    FOREIGN KEY (stock_code) REFERENCES products (stock_code)
);

-- indexes, otherwise the joins are slow
CREATE INDEX idx_items_invoice ON invoice_items (invoice_no);
CREATE INDEX idx_items_product ON invoice_items (stock_code);
