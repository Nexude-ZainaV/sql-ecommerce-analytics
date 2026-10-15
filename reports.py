"""Build the store database and run the analytical queries.

Usage:
    python reports.py                 # run every query, print result tables
    python reports.py 04 08           # run only queries whose file names start with 04 or 08
    python reports.py --db store.db   # also write the database to a file (open it in any SQLite tool)

Standard library only (sqlite3). Requires SQLite 3.35+ for window functions and
strftime; Python 3.12 ships a new enough version.
"""

from __future__ import annotations

import argparse
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SQL_DIR = ROOT / "sql"
QUERY_DIR = ROOT / "queries"


def build_database(path: str = ":memory:") -> sqlite3.Connection:
    """Create the schema, load the seed data and define the views, in file order."""
    connection = sqlite3.connect(path)
    for script in sorted(SQL_DIR.glob("*.sql")):
        connection.executescript(script.read_text(encoding="utf-8"))
    return connection


def query_files(prefixes: list[str] | None = None) -> list[Path]:
    """Query files in report order, optionally only those whose names start with a prefix."""
    files = sorted(QUERY_DIR.glob("*.sql"))
    if prefixes:
        files = [f for f in files if f.name.startswith(tuple(prefixes))]
    return files


def run_query(connection: sqlite3.Connection, path: Path) -> tuple[list[str], list[tuple]]:
    """Run one query file and return its column names and rows."""
    cursor = connection.execute(path.read_text(encoding="utf-8"))
    columns = [description[0] for description in cursor.description]
    return columns, cursor.fetchall()


def format_table(columns: list[str], rows: list[tuple]) -> str:
    """Render a result as a plain-text table with padded columns (NULL shows as blank)."""
    cells = [columns] + [["" if v is None else str(v) for v in row] for row in rows]
    widths = [max(len(row[i]) for row in cells) for i in range(len(columns))]
    lines = [" | ".join(value.ljust(width) for value, width in zip(row, widths, strict=True)) for row in cells]
    lines.insert(1, "-+-".join("-" * width for width in widths))
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("queries", nargs="*", help="query file prefixes, e.g. 01 04")
    parser.add_argument("--db", default=":memory:", help="write the database to this file")
    args = parser.parse_args()

    if args.db != ":memory:":
        Path(args.db).unlink(missing_ok=True)   # rebuild from scratch every time
    connection = build_database(args.db)
    for path in query_files(args.queries):
        columns, rows = run_query(connection, path)
        print(f"\n== {path.stem} ==\n{format_table(columns, rows)}")
    connection.close()


if __name__ == "__main__":
    main()
