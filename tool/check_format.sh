#!/bin/sh
# Confere a formatação de todo Dart versionado.
#
# lib/l10n/generated fica de fora: é código gerado pelo `flutter gen-l10n`,
# não é editado à mão e não segue o dart format.
#
# Uso:
#   tool/check_format.sh          # só confere (é o que a CI roda)
#   tool/check_format.sh --fix    # formata no lugar
set -eu

cd "$(dirname "$0")/.."

if [ "${1:-}" = "--fix" ]; then
  modo=""
else
  modo="--output=none --set-exit-if-changed"
fi

# tr + xargs -0 em vez de mapfile: roda igual no bash 3.2 do macOS e no
# bash 5 do runner do GitHub.
git ls-files '*.dart' \
  | grep -v '^lib/l10n/generated/' \
  | tr '\n' '\0' \
  | xargs -0 dart format $modo
