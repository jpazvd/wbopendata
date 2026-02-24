#!/usr/bin/env python3
"""
analyze_test_log.py — Parse wbopendata test log files for command-by-command analysis.

Parses the Stata log output from test_help_examples.do or run_tests.do to extract:
  - Test IDs and descriptions
  - wbopendata commands with timing
  - Pass/fail/skip status
  - Cache hit/miss detection (via "(using cached data:" messages)
  - Tier-level grouping

Usage:
    python analyze_test_log.py <logfile>
    python analyze_test_log.py tests/test_help_examples_23Feb2026015637.log

Version: 1.0.0
Date: 23Feb2026
Author: Joao Pedro Azevedo
"""

import re
import sys
from pathlib import Path
from collections import OrderedDict


def parse_log(log_path):
    """Parse a Stata test log file and extract structured test data."""

    with open(log_path, "r", encoding="utf-8", errors="replace") as f:
        lines = f.readlines()

    tests = OrderedDict()
    tiers = OrderedDict()
    current_test_id = None
    current_tier = None

    # Patterns
    re_tier = re.compile(r"^=+\s*$")
    re_tier_name = re.compile(r"^TIER\s+\d+:\s+(.+)$")
    re_test_start = re.compile(r"^---\s+(HELP-\S+|EX-\d+):\s+(.+?)\s+---\s*$")
    re_pass = re.compile(r"^\s+PASS\s*$")
    re_fail = re.compile(r"^\s+FAIL:\s+(.*)$")
    re_skip = re.compile(r"^\s+SKIP:\s+(.*)$")
    re_wbo_cmd = re.compile(r"^\.\s+((?:qui\s+)?(?:cap\s+(?:noi\s+)?)?wbopendata\s*,.+)$")
    re_timing = re.compile(r"^r(?:\(\d+\))?;\s+t=(\d+\.\d+)\s")
    re_cache_hit = re.compile(r"\(using cached data:\s+(.+?)\)")
    re_cache_ttl = re.compile(r"TTL\s+(\d+)d")
    re_summary_run = re.compile(r"^Tests Run:\s+(\d+)")
    re_summary_pass = re.compile(r"^Tests Passed:\s+(\d+)")
    re_summary_fail = re.compile(r"^Tests Failed:\s+(\d+)")
    re_summary_skip = re.compile(r"^Tests Skipped:\s+(\d+)")

    summary = {"run": 0, "passed": 0, "failed": 0, "skipped": 0}

    for i, raw_line in enumerate(lines):
        line = raw_line.rstrip()

        # Detect tier headers (preceded by === line)
        m = re_tier_name.match(line)
        if m:
            current_tier = m.group(1).strip()
            if current_tier not in tiers:
                tiers[current_tier] = []

        # Detect test start
        m = re_test_start.match(line)
        if m:
            current_test_id = m.group(1)
            desc = m.group(2)
            tests[current_test_id] = {
                "id": current_test_id,
                "description": desc,
                "tier": current_tier,
                "status": "unknown",
                "commands": [],
                "timings": [],
                "cache_hits": [],
                "fail_msg": "",
                "skip_msg": "",
                "line_num": i + 1,
            }
            if current_tier and current_tier in tiers:
                tiers[current_tier].append(current_test_id)
            continue

        if current_test_id is None:
            # Summary lines
            for pat, key in [
                (re_summary_run, "run"),
                (re_summary_pass, "passed"),
                (re_summary_fail, "failed"),
                (re_summary_skip, "skipped"),
            ]:
                m = pat.match(line)
                if m:
                    summary[key] = int(m.group(1))
            continue

        test = tests[current_test_id]

        # Pass/fail/skip
        if re_pass.match(line):
            test["status"] = "PASS"
            current_test_id = None
            continue
        m = re_fail.match(line)
        if m:
            test["status"] = "FAIL"
            test["fail_msg"] = m.group(1)
            current_test_id = None
            continue
        m = re_skip.match(line)
        if m:
            test["status"] = "SKIP"
            test["skip_msg"] = m.group(1)
            current_test_id = None
            continue

        # wbopendata commands
        m = re_wbo_cmd.match(line)
        if m:
            cmd = m.group(1).strip()
            # Clean up continuation lines
            cmd = re.sub(r"\s*///\s*$", "", cmd)
            test["commands"].append(cmd)

        # Timing
        m = re_timing.match(line)
        if m:
            test["timings"].append(float(m.group(1)))

        # Cache hit messages
        m = re_cache_hit.search(line)
        if m:
            test["cache_hits"].append(m.group(1))

    return tests, tiers, summary


