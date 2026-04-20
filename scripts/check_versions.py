#!/usr/bin/env python3
"""Check that modified source files in a git diff have an updated header version.

Supports trilingual repos (Stata, Python, R) as well as Stata-only repos.
Auto-detects file types — no configuration needed.

Usage:
    python scripts/check_versions.py <base-ref>
    python scripts/check_versions.py <base-ref> --check-consistency

Exit codes:
    0  All checks passed
    1  Version bump or consistency failures detected
    2  Usage error
"""
import re
import subprocess
import sys
from pathlib import Path

# --- Regex patterns by file type ---

# Stata: *! v X.Y.Z  or  *! version X.Y.Z  (optionally with SMCL prefix: {* *! ...)
RE_ADO = re.compile(
    r"^\s*(?:\{\*\s*)?\*!\s*.*?\b(?:v|version)\b\s*([0-9]+(?:\.[0-9]+)*)",
    re.IGNORECASE,
)
RE_LEGACY = re.compile(
    r"^\s*(?:\{\*\s*)?\*!\s*v?\s*([0-9]+)(?:\s|$)",
    re.IGNORECASE,
)

# Python pyproject.toml: version = "X.Y.Z"
RE_PYPROJECT = re.compile(r'^version\s*=\s*["\']([0-9]+(?:\.[0-9]+)*)["\']')

# Python __init__.py: __version__ = "X.Y.Z"
RE_PYVERSION = re.compile(r'^__version__\s*=\s*["\']([0-9]+(?:\.[0-9]+)*)["\']')

# R DESCRIPTION: Version: X.Y.Z
RE_RDESC = re.compile(r"^Version:\s*([0-9]+(?:\.[0-9]+)*)")

# CITATION.cff: version: X.Y.Z (but NOT cff-version:)
RE_CFF = re.compile(r"^version:\s*['\"]?([0-9]+(?:\.[0-9]+)*)")

# Stata .pkg / .toc first line: v X.Y.Z
RE_PKG = re.compile(r"^v\s+([0-9]+(?:\.[0-9]+)*)")

ROOT = Path(__file__).resolve().parents[1]

# File extensions and names that can contain version headers
VERSION_EXTS = {".ado", ".sthlp", ".do", ".toml", ".py", ".cff", ".pkg", ".toc"}
VERSION_NAMES = {"DESCRIPTION"}


def extract_version(text, filepath):
    """Extract version string from file content, dispatching by file type."""
    p = Path(filepath)
    ext = p.suffix.lower()
    name = p.name

    if ext in {".ado", ".sthlp", ".do"}:
        return _extract_ado(text)
    elif name == "pyproject.toml" or (ext == ".toml" and "version" in text[:500]):
        return _extract_pyproject(text)
    elif ext == ".py":
        return _extract_pyversion(text)
    elif name == "DESCRIPTION":
        return _extract_rdesc(text)
    elif ext == ".cff":
        return _extract_cff(text)
    elif ext in {".pkg", ".toc"}:
        return _extract_pkg(text)
    return None


def _extract_ado(text):
    for line in text.splitlines()[:20]:
        m = RE_ADO.match(line)
        if m:
            return m.group(1)
        m3 = RE_LEGACY.match(line)
        if m3:
            return f"{m3.group(1)}.0.0"
    return None


def _extract_pyproject(text):
    for line in text.splitlines()[:30]:
        m = RE_PYPROJECT.match(line)
        if m:
            return m.group(1)
    return None


def _extract_pyversion(text):
    for line in text.splitlines()[:20]:
        m = RE_PYVERSION.match(line)
        if m:
            return m.group(1)
    return None


def _extract_rdesc(text):
    for line in text.splitlines()[:30]:
        m = RE_RDESC.match(line)
        if m:
            return m.group(1)
    return None


def _extract_cff(text):
    for line in text.splitlines()[:30]:
        # Skip cff-version: line
        if line.strip().startswith("cff-version"):
            continue
        m = RE_CFF.match(line)
        if m:
            return m.group(1)
    return None


def _extract_pkg(text):
    first_line = text.splitlines()[0] if text.strip() else ""
    m = RE_PKG.match(first_line)
    if m:
        return m.group(1)
    return None


def _version_tuple(v):
    """Parse version string to comparable tuple, padding to 3 components."""
    parts = v.split(".")[:3]
    while len(parts) < 3:
        parts.append("0")
    return tuple(int(x) for x in parts)


def git_cat(ref, path):
    """Read a file at a specific git ref."""
    p = subprocess.run(["git", "show", f"{ref}:{path}"], capture_output=True)
    if p.returncode != 0:
        return None
    try:
        return p.stdout.decode("utf-8")
    except UnicodeDecodeError:
        return None


