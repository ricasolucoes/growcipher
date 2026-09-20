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

command -v sips >/dev/null 2>&1 || {
  printf '%s\n' 'ERRO: sips (macOS) e necessario para preparar screenshots iOS.' >&2
  exit 1
}

for locale in "${LOCALES[@]}"; do
  output_dir="$OUTPUT_ROOT/$locale"
  mkdir -p "$output_dir"
  for source_name_index in "${!SOURCES[@]}"; do
    index=$((source_name_index + 1))
    source="$SOURCE_DIR/${SOURCES[$source_name_index]}"
    test -f "$source"

    iphone_output="$output_dir/iPhone 6.5-$index.png"
    sips --resampleHeightWidthMax 2688 "$source" --out "$iphone_output" >/dev/null 2>&1
    sips --padToHeightWidth 2688 1242 --padColor 0f172a "$iphone_output" >/dev/null 2>&1

    ipad_output="$output_dir/iPad Pro (12.9-inch) (3rd generation)-$index.png"
    sips --resampleHeightWidthMax 2732 "$source" --out "$ipad_output" >/dev/null 2>&1
    sips --padToHeightWidth 2732 2048 --padColor 0f172a "$ipad_output" >/dev/null 2>&1
  done
done

for locale in "${LOCALES[@]}"; do
  for output in "$OUTPUT_ROOT/$locale"/*.png; do
    width="$(sips -g pixelWidth "$output" | awk '/pixelWidth:/ {print $2}')"
    height="$(sips -g pixelHeight "$output" | awk '/pixelHeight:/ {print $2}')"
    case "$(basename "$output")" in
      iPhone*) test "$width" = 1242 && test "$height" = 2688 ;;
      iPad*) test "$width" = 2048 && test "$height" = 2732 ;;
      *) printf '%s\n' "ERRO: nome de screenshot inesperado: $output" >&2; exit 1 ;;
    esac
    printf '%s/%s %sx%s\n' "$locale" "$(basename "$output")" "$width" "$height"
  done
done
