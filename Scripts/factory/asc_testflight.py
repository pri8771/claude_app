#!/usr/bin/env python3
"""App Store Connect TestFlight operations for the Gen 8 release rail.

Subcommands:
  wait-processing  Poll until the uploaded build finishes processing.
  assign-group     Add a processed build to an existing beta group.

Auth (all subcommands) comes from environment variables:
  ASC_KEY_ID       App Store Connect API key ID
  ASC_ISSUER_ID    App Store Connect issuer ID
  ASC_KEY_P8_PATH  Path to the .p8 private key file

Requires: PyJWT[crypto], requests  (pip install "PyJWT[crypto]" requests)

Every subcommand prints a single JSON object to stdout as its receipt and
exits non-zero on failure. No secrets are ever printed.
"""

import argparse
import json
import os
import sys
import time

import jwt
import requests

API_BASE = "https://api.appstoreconnect.apple.com"
TOKEN_LIFETIME_SECONDS = 15 * 60


class AscClient:
    def __init__(self):
        try:
            self.key_id = os.environ["ASC_KEY_ID"]
            self.issuer_id = os.environ["ASC_ISSUER_ID"]
            key_path = os.environ["ASC_KEY_P8_PATH"]
        except KeyError as missing:
            fail(f"missing required environment variable: {missing.args[0]}")
        with open(key_path, "r", encoding="utf-8") as fh:
            self.private_key = fh.read()
        self._token = None
        self._token_expires = 0.0

    def _bearer(self):
        now = time.time()
        if self._token is None or now > self._token_expires - 60:
            payload = {
                "iss": self.issuer_id,
                "iat": int(now),
                "exp": int(now + TOKEN_LIFETIME_SECONDS),
                "aud": "appstoreconnect-v1",
            }
            self._token = jwt.encode(
                payload, self.private_key, algorithm="ES256",
                headers={"kid": self.key_id},
            )
            self._token_expires = now + TOKEN_LIFETIME_SECONDS
        return self._token

    def request(self, method, path, **kwargs):
        resp = requests.request(
            method,
            API_BASE + path,
            headers={
                "Authorization": f"Bearer {self._bearer()}",
                "Content-Type": "application/json",
            },
            timeout=60,
            **kwargs,
        )
        if resp.status_code >= 400:
            fail(
                f"ASC API {method} {path} -> HTTP {resp.status_code}: "
                f"{resp.text[:2000]}"
            )
        if resp.status_code == 204 or not resp.content:
            return {}
        return resp.json()

    def get(self, path, params=None):
        return self.request("GET", path, params=params or {})

    def post(self, path, body):
        return self.request("POST", path, data=json.dumps(body))

    def app_id_for_bundle(self, bundle_id):
        data = self.get("/v1/apps", {"filter[bundleId]": bundle_id})
        apps = data.get("data", [])
        if not apps:
            fail(f"no App Store Connect app found for bundle id {bundle_id}")
        return apps[0]["id"]

    def find_build(self, app_id, build_number):
        data = self.get(
            "/v1/builds",
            {
                "filter[app]": app_id,
                "filter[version]": build_number,
                "sort": "-uploadedDate",
                "limit": "5",
            },
        )
        builds = data.get("data", [])
        return builds[0] if builds else None


def fail(message):
    print(json.dumps({"outcome": "FAILED", "error": message}))
    sys.exit(1)


def cmd_wait_processing(args):
    client = AscClient()
    app_id = client.app_id_for_bundle(args.bundle_id)
    deadline = time.time() + args.timeout_minutes * 60
    seen = False
    while time.time() < deadline:
        build = client.find_build(app_id, args.build_number)
        if build is None:
            # Uploads can take a few minutes to appear at all.
            if not seen:
                print(
                    f"build {args.build_number} not visible yet; waiting...",
                    file=sys.stderr,
                )
        else:
            seen = True
            state = build["attributes"].get("processingState")
            print(f"processingState={state}", file=sys.stderr)
            if state == "VALID":
                print(json.dumps({
                    "outcome": "VERIFIED",
                    "asc_app_id": app_id,
                    "asc_build_id": build["id"],
                    "build_number": args.build_number,
                    "processing_state": state,
                    "uploaded_date": build["attributes"].get("uploadedDate"),
                    "expiration_date": build["attributes"].get("expirationDate"),
                }))
                return
            if state in ("INVALID", "FAILED"):
                fail(
                    f"build {args.build_number} finished processing in state "
                    f"{state}; check App Store Connect for details"
                )
        time.sleep(args.poll_seconds)
    fail(
        f"timed out after {args.timeout_minutes} minutes waiting for build "
        f"{args.build_number} to reach processingState=VALID "
        f"(build {'seen' if seen else 'never appeared'})"
    )


def cmd_assign_group(args):
    client = AscClient()
    app_id = client.app_id_for_bundle(args.bundle_id)
    build = client.find_build(app_id, args.build_number)
    if build is None:
        fail(f"build {args.build_number} not found for {args.bundle_id}")
    groups = client.get(
        "/v1/betaGroups", {"filter[app]": app_id, "limit": "200"}
    ).get("data", [])
    wanted = [
        g for g in groups
        if g["attributes"].get("name", "").lower() == args.group.lower()
    ]
    if not wanted:
        names = [g["attributes"].get("name") for g in groups]
        fail(
            f"beta group '{args.group}' not found for this app. "
            f"Existing groups: {names}. Create it once in App Store Connect "
            f"(TestFlight > Internal Testing) and re-run."
        )
    group = wanted[0]
    client.post(
        f"/v1/betaGroups/{group['id']}/relationships/builds",
        {"data": [{"type": "builds", "id": build["id"]}]},
    )
    print(json.dumps({
        "outcome": "VERIFIED",
        "asc_app_id": app_id,
        "asc_build_id": build["id"],
        "build_number": args.build_number,
        "beta_group": group["attributes"].get("name"),
        "beta_group_id": group["id"],
        "is_internal_group": group["attributes"].get("isInternalGroup"),
    }))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    p_wait = sub.add_parser("wait-processing")
    p_wait.add_argument("--bundle-id", required=True)
    p_wait.add_argument("--build-number", required=True)
    p_wait.add_argument("--timeout-minutes", type=int, default=45)
    p_wait.add_argument("--poll-seconds", type=int, default=60)
    p_wait.set_defaults(func=cmd_wait_processing)

    p_assign = sub.add_parser("assign-group")
    p_assign.add_argument("--bundle-id", required=True)
    p_assign.add_argument("--build-number", required=True)
    p_assign.add_argument("--group", default="Internal Testers")
    p_assign.set_defaults(func=cmd_assign_group)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