def classify_commands(tests):
    """Classify each test's data download commands as API or CACHE."""
    data_stats = {
        "total_data_cmds": 0,
        "api_downloads": 0,
        "cache_hits": 0,
        "total_api_time": 0.0,
        "total_cache_time": 0.0,
    }

    for test in tests.values():
        # Only count tests with actual wbopendata data commands
        # (skip search, sources, alltopics, match, sync, etc.)
        for j, cmd in enumerate(test["commands"]):
            is_data = any(
                kw in cmd
                for kw in [
                    "indicator(",
                    "country(",
                    "topics(",
                ]
            )
            # Exclude non-data commands
            if not is_data:
                continue
            if any(kw in cmd for kw in ["search(", "sources", "alltopics", "match(", "sync", "cacheinfo", "cleardatacache", "checkupdate", "info("]):
                continue

            data_stats["total_data_cmds"] += 1

            # Check if this command had a cache hit
            if test["cache_hits"]:
                data_stats["cache_hits"] += 1
                if j < len(test["timings"]):
                    data_stats["total_cache_time"] += test["timings"][j]
            else:
                data_stats["api_downloads"] += 1
                if j < len(test["timings"]):
                    data_stats["total_api_time"] += test["timings"][j]

    return data_stats


def print_report(tests, tiers, summary, data_stats, log_path):
    """Print the structured analysis report."""

    print("=" * 72)
    print("wbopendata Test Log Analysis")
    print("=" * 72)
    print(f"Log: {Path(log_path).name}")
    print()

    # Per-tier output
    for tier_name, test_ids in tiers.items():
        if not test_ids:
            continue
        print(f"  {tier_name}")
        print(f"  {'-' * 68}")
        for tid in test_ids:
            test = tests[tid]
            status = test["status"]

            # Get primary timing (max timing for the test)
            timing_str = ""
            if test["timings"]:
                max_t = max(test["timings"])
                timing_str = f"{max_t:6.2f}s"
            else:
                timing_str = "     -"

            # Cache status
            cache_str = ""
            if test["cache_hits"]:
                cache_str = "CACHE"
            elif test["commands"] and any(
                any(kw in c for kw in ["indicator(", "country(", "topics("])
                for c in test["commands"]
            ):
                # Has data commands but no cache hits
                if not any(kw in " ".join(test["commands"]) for kw in ["search(", "sources", "alltopics", "match(", "sync", "cacheinfo", "cleardatacache", "info("]):
                    cache_str = "API"

            # Primary command
            cmd_str = ""
            for c in test["commands"]:
                if "wbopendata" in c:
                    cmd_str = re.sub(r"^(?:qui\s+)?(?:cap\s+(?:noi\s+)?)?", "", c)
                    if len(cmd_str) > 50:
                        cmd_str = cmd_str[:47] + "..."
                    break

            status_fmt = {
                "PASS": f"\033[32m{status}\033[0m",
                "FAIL": f"\033[31m{status}\033[0m",
                "SKIP": f"\033[33m{status}\033[0m",
            }.get(status, status)

            print(f"    {tid:<10s} {status_fmt:<14s} {timing_str}  {cache_str:<6s} {cmd_str}")

            if test["status"] == "FAIL":
                print(f"               -> {test['fail_msg']}")

        print()

    # Summary
    print("=" * 72)
    print("SUMMARY")
    print("=" * 72)
    print(f"  Tests Run:     {summary['run']:>4d}")
    print(f"  Tests Passed:  {summary['passed']:>4d}")
    print(f"  Tests Failed:  {summary['failed']:>4d}")
    print(f"  Tests Skipped: {summary['skipped']:>4d}")
    print()

    if data_stats["total_data_cmds"] > 0:
        hit_rate = (
            data_stats["cache_hits"] / data_stats["total_data_cmds"] * 100
            if data_stats["total_data_cmds"] > 0
            else 0
        )
        print(f"  Data Downloads:  {data_stats['total_data_cmds']:>4d}")
        print(f"  API calls:       {data_stats['api_downloads']:>4d}")
        print(f"  Cache hits:      {data_stats['cache_hits']:>4d}")
        print(f"  Cache hit rate:  {hit_rate:>5.1f}%")
        print()
        print(f"  Total API time:    {data_stats['total_api_time']:>6.1f}s")
        print(f"  Total cache time:  {data_stats['total_cache_time']:>6.1f}s")
        if data_stats["cache_hits"] > 0:
            avg_api = (
                data_stats["total_api_time"] / data_stats["api_downloads"]
                if data_stats["api_downloads"] > 0
                else 0
            )
            saved = data_stats["cache_hits"] * avg_api - data_stats["total_cache_time"]
            print(f"  Est. time saved:   ~{max(0, saved):>5.1f}s")
    print()


def main():
    if len(sys.argv) < 2:
        print("Usage: python analyze_test_log.py <logfile>")
        print()
        print("Parses a wbopendata test log and produces a structured report")
        print("showing per-test timing, cache status, and pass/fail results.")
        sys.exit(1)

    log_path = sys.argv[1]
    if not Path(log_path).exists():
        print(f"Error: File not found: {log_path}")
        sys.exit(1)

    tests, tiers, summary = parse_log(log_path)
    data_stats = classify_commands(tests)
    print_report(tests, tiers, summary, data_stats, log_path)


if __name__ == "__main__":
    main()
