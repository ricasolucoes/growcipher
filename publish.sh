#!/bin/bash
# 🚀 Publish GrowCipher to Google Play Store
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

TRACK="${1:-production}"
SKIP_BUILD="${SKIP_BUILD:-0}"
AAB_PATH="$SCRIPT_DIR/build/app/outputs/bundle/release/app-release.aab"

export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="/Users/sierra/Library/Android/sdk"

echo "======================================================="
echo "🔒 Publicando GrowCipher (com.sierratecnologia.growcipher) no Google Play"
echo "Faixa: $TRACK"
echo "======================================================="

if [ "$SKIP_BUILD" != "1" ]; then
    echo "=> Compilando Flutter App Bundle (.aab)..."
    flutter build appbundle --release
fi

if [ ! -f "$AAB_PATH" ]; then
    FALLBACK_AAB="$(find "$SCRIPT_DIR/build" -name "*release*.aab" 2>/dev/null | head -n 1)"
    if [ -n "$FALLBACK_AAB" ] && [ -f "$FALLBACK_AAB" ]; then
        AAB_PATH="$FALLBACK_AAB"
    else
        echo "❌ Erro: AAB não encontrado em $AAB_PATH"
        exit 1
    fi
fi

echo "=> AAB localizado: $AAB_PATH"
echo "=> Enviando para a Google Play Store..."
python3 /Users/sierra/Dev/scripts/play_store_publish.py \
    --package com.sierratecnologia.growcipher \
    --aab "$AAB_PATH" \
    --track "$TRACK" \
    --metadata-dir "$SCRIPT_DIR/fastlane/metadata/android" \
    "${@:2}"

echo "✅ GrowCipher publicado com sucesso!"
