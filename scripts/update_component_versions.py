#!/usr/bin/env python3
"""Generate a __COMPONENT_VERSIONS.yaml mapping of source files to their header versions.

Supports trilingual repos (Stata, Python, R) and Stata-only repos.
Auto-detects file types based on glob patterns and file extensions.

Usage:
    python scripts/update_component_versions.py                                    # stdout
    python scripts/update_component_versions.py -o r/doc/__COMPONENT_VERSIONS.yaml # write to file
"""
import argparse
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# File patterns to scan for version headers
PATTERNS = [
    "*.ado", "*.sthlp", "*.do",       # Stata
    "**/pyproject.toml",               # Python
    "**/__init__.py",                  # Python
    "**/*.py",                         # Python modules with version comments
    "**/DESCRIPTION",                  # R
    "**/*.cff",                        # Citation
    "**/stata.toc", "**/*.pkg",        # Stata package
]

# Skip directories that contain vendored or archived code
SKIP_DIRS = {"_archive", "node_modules", ".git", "__pycache__", "venv", ".venv"}

# --- Regex patterns (same as check_versions.py) ---

# Stata: *! v X.Y.Z  or  *! version X.Y.Z  (optionally with SMCL prefix: {* *! ...)
RE_ADO = re.compile(
    r"^\s*(?:\{\*\s*)?\*!\s*.*?\b(?:v|version)\b\s*([0-9]+(?:\.[0-9]+)*)",
    re.IGNORECASE,
)
RE_LEGACY = re.compile(
    r"^\s*(?:\{\*\s*)?\*!\s*v?\s*([0-9]+)(?:\s|$)",
    re.IGNORECASE,
)
RE_PYPROJECT = re.compile(r'^version\s*=\s*["\']([0-9]+(?:\.[0-9]+)*)["\']')
RE_PYVERSION = re.compile(r'^__version__\s*=\s*["\']([0-9]+(?:\.[0-9]+)*)["\']')
RE_RDESC = re.compile(r"^Version:\s*([0-9]+(?:\.[0-9]+)*)")
RE_CFF = re.compile(r"^version:\s*['\"]?([0-9]+(?:\.[0-9]+)*)")
RE_PKG = re.compile(r"^v\s+([0-9]+(?:\.[0-9]+)*)")
RE_RCOMMENT = re.compile(r"^#\s*Version:\s*([0-9]+(?:\.[0-9]+)*)")
RE_PYCOMMENT = re.compile(r"^#\s*Version:\s*([0-9]+(?:\.[0-9]+)*)")


def _should_skip(path: Path) -> bool:
    return any(d in path.parts for d in SKIP_DIRS)


def extract_version(path: Path):  # -> Optional[str]
    """Extract version from a file based on its type."""
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return None

    ext = path.suffix.lower()
    name = path.name

    if ext in {".ado", ".sthlp", ".do"}:
        return _scan(text, [RE_ADO, RE_LEGACY], legacy_idx=1)
    elif name == "pyproject.toml":
        return _scan(text, [RE_PYPROJECT])
    elif name == "__init__.py":
        return _scan(text, [RE_PYVERSION])
    elif name == "DESCRIPTION":
        return _scan(text, [RE_RDESC])
    elif ext == ".cff":
        return _scan_cff(text)
    elif ext in {".pkg", ".toc"}:
        first = text.splitlines()[0] if text.strip() else ""
        m = RE_PKG.match(first)
        return m.group(1) if m else None
    elif ext == ".py":
        return _scan(text, [RE_PYCOMMENT])
    elif ext == ".r" or ext == ".R":
        return _scan(text, [RE_RCOMMENT])
    return None


def _scan(text, patterns, legacy_idx=None):
    for line in text.splitlines()[:30]:
        for i, pat in enumerate(patterns):
            m = pat.match(line)
            if m:
                v = m.group(1)
                if legacy_idx is not None and i == legacy_idx:
                    return f"{v}.0.0"
                return v
    return None


def _scan_cff(text):
    for line in text.splitlines()[:30]:
        if line.strip().startswith("cff-version"):
            continue
        m = RE_CFF.match(line)
        if m:
            return m.group(1)
    return None


def classify(rel_path: str) -> str:
    """Classify a file into a section: package, stata, python, r, or other."""
    p = Path(rel_path)
    name = p.name

    # Package-level canonical version files
    if name in {"DESCRIPTION", "pyproject.toml", "CITATION.cff"} or name.endswith(".cff"):
        return "package"
    if name in {"stata.toc"} or name.endswith(".pkg"):
        return "package"
    if name == "__init__.py" and "unicefdata" in rel_path:
        return "package"

    # Platform classification by path or extension
    if "stata/" in rel_path or "src/" in rel_path:
        ext = p.suffix.lower()
        if ext in {".ado", ".sthlp", ".do", ".toc", ".pkg"}:
            return "stata"
    if "python/" in rel_path or p.suffix == ".py":
        return "python"
    if "r/" in rel_path.lower() or p.suffix.lower() == ".r":
        return "r"

    return "other"


def main():
    parser = argparse.ArgumentParser(description="Generate component versions manifest")
    parser.add_argument("-o", "--output", help="Write to file instead of stdout")
    args = parser.parse_args()

    # Collect files
    found = set()
    for pat in PATTERNS:
        for p in ROOT.glob(f"**/{pat}"):
            if not _should_skip(p):
                found.add(p)

    # Also scan for .R files with version comments
    for p in ROOT.glob("**/*.R"):
        if not _should_skip(p):
            found.add(p)

    # Extract versions and classify
    sections = {"package": [], "stata": [], "python": [], "r": []}
    for path in sorted(found):
        v = extract_version(path)
        if v:
            rel = path.relative_to(ROOT).as_posix()
            section = classify(rel)
            if section in sections:
                sections[section].append((rel, v))

    # Build output
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    lines = [
        "# Auto-generated component versions for wbopendata",
        f"# Generated: {now}",
        "# Generator: scripts/update_component_versions.py",
        "",
    ]

    section_labels = {
        "package": "Package-level versions",
        "stata": "STATA components",
        "python": "PYTHON components",
        "r": "R components",
    }
    for key in ["package", "stata", "python", "r"]:
        entries = sections[key]
        if not entries:
            continue
        lines.append(f"# ---- {section_labels[key]} ----")
        lines.append(f"{key}:")
        for rel, v in entries:
            lines.append(f"  {rel}: {v}")
        lines.append("")

    output = "\n".join(lines) + "\n"

    if args.output:
        Path(args.output).write_text(output, encoding="utf-8")
        print(f"Written to {args.output}")
    else:
        sys.stdout.write(output)


if __name__ == "__main__":
    main()
