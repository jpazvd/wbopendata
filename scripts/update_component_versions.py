#!/usr/bin/env python3
"""Generate a COMPONENT_VERSIONS.yaml mapping of source files to their header versions.

Usage: python scripts/update_component_versions.py > src/_/__COMPONENT_VERSIONS.yaml
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATTERNS = ["*.ado", "*.sthlp", "*.md", "*.toc", "*.cff", "*.yaml"]

RE_ADO = re.compile(r"^\s*\*!.*?v\s*([0-9]+(?:\.[0-9]+)*)", re.IGNORECASE)
RE_VERSION = re.compile(r"^\s*version:\s*[\'\"]?([0-9]+(?:\.[0-9]+)*)", re.IGNORECASE)
RE_LEGACY = re.compile(r"^\s*\*!\s*v?\s*([0-9]+)(?:\s|$)")

def extract_version(path: Path):
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return None
    for line in text.splitlines()[:20]:
        m = RE_ADO.match(line)
        if m:
            return m.group(1)
        m2 = RE_VERSION.match(line)
        if m2:
            return m2.group(1)
        m3 = RE_LEGACY.match(line)
        if m3:
            # normalize legacy single-number versions to semver-like
            return f"{m3.group(1)}.0.0"
    return None

def main():
    files = []
    for pat in PATTERNS:
        files.extend(ROOT.glob(f"**/{pat}"))
    files = sorted(set(files))
    out = []
    out.append("# Auto-generated component versions\n")
    out.append("components:")
    for f in files:
        v = extract_version(f)
        if v:
            rel = f.relative_to(ROOT).as_posix()
            out.append(f"  {rel}: {v}")
    sys.stdout.write("\n".join(out) + "\n")

if __name__ == '__main__':
    main()
