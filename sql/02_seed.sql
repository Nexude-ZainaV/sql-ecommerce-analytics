-- 02_seed.sql - small, hand-written dataset (January to June 2026).
-- Small enough to check every report by hand; varied enough to exercise edge cases:
-- a product never sold, a customer who never ordered, cancelled and pending orders,
-- out-of-stock items and a month with falling revenue.

INSERT INTO categories (id, name) VALUES
    (1, 'Electronics'),
    (2, 'Books'),
    (3, 'Home'),
    (4, 'Sports');

INSERT INTO products (id, sku, name, category_id, price_cents, stock_qty, reorder_level) VALUES
    (1,  'EL-001', 'Wireless Mouse',                        1,  2499, 40, 15),
    (2,  'EL-002', 'Mechanical Keyboard',                   1,  8999,  8, 10),
    (3,  'EL-003', 'USB-C Hub',                             1,  3999, 25, 10),
    (4,  'EL-004', 'Noise-Cancelling Headphones',           1, 19999,  5,  5),
    (5,  'BK-001', 'Clean Code',                            2,  3499, 12,  5),
    (6,  'BK-002', 'Designing Data-Intensive Applications', 2,  4599,  3,  5),
    (7,  'BK-003', 'The Pragmatic Programmer',              2,  3999, 20,  5),
    (8,  'HM-001', 'Desk Lamp',                             3,  2999, 30, 10),
    (9,  'HM-002', 'Ergonomic Chair',                       3, 24999,  4,  3),
    (10, 'HM-003', 'Standing Desk Mat',                     3,  4999,  0,  5),
    (11, 'SP-001', 'Yoga Mat',                              4,  2599, 18,  8),
    (12, 'SP-002', 'Resistance Bands',                      4,  1499, 50, 10);

INSERT INTO customers (id, email, full_name, country, created_at) VALUES
    (1, 'maria.santos@example.com', 'Maria Santos',  'PH', '2025-12-02'),
    (2, 'james.lee@example.com',    'James Lee',     'US', '2025-12-15'),
    (3, 'aisha.khan@example.com',   'Aisha Khan',    'GB', '2026-01-05'),
    (4, 'lucas.martin@example.com', 'Lucas Martin',  'CA', '2026-01-20'),
    (5, 'sofia.rossi@example.com',  'Sofia Rossi',   'IT', '2026-02-03'),
    (6, 'kenji.sato@example.com',   'Kenji Sato',    'JP', '2026-02-18'),
    (7, 'emma.brown@example.com',   'Emma Brown',    'US', '2026-03-09'),
    (8, 'noah.garcia@example.com',  'Noah Garcia',   'US', '2026-04-11');   -- never orders

INSERT INTO orders (id, customer_id, ordered_at, status) VALUES
    (1,  1, '2026-01-08', 'delivered'),
    (2,  2, '2026-01-14', 'delivered'),
    (3,  3, '2026-01-22', 'delivered'),
    (4,  1, '2026-02-03', 'delivered'),
    (5,  4, '2026-02-10', 'delivered'),
    (6,  2, '2026-02-19', 'cancelled'),
    (7,  5, '2026-02-25', 'delivered'),
    (8,  3, '2026-03-04', 'delivered'),
    (9,  6, '2026-03-12', 'delivered'),
    (10, 1, '2026-03-20', 'delivered'),
    (11, 7, '2026-03-28', 'shipped'),
    (12, 2, '2026-04-02', 'delivered'),
    (13, 5, '2026-04-15', 'delivered'),
    (14, 4, '2026-04-27', 'cancelled'),
    (15, 6, '2026-05-06', 'delivered'),
    (16, 1, '2026-05-18', 'shipped'),
    (17, 7, '2026-05-29', 'paid'),
    (18, 3, '2026-06-03', 'shipped'),
    (19, 2, '2026-06-17', 'paid'),
    (20, 5, '2026-06-26', 'pending');

INSERT INTO order_items (order_id, product_id, quantity, unit_price_cents) VALUES
    (1,  1, 1,  2499), (1,  5, 1,  3499),
    (2,  2, 1,  8999), (2,  3, 1,  3999),
    (3,  7, 2,  3999),
    (4,  8, 2,  2999), (4, 11, 1,  2599),
    (5,  4, 1, 19999),
    (6,  9, 1, 24999),
    (7,  6, 1,  4599), (7,  5, 1,  3499), (7, 7, 1, 3999),
    (8,  1, 2,  2499),
    (9,  9, 1, 24999), (9,  8, 1,  2999),
    (10, 3, 1,  3999), (10, 10, 1, 4999),
    (11, 11, 2, 2599),
    (12, 4, 1, 19999), (12, 1, 1,  2499),
    (13, 6, 1,  4599),
    (14, 2, 1,  8999),
    (15, 2, 1,  8999), (15, 10, 2, 4999),
    (16, 7, 1,  3999),
    (17, 8, 1,  2999), (17, 11, 1, 2599),
    (18, 5, 1,  3499), (18, 3, 2,  3999),
    (19, 9, 1, 24999),
    (20, 1, 3,  2499);
