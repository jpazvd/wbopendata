from __future__ import annotations

import argparse
from pathlib import Path

REPLACEMENTS = {
    "â€s": "’s",
    "â€™": "’",
    "â€œ": "“",
    "â€�": "”",
    "â€”": "—",
    "â€“": "–",
}


def fix_text(text: str) -> str:
    for bad, good in REPLACEMENTS.items():
        text = text.replace(bad, good)
    return text


def main() -> int:
    parser = argparse.ArgumentParser(description="Fix mojibake in Stata YAML outputs")
    parser.add_argument("path", help="Path to Stata YAML file to fix")
    args = parser.parse_args()

    path = Path(args.path)
    text = path.read_text(encoding="cp1252", errors="replace")
    fixed = fix_text(text)
    path.write_text(fixed, encoding="utf-8", newline="\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
