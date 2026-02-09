"""Compare YAML outputs from two pipelines.

Usage:
  python compare_yaml_parity.py --stata-dir path/to/stata/output --python-dir path/to/python/output

Defaults:
  --stata-dir defaults to wbopendata-dev/src/_
  --python-dir defaults to wbopendata-dev/src/_
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, Tuple

try:
    import yaml
except Exception as exc:  # pragma: no cover - import guard
    print("ERROR: PyYAML is required to run this script.")
    print(f"Import error: {exc}")
    sys.exit(2)


FILES = {
    "indicators": "_wbopendata_indicators.yaml",
    "sources": "_wbopendata_sources.yaml",
    "topics": "_wbopendata_topics.yaml",
}

IGNORE_METADATA_KEYS = {
    "generated_at",
    "checksum_sha256",
}


def _select_yaml_loader() -> Any:
    # Prefer the C-based loader for speed on large files.
    return getattr(yaml, "CSafeLoader", yaml.SafeLoader)


def _load_yaml(path: Path) -> Dict[str, Any]:
    raw = path.read_bytes()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        text = raw.decode("cp1252", errors="replace")
    loader = _select_yaml_loader()
    data = yaml.load(text, Loader=loader) or {}
    if not isinstance(data, dict):
        raise ValueError(f"YAML root is not a mapping: {path}")
    return data


def _normalize(value: Any) -> Any:
    if value is None:
        return ""
    if isinstance(value, dict):
        return {str(k): _normalize(v) for k, v in value.items()}
    if isinstance(value, list):
        return [_normalize(v) for v in value]
    return value


def _strip_metadata(data: Dict[str, Any]) -> Dict[str, Any]:
    out = dict(data)
    meta = out.get("_metadata", {})
    if isinstance(meta, dict):
        meta = {k: v for k, v in meta.items() if k not in IGNORE_METADATA_KEYS}
    out["_metadata"] = meta
    return out


def _compare_dicts(left: Dict[str, Any], right: Dict[str, Any]) -> Tuple[bool, str]:
    if left == right:
        return True, ""
    left_keys = set(left.keys())
    right_keys = set(right.keys())
    if left_keys != right_keys:
        missing = sorted(left_keys - right_keys)
        extra = sorted(right_keys - left_keys)
        return False, f"Key mismatch. Missing: {missing} Extra: {extra}"
    return False, "Content mismatch"


def _report_sample_diffs(
    section: str,
    left_section: Dict[str, Any],
    right_section: Dict[str, Any],
    max_keys: int = 5,
) -> None:
    left_keys = sorted(left_section.keys())
    right_keys = sorted(right_section.keys())

    missing = [k for k in left_keys if k not in right_section]
    extra = [k for k in right_keys if k not in left_section]
    if missing:
        print(f"  Missing keys (sample): {missing[:max_keys]}")
    if extra:
        print(f"  Extra keys (sample): {extra[:max_keys]}")

    common = [k for k in left_keys if k in right_section]
    checked = 0
    for key in common:
        if checked >= max_keys:
            break
        left_val = left_section.get(key)
        right_val = right_section.get(key)
        if left_val != right_val:
            print(f"  Diff key: {key}")
            if isinstance(left_val, dict) and isinstance(right_val, dict):
                lsub = set(left_val.keys())
                rsub = set(right_val.keys())
                if lsub != rsub:
                    lmiss = sorted(lsub - rsub)
                    rextra = sorted(rsub - lsub)
                    print(f"    Field keys missing: {lmiss[:max_keys]}")
                    print(f"    Field keys extra: {rextra[:max_keys]}")
                else:
                    for field in sorted(lsub)[:max_keys]:
                        if left_val.get(field) != right_val.get(field):
                            print(
                                f"    Field {field}: {left_val.get(field)!r} != {right_val.get(field)!r}"
                            )
            else:
                print(f"    Value: {left_val!r} != {right_val!r}")
            checked += 1


def _compare_section(name: str, left_path: Path, right_path: Path) -> Tuple[bool, str]:
    left = _strip_metadata(_normalize(_load_yaml(left_path)))
    right = _strip_metadata(_normalize(_load_yaml(right_path)))

    ok, msg = _compare_dicts(left, right)
    if ok:
        return True, "OK"

    left_section = left.get(name, {})
    right_section = right.get(name, {})
    if isinstance(left_section, dict) and isinstance(right_section, dict):
        lkeys = set(left_section.keys())
        rkeys = set(right_section.keys())
        if lkeys != rkeys:
            missing = sorted(lkeys - rkeys)
            extra = sorted(rkeys - lkeys)
            return False, f"{name} keys differ. Missing: {missing} Extra: {extra}"
        _report_sample_diffs(name, left_section, right_section)
    return False, msg


def _resolve_dir(path_str: str, base: Path) -> Path:
    path = Path(path_str)
    if path.is_absolute():
        return path
    return (base / path).resolve()


def _parse_sections(value: str) -> Dict[str, str]:
    if not value or value.strip().lower() == "all":
        return dict(FILES)
    requested = [item.strip().lower() for item in value.split(",") if item.strip()]
    unknown = [item for item in requested if item not in FILES]
    if unknown:
        raise ValueError(f"Unknown section(s): {unknown}. Valid: {sorted(FILES)}")
    return {name: FILES[name] for name in requested}


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Compare YAML outputs from two pipelines")
    parser.add_argument(
        "--stata-dir",
        default="wbopendata-dev/src/_",
        help="Directory with Stata-generated YAML files",
    )
    parser.add_argument(
        "--python-dir",
        default="wbopendata-dev/src/_",
        help="Directory with Python-generated YAML files",
    )
    parser.add_argument(
        "--sections",
        default="all",
        help="Comma-separated list of sections to compare (indicators,sources,topics) or 'all'",
    )

    args = parser.parse_args(argv)
    repo_root = Path(__file__).resolve().parents[2]
    stata_dir = _resolve_dir(args.stata_dir, repo_root)
    python_dir = _resolve_dir(args.python_dir, repo_root)

    try:
        selected = _parse_sections(args.sections)
    except ValueError as exc:
        print(f"ERROR: {exc}")
        return 2

    failures = 0
    for section, filename in selected.items():
        left_path = stata_dir / filename
        right_path = python_dir / filename
        if not left_path.exists():
            print(f"FAIL {section}: missing file {left_path}")
            failures += 1
            continue
        if not right_path.exists():
            print(f"FAIL {section}: missing file {right_path}")
            failures += 1
            continue
        ok, msg = _compare_section(section, left_path, right_path)
        status = "OK" if ok else "FAIL"
        print(f"{status} {section}: {msg}")
        if not ok:
            failures += 1

    if failures:
        print(f"\nParity check FAILED ({failures} section(s) differ).")
        return 1

    print("\nParity check PASSED.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
