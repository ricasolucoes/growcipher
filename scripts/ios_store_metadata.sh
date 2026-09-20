#!/usr/bin/env bash
# Materializa os metadados localizados usados pelo fastlane deliver.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_ROOT="$PROJECT_ROOT/fastlane/metadata/android"
OUTPUT_ROOT="$PROJECT_ROOT/fastlane/metadata/ios"

mkdir -p "$OUTPUT_ROOT"

write_locale() {
  local source_locale="$1"
  local app_locale="$2"
  local subtitle="$3"
  local keywords="$4"
  local promotional_text="$5"
  local release_notes="$6"
  local legal_note="$7"
  local source_dir="$ANDROID_ROOT/$source_locale"
  local output_dir="$OUTPUT_ROOT/$app_locale"

  test -f "$source_dir/title.txt"
  test -f "$source_dir/full_description.txt"
  mkdir -p "$output_dir"
  cp "$source_dir/title.txt" "$output_dir/name.txt"
  printf '%s\n' "$subtitle" > "$output_dir/subtitle.txt"
  {
    cat "$source_dir/full_description.txt"
    printf '\n\n%s\n' "$legal_note"
  } > "$output_dir/description.txt"
  printf '%s\n' "$keywords" > "$output_dir/keywords.txt"
  printf '%s\n' "$promotional_text" > "$output_dir/promotional_text.txt"
  printf '%s\n' "$release_notes" > "$output_dir/release_notes.txt"
  printf '%s\n' 'https://github.com/ricasolucoes/growcipher' > "$output_dir/marketing_url.txt"
  printf '%s\n' 'https://github.com/ricasolucoes/growcipher' > "$output_dir/support_url.txt"
  printf '%s\n' '© 2026 Sierra Tecnologia LTDA' > "$output_dir/copyright.txt"
}

write_locale de-DE de-DE \
  'Lokales Grow-Tagebuch' \
  'grow tagebuch,pflanzen,offline,privatsphäre,anbau,gießen,ernte' \
  'Dein lokales Tagebuch für Pflanzen, Zyklen und Ereignisse.' \
  'Erster GrowCipher-Release: Pflanzen anlegen, Ereignisse erfassen und den Verlauf lokal behalten.' \
  'Nutzen Sie die App nur im Rahmen der an Ihrem Ort geltenden Gesetze.'
write_locale en-US en-US \
  'A private grow journal' \
  'grow journal,plant tracker,offline,privacy,plant log,watering,harvest' \
  'Track plants, cycles and events locally, without a required account.' \
  'First GrowCipher release: create a plant, record events and keep the timeline on your device.' \
  'Use the app only in accordance with the laws that apply where you live.'
write_locale es-ES es-ES \
  'Diario local de cultivo' \
  'diario,cultivo,plantas,offline,privacidad,riego,siembra,cosecha' \
  'Registra plantas, ciclos y eventos localmente, sin una cuenta obligatoria.' \
  'Primera versión de GrowCipher: crea una planta, registra eventos y conserva el historial en tu dispositivo.' \
  'Usa la aplicación únicamente de acuerdo con las leyes aplicables en tu lugar de residencia.'
write_locale fr-FR fr-FR \
  'Journal local de culture' \
  'journal,culture,plantes,hors ligne,confidentialité,arrosage,récolte' \
  'Suivez vos plantes et vos événements localement, sans compte obligatoire.' \
  'Première version de GrowCipher : créez une plante, notez les événements et gardez l’historique sur l’appareil.' \
  'Utilisez l’application uniquement conformément aux lois applicables dans votre lieu de résidence.'
write_locale it-IT it \
  'Diario locale di coltivazione' \
  'diario,coltivazione,piante,offline,privacy,irrigazione,raccolto' \
  'Registra piante, cicli ed eventi in locale, senza un account obbligatorio.' \
  'Prima versione di GrowCipher: crea una pianta, registra gli eventi e conserva la cronologia sul dispositivo.' \
  'Usa l’applicazione esclusivamente nel rispetto delle leggi applicabili nel luogo in cui vivi.'
write_locale ja-JP ja \
  'ローカル栽培日誌' \
  '栽培日誌,植物,オフライン,プライバシー,水やり,収穫,記録' \
  '植物、サイクル、出来事を端末に記録。アカウントは必須ではありません。' \
  'GrowCipher 初回リリース：植物を登録し、出来事を記録し、履歴を端末に保存できます。' \
  'お住まいの地域で適用される法律に従ってご利用ください。'
write_locale pt-BR pt-BR \
  'Diário local do cultivo' \
  'cultivo,diário,plantas,offline,privacidade,rega,plantio,colheita' \
  'Registre plantas, ciclos e eventos localmente, sem conta obrigatória.' \
  'Primeiro lançamento do GrowCipher: cadastre uma planta, registre acontecimentos e mantenha o histórico no aparelho.' \
  'Use o aplicativo somente de acordo com a legislação aplicável no seu local.'
write_locale ru-RU ru \
  'Дневник выращивания' \
  'дневник,выращивание,растения,офлайн,приватность,полив,урожай' \
  'Записывайте растения и события локально, без обязательной учетной записи.' \
  'Первый релиз GrowCipher: создавайте растения, записывайте события и храните историю на устройстве.' \
  'Используйте приложение только в соответствии с законами, действующими в вашем регионе.'
write_locale zh-CN zh-Hans \
  '本地种植记录日记' \
  '种植日记,植物,离线,隐私,浇水,收获,记录' \
  '在本地记录植物、生长周期和事件，无需强制注册账号。' \
  'GrowCipher 首个版本：创建植物、记录事件，并将历史保存在设备上。' \
  '请仅根据您所在地区适用的法律使用本应用。'

for locale in de-DE en-US es-ES fr-FR it ja pt-BR ru zh-Hans; do
  for file in name.txt subtitle.txt description.txt keywords.txt promotional_text.txt release_notes.txt marketing_url.txt support_url.txt copyright.txt; do
    test -s "$OUTPUT_ROOT/$locale/$file"
  done
done

printf '%s\n' 'Prepared iOS metadata for: de-DE en-US es-ES fr-FR it ja pt-BR ru zh-Hans'
