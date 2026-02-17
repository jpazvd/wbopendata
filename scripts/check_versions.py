#!/usr/bin/env python3
"""Check that modified ADO files in a git diff have an updated header version.

Usage: python scripts/check_versions.py <base-ref>

This script expects to run in a git repo. It will compare the header version
for each modified file against the version on <base-ref> and exit non-zero if
any modified file does not have an increased version.
"""
import re
import subprocess
import sys
from pathlib import Path

RE_ADO = re.compile(r"^\s*\*!.*?v\s*([0-9]+(?:\.[0-9]+)*)", re.IGNORECASE)
RE_LEGACY = re.compile(r"^\s*\*!\s*v?\s*([0-9]+)(?:\s|$)")

ROOT = Path(__file__).resolve().parents[1]


def extract_version(text):
    for line in text.splitlines()[:20]:
        m = RE_ADO.match(line)
        if m:
            return m.group(1)
        m3 = RE_LEGACY.match(line)
        if m3:
            return f"{m3.group(1)}.0.0"
    return None


def git_cat(ref, path):
    p = subprocess.run(["git", "show", f"{ref}:{path}"], capture_output=True, text=True)
    if p.returncode != 0:
        return None
    return p.stdout


def main():
    if len(sys.argv) < 2:
        print("Usage: check_versions.py <base-ref>")
        return 2
    base = sys.argv[1]
    p = subprocess.run(["git", "diff", "--name-only", base, "HEAD"], capture_output=True, text=True)
    files = [l.strip() for l in p.stdout.splitlines() if l.strip()]
    failures = []
    for f in files:
        ppath = Path(f)
        if not ppath.exists():
            continue
        text_new = ppath.read_text(encoding="utf-8", errors="ignore")
        v_new_raw = extract_version(text_new)
        old_text = git_cat(base, f)
        v_old_raw = extract_version(old_text) if old_text else None

        # If neither old nor new contain a version header, skip the file
        if v_old_raw is None and v_new_raw is None:
            continue

        # Default missing headers to 0.0.0 for comparison purposes
        v_old = v_old_raw or "0.0.0"
        v_new = v_new_raw or "0.0.0"

        # simple compare by tuple
        try:
            t_old = tuple(int(x) for x in v_old.split('.')[:3])
            t_new = tuple(int(x) for x in v_new.split('.')[:3])
        except Exception:
            failures.append((f, v_old, v_new))
            continue

        if t_new <= t_old:
            failures.append((f, v_old, v_new))
    if failures:
        print("Version check failed for modified files:")
        for f, old, new in failures:
            print(f" - {f}: {old} -> {new}")
        return 1
    print("All modified files have version bumps.")
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
