"""Tests for the SQL reports.

Two kinds of checks:
  * snapshot tests: each query's output must equal tests/expected/<query>.csv
    (regenerate with: UPDATE_SNAPSHOTS=1 python -m unittest discover -s tests, then review the diff)
  * invariant tests: facts that must hold whatever the data, e.g. per-category revenue
    adds up to total revenue, and every schema constraint rejects bad rows.

Run:  python -m unittest discover -s tests -v
"""

from __future__ import annotations

import csv
import io
import os
import sqlite3
import sys
import unittest
from pathlib import Path

# Make reports.py importable when the tests run from the repo root.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from reports import build_database, query_files, run_query  # noqa: E402

EXPECTED_DIR = Path(__file__).resolve().parent / "expected"
UPDATE_SNAPSHOTS = os.environ.get("UPDATE_SNAPSHOTS") == "1"


def to_csv(columns: list[str], rows: list[tuple]) -> str:
    """Serialise a result exactly the way the snapshot files are written."""
    buffer = io.StringIO()
    writer = csv.writer(buffer, lineterminator="\n")
    writer.writerow(columns)
    writer.writerows(rows)
    return buffer.getvalue()


class SnapshotTests(unittest.TestCase):
    def setUp(self) -> None:
        self.db = build_database()

    def tearDown(self) -> None:
        self.db.close()

    def test_every_query_matches_its_snapshot(self) -> None:
        files = query_files()
        self.assertEqual(len(files), 10)
        for path in files:
            with self.subTest(query=path.stem):
                actual = to_csv(*run_query(self.db, path))
                snapshot = EXPECTED_DIR / f"{path.stem}.csv"
                if UPDATE_SNAPSHOTS:
                    snapshot.parent.mkdir(exist_ok=True)
                    snapshot.write_text(actual, encoding="utf-8", newline="\n")
                self.assertEqual(actual, snapshot.read_text(encoding="utf-8"))


class InvariantTests(unittest.TestCase):
    def setUp(self) -> None:
        self.db = build_database()

    def tearDown(self) -> None:
        self.db.close()

    def scalar(self, sql: str) -> object:
        return self.db.execute(sql).fetchone()[0]

    def test_category_revenue_sums_to_total(self) -> None:
        total = self.scalar("SELECT SUM(order_cents) FROM v_order_totals")
        by_category = self.scalar(
            "SELECT SUM(c) FROM (SELECT SUM(line_cents) AS c FROM v_sales_lines GROUP BY category_id)"
        )
        self.assertEqual(total, by_category)

    def test_views_exclude_cancelled_and_pending_orders(self) -> None:
        excluded = self.scalar(
            "SELECT COUNT(*) FROM v_order_totals t JOIN orders o ON o.id = t.order_id"
            " WHERE o.status IN ('cancelled', 'pending')"
        )
        self.assertEqual(excluded, 0)

    def test_running_total_ends_at_total_revenue(self) -> None:
        _, rows = run_query(self.db, query_files(["01"])[0])
        total = self.scalar("SELECT ROUND(SUM(order_cents) / 100.0, 2) FROM v_order_totals")
        self.assertEqual(rows[-1][3], total)

    def test_clv_percentages_sum_to_100(self) -> None:
        _, rows = run_query(self.db, query_files(["04"])[0])
        self.assertAlmostEqual(sum(row[5] for row in rows), 100.0, delta=0.5)

    def test_schema_rejects_invalid_rows(self) -> None:
        bad_statements = [
            "INSERT INTO orders (customer_id, ordered_at, status) VALUES (1, '2026-07-01', 'lost')",
            "INSERT INTO orders (customer_id, ordered_at, status) VALUES (999, '2026-07-01', 'paid')",
            "INSERT INTO products (sku, name, category_id, price_cents, stock_qty, reorder_level)"
            " VALUES ('X-1', 'Free', 1, 0, 1, 1)",
            "INSERT INTO customers (email, full_name, country, created_at)"
            " VALUES ('maria.santos@example.com', 'Dup', 'PH', '2026-01-01')",
            "INSERT INTO order_items VALUES (1, 1, 1, 2499)",  # duplicate (order, product)
        ]
        for statement in bad_statements:
            with self.subTest(statement=statement), self.assertRaises(sqlite3.IntegrityError):
                self.db.execute(statement)


if __name__ == "__main__":
    unittest.main()
