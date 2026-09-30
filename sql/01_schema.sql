-- 01_schema.sql - normalised (3NF) schema for a small online store.
-- Dialect: SQLite 3.35+. Money is stored in integer cents to avoid rounding drift.

PRAGMA foreign_keys = ON;

CREATE TABLE customers (
    id          INTEGER PRIMARY KEY,
    email       TEXT    NOT NULL UNIQUE,
    full_name   TEXT    NOT NULL,
    country     TEXT    NOT NULL,              -- ISO 3166-1 alpha-2
    created_at  TEXT    NOT NULL               -- ISO 8601 date
);

CREATE TABLE categories (
    id    INTEGER PRIMARY KEY,
    name  TEXT    NOT NULL UNIQUE
);

CREATE TABLE products (
    id             INTEGER PRIMARY KEY,
    sku            TEXT    NOT NULL UNIQUE,
    name           TEXT    NOT NULL,
    category_id    INTEGER NOT NULL REFERENCES categories (id),
    price_cents    INTEGER NOT NULL CHECK (price_cents > 0),
    stock_qty      INTEGER NOT NULL CHECK (stock_qty >= 0),
    reorder_level  INTEGER NOT NULL CHECK (reorder_level >= 0)
);

CREATE TABLE orders (
    id           INTEGER PRIMARY KEY,
    customer_id  INTEGER NOT NULL REFERENCES customers (id),
    ordered_at   TEXT    NOT NULL,             -- ISO 8601 date
    status       TEXT    NOT NULL
                 CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled'))
);

-- One row per product in an order. unit_price_cents is copied at purchase time so
-- later price changes do not rewrite order history.
CREATE TABLE order_items (
    order_id          INTEGER NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    product_id        INTEGER NOT NULL REFERENCES products (id),
    quantity          INTEGER NOT NULL CHECK (quantity > 0),
    unit_price_cents  INTEGER NOT NULL CHECK (unit_price_cents > 0),
    PRIMARY KEY (order_id, product_id)
);

-- Indexes for the foreign keys and the date filters the reports use.
CREATE INDEX ix_products_category   ON products (category_id);
CREATE INDEX ix_orders_customer     ON orders (customer_id);
CREATE INDEX ix_orders_ordered_at   ON orders (ordered_at);
CREATE INDEX ix_order_items_product ON order_items (product_id);