def check_bumps(base):
    """Check that all modified versioned files have bumped their version."""
    p = subprocess.run(
        ["git", "diff", "--name-only", base, "HEAD"],
        capture_output=True, text=True,
    )
    if p.returncode != 0:
        sys.stderr.write(f"Error: 'git diff --name-only {base} HEAD' failed.\n")
        if p.stderr:
            sys.stderr.write(p.stderr)
        sys.exit(2)
    files = [l.strip() for l in p.stdout.splitlines() if l.strip()]
    files = [
        f for f in files
        if Path(f).suffix.lower() in VERSION_EXTS or Path(f).name in VERSION_NAMES
    ]

    failures = []
    checked = 0
    for f in files:
        ppath = Path(f)
        if not ppath.exists():
            continue

        text_new = ppath.read_text(encoding="utf-8", errors="ignore")
        v_new_raw = extract_version(text_new, f)
        old_text = git_cat(base, f)
        v_old_raw = extract_version(old_text, f) if old_text else None

        # If neither old nor new contain a version header, skip
        if v_old_raw is None and v_new_raw is None:
            continue

        checked += 1
        v_old = v_old_raw or "0.0.0"
        v_new = v_new_raw or "0.0.0"

        try:
            t_old = _version_tuple(v_old)
            t_new = _version_tuple(v_new)
        except (ValueError, IndexError):
            failures.append((f, v_old, v_new))
            continue

        if t_new <= t_old:
            failures.append((f, v_old, v_new))

    return failures, checked


def check_consistency():
    """Check cross-file version consistency within each platform."""
    issues = []

    # Python: pyproject.toml == __init__.py
    py_versions = {}
    for pattern, label in [
        ("python/pyproject.toml", "pyproject.toml"),
        ("python/*/__init__.py", "__init__.py"),
    ]:
        for path in ROOT.glob(pattern):
            text = path.read_text(encoding="utf-8", errors="ignore")
            v = extract_version(text, str(path))
            if v:
                py_versions[label] = (v, path.relative_to(ROOT).as_posix())

    if len(py_versions) == 2:
        v1 = py_versions["pyproject.toml"]
        v2 = py_versions["__init__.py"]
        if v1[0] != v2[0]:
            issues.append(f"Python version mismatch: {v1[1]}={v1[0]} vs {v2[1]}={v2[0]}")

    # Stata: .pkg == .toc (check all pairs found)
    pkg_versions = {}
    for pattern in ["**/unicefdata.pkg", "**/wbopendata.pkg", "**/yaml.pkg",
                     "**/stata.toc"]:
        for path in ROOT.glob(pattern):
            text = path.read_text(encoding="utf-8", errors="ignore")
            v = extract_version(text, str(path))
            if v:
                rel = path.relative_to(ROOT).as_posix()
                pkg_versions[rel] = v

    toc_files = {k: v for k, v in pkg_versions.items() if k.endswith(".toc")}
    pkg_files = {k: v for k, v in pkg_versions.items() if k.endswith(".pkg")}

    # Ensure all .pkg files share the same version
    if pkg_files:
        pkg_versions_set = set(pkg_files.values())
        if len(pkg_versions_set) > 1:
            details = ", ".join(f"{f}={v}" for f, v in sorted(pkg_files.items()))
            issues.append(f"Stata .pkg version mismatch across files: {details}")
    else:
        pkg_versions_set = set()

    # Ensure all .toc files share the same version
    if toc_files:
        toc_versions_set = set(toc_files.values())
        if len(toc_versions_set) > 1:
            details = ", ".join(f"{f}={v}" for f, v in sorted(toc_files.items()))
            issues.append(f"Stata .toc version mismatch across files: {details}")
    else:
        toc_versions_set = set()

    # Cross-check: .pkg versions must match .toc versions
    if pkg_versions_set and toc_versions_set:
        pkg_v = next(iter(pkg_versions_set))
        toc_v = next(iter(toc_versions_set))
        if len(pkg_versions_set) == 1 and len(toc_versions_set) == 1 and pkg_v != toc_v:
            issues.append(
                f"Stata .pkg/.toc mismatch: "
                f".pkg={pkg_v} vs .toc={toc_v}"
            )

    # CITATION.cff >= max of all platform versions
    all_versions = []
    for v_str in list(py_versions.values()) + list(
        (v, k) for k, v in pkg_versions.items()
    ):
        if isinstance(v_str, tuple):
            all_versions.append(v_str[0])
        else:
            all_versions.append(v_str)

    # R DESCRIPTION
    for path in ROOT.glob("**/DESCRIPTION"):
        if "Rd" in str(path) or "man" in str(path):
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        v = extract_version(text, str(path))
        if v:
            all_versions.append(v)

    cff_version = None
    for path in ROOT.glob("**/*.cff"):
        text = path.read_text(encoding="utf-8", errors="ignore")
        v = extract_version(text, str(path))
        if v:
            cff_version = (v, path.relative_to(ROOT).as_posix())
            break

    if cff_version and all_versions:
        max_v = max(all_versions, key=lambda x: _version_tuple(x))
        if _version_tuple(cff_version[0]) < _version_tuple(max_v):
            issues.append(
                f"CITATION.cff ({cff_version[1]}={cff_version[0]}) "
                f"is behind max platform version ({max_v})"
            )

    return issues


def main():
    if len(sys.argv) < 2:
        print("Usage: check_versions.py <base-ref> [--check-consistency]")
        return 2

    base = sys.argv[1]
    do_consistency = "--check-consistency" in sys.argv

    exit_code = 0

    # 1. Check version bumps on modified files
    failures, checked = check_bumps(base)
    if failures:
        print("Version check FAILED for modified files:")
        for f, old, new in failures:
            print(f"  {f}: {old} -> {new}")
        exit_code = 1
    else:
        print(f"Version bump check passed ({checked} versioned files checked).")

    # 2. Optionally check cross-file consistency
    if do_consistency:
        issues = check_consistency()
        if issues:
            print("\nConsistency check FAILED:")
            for issue in issues:
                print(f"  {issue}")
            exit_code = 1
        else:
            print("Consistency check passed.")

    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
