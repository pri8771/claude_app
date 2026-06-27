#!/usr/bin/env bash
#
# generate_app_icon.sh
#
# Generates every iOS app-icon size from a single 1024×1024 source PNG and
# writes a matching (legacy, per-size) Contents.json into the asset catalog.
#
# This is OPTIONAL. The committed AppIcon.appiconset uses the modern
# single-size "universal 1024" slot, so you can simply drop a 1024×1024 PNG
# onto that slot in Xcode and the build will produce every size for you.
# Use this script only if you prefer explicit per-size PNGs.
#
# Requirements: macOS (uses the built-in `sips`). No third-party tools.
#
# Usage:
#   Scripts/generate_app_icon.sh [SOURCE_1024_PNG] [APPICONSET_DIR]
#
# Defaults:
#   SOURCE_1024_PNG = ./AppIcon-1024.png
#   APPICONSET_DIR  = Hindsight/Assets.xcassets/AppIcon.appiconset
#
set -euo pipefail

SRC="${1:-AppIcon-1024.png}"
DEST="${2:-Hindsight/Assets.xcassets/AppIcon.appiconset}"

if ! command -v sips >/dev/null 2>&1; then
  echo "error: 'sips' not found. Run this on macOS." >&2
  exit 1
fi
if [[ ! -f "$SRC" ]]; then
  echo "error: source icon not found: $SRC" >&2
  echo "       Export one from AppIconPreviewView (1024×1024 PNG) first." >&2
  exit 1
fi
mkdir -p "$DEST"

# pixel sizes to emit: "<pixels> <filename>"
sizes=(
  "40 icon-20@2x.png"   "60 icon-20@3x.png"
  "58 icon-29@2x.png"   "87 icon-29@3x.png"
  "80 icon-40@2x.png"   "120 icon-40@3x.png"
  "120 icon-60@2x.png"  "180 icon-60@3x.png"
  "20 icon-20.png"      "29 icon-29.png"      "40 icon-40.png"
  "76 icon-76.png"      "152 icon-76@2x.png"  "167 icon-83.5@2x.png"
  "1024 icon-1024.png"
)

echo "Generating icons from $SRC -> $DEST"
for entry in "${sizes[@]}"; do
  px="${entry%% *}"
  name="${entry#* }"
  sips -s format png -z "$px" "$px" "$SRC" --out "$DEST/$name" >/dev/null
  echo "  ✓ $name (${px}px)"
done

cat > "$DEST/Contents.json" <<'JSON'
{
  "images" : [
    { "size" : "20x20",   "idiom" : "iphone", "filename" : "icon-20@2x.png",   "scale" : "2x" },
    { "size" : "20x20",   "idiom" : "iphone", "filename" : "icon-20@3x.png",   "scale" : "3x" },
    { "size" : "29x29",   "idiom" : "iphone", "filename" : "icon-29@2x.png",   "scale" : "2x" },
    { "size" : "29x29",   "idiom" : "iphone", "filename" : "icon-29@3x.png",   "scale" : "3x" },
    { "size" : "40x40",   "idiom" : "iphone", "filename" : "icon-40@2x.png",   "scale" : "2x" },
    { "size" : "40x40",   "idiom" : "iphone", "filename" : "icon-40@3x.png",   "scale" : "3x" },
    { "size" : "60x60",   "idiom" : "iphone", "filename" : "icon-60@2x.png",   "scale" : "2x" },
    { "size" : "60x60",   "idiom" : "iphone", "filename" : "icon-60@3x.png",   "scale" : "3x" },
    { "size" : "20x20",   "idiom" : "ipad",   "filename" : "icon-20.png",      "scale" : "1x" },
    { "size" : "20x20",   "idiom" : "ipad",   "filename" : "icon-20@2x.png",   "scale" : "2x" },
    { "size" : "29x29",   "idiom" : "ipad",   "filename" : "icon-29.png",      "scale" : "1x" },
    { "size" : "29x29",   "idiom" : "ipad",   "filename" : "icon-29@2x.png",   "scale" : "2x" },
    { "size" : "40x40",   "idiom" : "ipad",   "filename" : "icon-40.png",      "scale" : "1x" },
    { "size" : "40x40",   "idiom" : "ipad",   "filename" : "icon-40@2x.png",   "scale" : "2x" },
    { "size" : "76x76",   "idiom" : "ipad",   "filename" : "icon-76.png",      "scale" : "1x" },
    { "size" : "76x76",   "idiom" : "ipad",   "filename" : "icon-76@2x.png",   "scale" : "2x" },
    { "size" : "83.5x83.5","idiom" : "ipad",  "filename" : "icon-83.5@2x.png", "scale" : "2x" },
    { "size" : "1024x1024","idiom" : "ios-marketing", "filename" : "icon-1024.png", "scale" : "1x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
JSON

echo "Done. Wrote $DEST/Contents.json with all sizes."
