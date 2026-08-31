#!/usr/bin/env python3
"""Gen 8 stage S6: deterministic release-hygiene validator.

Checks the things that historically blocked App Store / TestFlight submission
across this portfolio (missing icons, missing privacy manifest, unanswered
export compliance). No model judgment, no network: every check is a file or
plist fact. Exits non-zero if any REQUIRED check fails.

Usage:
  python3 Scripts/factory/check_release_hygiene.py \
      --bundle-id com.pchordia.hindsight --team 796XH483R4 [--json]
"""

import argparse
import json
import os
import plistlib
import re
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

APP_DIR = "Hindsight"
INFO_PLIST = "Hindsight-Info.plist"
PBXPROJ = "Hindsight.xcodeproj/project.pbxproj"
ICON_SET = f"{APP_DIR}/Assets.xcassets/AppIcon.appiconset"
PRIVACY_MANIFEST = f"{APP_DIR}/PrivacyInfo.xcprivacy"

results = []


def check(name, required, ok, detail):
    results.append({"check": name, "required": required, "ok": bool(ok), "detail": detail})


def path(*parts):
    return os.path.join(REPO_ROOT, *parts)


def pbx_values(pbx, key):
    """All distinct values assigned to a build setting, in file order."""
    found = re.findall(rf"{key} = ([^;]+);", pbx)
    seen, out = set(), []
    for raw in found:
        value = raw.strip().strip('"')
        if value not in seen:
            seen.add(value)
            out.append(value)
    return out


def check_app_icons():
    contents_path = path(ICON_SET, "Contents.json")
    if not os.path.exists(contents_path):
        check("app_icon_set", True, False, f"missing {ICON_SET}/Contents.json")
        return
    with open(contents_path, "r", encoding="utf-8") as fh:
        contents = json.load(fh)
    declared = [img for img in contents.get("images", []) if img.get("filename")]
    missing = [i["filename"] for i in declared if not os.path.exists(path(ICON_SET, i["filename"]))]
    has_marketing = any(
        i.get("size") == "1024x1024" or i.get("filename", "").endswith("1024.png")
        for i in declared
    )
    check("app_icon_files_present", True, not missing,
          f"{len(declared)} declared icon files, missing: {missing or 'none'}")
    check("app_icon_1024_marketing", True, has_marketing,
          "1024x1024 marketing icon present" if has_marketing
          else "no 1024x1024 marketing icon - App Store Connect rejects builds without it")


def check_privacy_manifest():
    exists = os.path.exists(path(PRIVACY_MANIFEST))
    if not exists:
        check("privacy_manifest", True, False, f"{PRIVACY_MANIFEST} MISSING")
        return
    try:
        with open(path(PRIVACY_MANIFEST), "rb") as fh:
            plistlib.load(fh)
    except Exception as exc:  # noqa: BLE001 - report any parse failure verbatim
        check("privacy_manifest", True, False, f"{PRIVACY_MANIFEST} does not parse: {exc}")
        return
    check("privacy_manifest", True, True, f"{PRIVACY_MANIFEST} present and parses")


def check_export_compliance():
    plist_path = path(INFO_PLIST)
    if not os.path.exists(plist_path):
        check("export_compliance_key", True, False, f"{INFO_PLIST} not found")
        return
    with open(plist_path, "rb") as fh:
        info = plistlib.load(fh)
    present = "ITSAppUsesNonExemptEncryption" in info
    check("export_compliance_key", True, present,
          f"ITSAppUsesNonExemptEncryption = {info.get('ITSAppUsesNonExemptEncryption')}"
          if present else
          "ITSAppUsesNonExemptEncryption absent - every upload stalls awaiting a "
          "manual export-compliance answer in App Store Connect")


def check_launch_screen():
    with open(path(INFO_PLIST), "rb") as fh:
        info = plistlib.load(fh)
    has_launch = "UILaunchScreen" in info or "UILaunchStoryboardName" in info
    check("launch_screen", True, has_launch,
          "launch screen configured" if has_launch
          else "no UILaunchScreen/UILaunchStoryboardName - App Store requires one")


def check_project_settings(expected_bundle, expected_team):
    with open(path(PBXPROJ), "r", encoding="utf-8") as fh:
        pbx = fh.read()

    bundles = pbx_values(pbx, "PRODUCT_BUNDLE_IDENTIFIER")
    check("app_bundle_identifier", True, expected_bundle in bundles,
          f"expected {expected_bundle}; project declares {bundles}")

    teams = pbx_values(pbx, "DEVELOPMENT_TEAM")
    non_empty = [t for t in teams if t]
    check("development_team_non_empty", True, bool(non_empty),
          f"DEVELOPMENT_TEAM values: {teams or 'UNSET'}")
    if expected_team:
        check("development_team_matches", True, expected_team in teams,
              f"expected {expected_team}; project declares {teams}")

    versions = pbx_values(pbx, "MARKETING_VERSION")
    check("marketing_version", True, bool(versions and versions[0]),
          f"MARKETING_VERSION = {versions or 'UNSET'}")

    test_targets = len(re.findall(r"com\.apple\.product-type\.bundle\.(unit-test|ui-testing)", pbx))
    check("test_targets_present", False, test_targets > 0,
          f"{test_targets} test target(s) in the project"
          if test_targets else
          "NO test target - a green build proves compilation only, never correctness")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bundle-id", default="com.pchordia.hindsight")
    parser.add_argument("--team", default="")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    check_app_icons()
    check_privacy_manifest()
    check_export_compliance()
    check_launch_screen()
    check_project_settings(args.bundle_id, args.team)

    failures = [r for r in results if r["required"] and not r["ok"]]
    warnings = [r for r in results if not r["required"] and not r["ok"]]
    outcome = "VERIFIED" if not failures else "FAILED"
    receipt = {
        "schema": "gen8/hygiene/v1",
        "stage": "release-prep",
        "app": "hindsight",
        "bundle_id": args.bundle_id,
        "outcome": outcome,
        "checks": results,
        "failed": [r["check"] for r in failures],
        "warnings": [r["check"] for r in warnings],
    }

    if args.json:
        print(json.dumps(receipt, indent=2))
    else:
        for r in results:
            mark = "PASS" if r["ok"] else ("FAIL" if r["required"] else "WARN")
            print(f"[{mark}] {r['check']}: {r['detail']}")
        print(f"\noutcome: {outcome} ({len(failures)} required failures, {len(warnings)} warnings)")

    return 0 if outcome == "VERIFIED" else 1


if __name__ == "__main__":
    sys.exit(main())
