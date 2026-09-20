#!/usr/bin/env bash
# Prepara capturas reais do MVP nos tamanhos aceitos pelo App Store Connect.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$PROJECT_ROOT/assets/store/screenshots"
OUTPUT_ROOT="$PROJECT_ROOT/fastlane/screenshots"
LOCALES=(de-DE en-US es-ES fr-FR it ja pt-BR ru zh-Hans)
SOURCES=(
  growcipher-01-home.png
  growcipher-02-wizard.png
  growcipher-03-identification.png
)

command -v magick >/dev/null 2>&1 || {
  printf '%s\n' 'ERRO: ImageMagick (magick) e necessario para preparar screenshots iOS.' >&2
  exit 1
}

for locale in "${LOCALES[@]}"; do
  output_dir="$OUTPUT_ROOT/$locale"
  mkdir -p "$output_dir"
  for source_name_index in "${!SOURCES[@]}"; do
    index=$((source_name_index + 1))
    source="$SOURCE_DIR/${SOURCES[$source_name_index]}"
    test -f "$source"

    magick "$source" \
      -background '#0f172a' \
      -gravity center \
      -resize '1242x2688' \
      -extent 1242x2688 \
      -strip \
      "$output_dir/iPhone 6.5-$index.png"

    magick "$source" \
      -background '#0f172a' \
      -gravity center \
      -resize '2048x2732' \
      -extent 2048x2732 \
      -strip \
      "$output_dir/iPad Pro (12.9-inch) (3rd generation)-$index.png"
  done
done

for locale in "${LOCALES[@]}"; do
  for output in "$OUTPUT_ROOT/$locale"/*.png; do
    identify -format "$locale/%f %wx%h\n" "$output"
  done
done
