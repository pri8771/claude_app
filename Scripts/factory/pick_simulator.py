#!/usr/bin/env python3
"""Print the UDID of an available iPhone simulator on this machine.

Runner images change device lineups between releases, so pinning a device
name ("iPhone 16") is a known source of CI breakage. This picks whatever
iPhone simulator actually exists, preferring the newest iOS runtime.
Exits non-zero (and prints nothing) if none is available.
"""

import json
import subprocess
import sys


def main():
    raw = subprocess.run(
        ["xcrun", "simctl", "list", "devices", "available", "-j"],
        capture_output=True, text=True, check=True,
    ).stdout
    devices = json.loads(raw).get("devices", {})

    ios_runtimes = [r for r in devices if "iOS" in r]

    def runtime_sort_key(runtime):
        digits = "".join(c if c.isdigit() else " " for c in runtime.split(".iOS-")[-1])
        parts = [int(p) for p in digits.split()] or [0]
        return parts

    for runtime in sorted(ios_runtimes, key=runtime_sort_key, reverse=True):
        iphones = [
            d for d in devices[runtime]
            if d.get("isAvailable") and "iPhone" in d.get("name", "")
        ]
        if iphones:
            print(iphones[0]["udid"])
            return 0

    print("no available iPhone simulator found", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
