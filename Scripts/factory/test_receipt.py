#!/usr/bin/env python3
"""Emit a wired-test receipt from an .xcresult bundle.

The point: report the number of tests that ACTUALLY EXECUTED. A build that
compiles proves nothing about correctness, and "the suite is green" is prose.
This reads the result bundle and reports counts, or UNVERIFIED if it cannot.

Usage: python3 Scripts/factory/test_receipt.py <path-to.xcresult> [--min N]
Exits non-zero when fewer than --min tests executed (default 1) or any failed.
"""

import argparse
import json
import os
import subprocess
import sys


def read_summary(bundle):
    """Try the modern test-results summary, then the legacy JSON shape."""
    attempts = [
        ["xcrun", "xcresulttool", "get", "test-results", "summary",
         "--path", bundle, "--format", "json"],
        ["xcrun", "xcresulttool", "get", "--path", bundle, "--format", "json"],
    ]
    errors = []
    for cmd in attempts:
        try:
            proc = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            if proc.returncode == 0 and proc.stdout.strip():
                return json.loads(proc.stdout), None
            errors.append(f"{' '.join(cmd[:5])}: rc={proc.returncode} {proc.stderr[:200]}")
        except Exception as exc:  # noqa: BLE001 - record and try the next shape
            errors.append(f"{' '.join(cmd[:5])}: {exc}")
    return None, "; ".join(errors)


def extract_counts(data):
    """Pull counts out of whichever schema xcresulttool returned."""
    if not isinstance(data, dict):
        return {}
    if "passedTests" in data or "totalTestCount" in data:
        passed = data.get("passedTests")
        failed = data.get("failedTests")
        skipped = data.get("skippedTests")
        total = data.get("totalTestCount")
        if total is None:
            total = sum(v for v in (passed, failed, skipped) if isinstance(v, int))
        return {"executed_tests": total, "passed": passed, "failed": failed,
                "skipped": skipped, "result": data.get("result")}
    # Legacy shape: metrics live under a nested _value key.
    metrics = data.get("metrics", {})

    def val(key):
        node = metrics.get(key, {})
        return node.get("_value") if isinstance(node, dict) else None

    total = val("testsCount")
    failed = val("testsFailedCount")
    skipped = val("testsSkippedCount")
    if total is None:
        return {}
    total = int(total)
    failed = int(failed or 0)
    skipped = int(skipped or 0)
    return {"executed_tests": total, "passed": total - failed - skipped,
            "failed": failed, "skipped": skipped}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("bundle")
    parser.add_argument("--min", type=int, default=1)
    args = parser.parse_args()

    receipt = {
        "schema": "gen8/test-receipt/v1",
        "sha": os.environ.get("GITHUB_SHA", ""),
        "run_url": (
            f"{os.environ.get('GITHUB_SERVER_URL', '')}/"
            f"{os.environ.get('GITHUB_REPOSITORY', '')}/actions/runs/"
            f"{os.environ.get('GITHUB_RUN_ID', '')}"
            if os.environ.get("GITHUB_RUN_ID") else ""
        ),
    }

    if not os.path.exists(args.bundle):
        receipt.update({"outcome": "UNVERIFIED",
                        "error": f"result bundle not found: {args.bundle}"})
        print(json.dumps(receipt, indent=2))
        return 1

    data, error = read_summary(args.bundle)
    if data is None:
        receipt.update({"outcome": "UNVERIFIED", "error": error})
        print(json.dumps(receipt, indent=2))
        return 1

    counts = extract_counts(data)
    if not counts:
        receipt.update({"outcome": "UNVERIFIED",
                        "error": "could not read test counts from result bundle"})
        print(json.dumps(receipt, indent=2))
        return 1

    receipt.update(counts)
    executed = counts.get("executed_tests") or 0
    failed = counts.get("failed") or 0
    if executed < args.min:
        receipt["outcome"] = "FAILED"
        receipt["reason"] = (
            f"only {executed} tests executed (minimum {args.min}) - "
            "compilation success is not correctness evidence"
        )
    elif failed:
        receipt["outcome"] = "FAILED"
        receipt["reason"] = f"{failed} test(s) failed"
    else:
        receipt["outcome"] = "VERIFIED"

    print(json.dumps(receipt, indent=2))
    return 0 if receipt["outcome"] == "VERIFIED" else 1


if __name__ == "__main__":
    sys.exit(main())
