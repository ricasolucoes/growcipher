#!/bin/sh
# Regression checks for the iOS store asset and version wiring.
set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

fail() {
  printf '%s\n' "FAIL: $1" >&2
  exit 1
}

version_line="$(sed -n -E 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)\+[0-9]+.*/\1/p' pubspec.yaml | head -1)"
test "$version_line" = "0.3.0" || fail "pubspec version must be 0.3.0 for this release"

workflow=".github/workflows/release-appstore.yml"
grep -Fq 'IOS_APP_STORE_VERSION: ${{ needs.build.outputs.version }}' "$workflow" \
  || fail "App Store Connect version must follow the built version"
if grep -Fq 'IOS_APP_STORE_VERSION: "1"' "$workflow"; then
  fail "App Store Connect version is still hard-coded to 1"
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
expected_icon="$tmp_dir/Icon-App-1024x1024@1x.png"
sips -z 1024 1024 assets/store/growcipher-play-icon-512.png --out "$expected_icon" >/dev/null
cmp -s "$expected_icon" \
  ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png \
  || fail "iOS AppIcon is not generated from the GrowCipher store icon"

printf '%s\n' "PASS: iOS store version follows $version_line and the GrowCipher icon is installed"
