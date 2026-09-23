#!/bin/sh
# Gera o AppIcon do iOS a partir da arte oficial do GrowCipher.
set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
SOURCE="$PROJECT_ROOT/assets/store/growcipher-play-icon-512.png"
OUTPUT_DIR="$PROJECT_ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"

command -v sips >/dev/null 2>&1 || {
  printf '%s\n' 'ERRO: sips (macOS) e necessario para gerar o AppIcon do iOS.' >&2
  exit 1
}
test -f "$SOURCE"
test -d "$OUTPUT_DIR"

generate_icon() {
  size="$1"
  filename="$2"
  sips -z "$size" "$size" "$SOURCE" --out "$OUTPUT_DIR/$filename" >/dev/null
}

generate_icon 40 Icon-App-20x20@2x.png
generate_icon 60 Icon-App-20x20@3x.png
generate_icon 29 Icon-App-29x29@1x.png
generate_icon 58 Icon-App-29x29@2x.png
generate_icon 87 Icon-App-29x29@3x.png
generate_icon 80 Icon-App-40x40@2x.png
generate_icon 120 Icon-App-40x40@3x.png
generate_icon 120 Icon-App-60x60@2x.png
generate_icon 180 Icon-App-60x60@3x.png
generate_icon 20 Icon-App-20x20@1x.png
generate_icon 40 Icon-App-20x20@2x.png
generate_icon 29 Icon-App-29x29@1x.png
generate_icon 58 Icon-App-29x29@2x.png
generate_icon 40 Icon-App-40x40@1x.png
generate_icon 80 Icon-App-40x40@2x.png
generate_icon 76 Icon-App-76x76@1x.png
generate_icon 152 Icon-App-76x76@2x.png
generate_icon 167 Icon-App-83.5x83.5@2x.png
generate_icon 1024 Icon-App-1024x1024@1x.png

printf '%s\n' 'AppIcon do iOS gerado a partir de assets/store/growcipher-play-icon-512.png'
