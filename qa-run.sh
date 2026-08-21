#!/bin/zsh
# Getmobil Partner QA — test suite runner
# Kullanım: ./qa-run.sh [flow1.yaml flow2.yaml ...]   (argümansız: tüm tc-*.yaml)
# - Açık (booted) simülatörü otomatik seçer (QA_DEVICE_UDID ile ezilebilir)
# - Uygulama kurulu değilse kurar, izinleri verir
# - Her flow'u süre ölçümüyle koşar, ekran görüntülerini reports/evidence/ altına toplar
# - Özeti reports/last-run.txt dosyasına yazar (rapor ve Slack için)
set -u
cd "$(dirname "$0")"
set -a; source .env 2>/dev/null; set +a

APP_PATH="${QA_APP_PATH:-/Users/beyzakizilkaya/qa-vendor-build/ios/build/Build/Products/Release-iphonesimulator/getmobilvendor.app}"
BUNDLE_ID="com.getmobil.vendor"

# ── Cihaz seçimi: QA_DEVICE_UDID > ilk açık simülatör > iPhone 17'yi boot et
UDID="${QA_DEVICE_UDID:-}"
if [ -z "$UDID" ]; then
  UDID=$(xcrun simctl list devices booted | grep -oE '[A-F0-9-]{36}' | head -1)
fi
if [ -z "$UDID" ]; then
  UDID="7CD8F910-19BE-44DF-9453-9367D0CCBD2C"
  xcrun simctl boot "$UDID" 2>/dev/null
fi
xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1

DEVICE_NAME=$(xcrun simctl list devices | grep "$UDID" | head -1 | sed -E 's/^ *(.*) \([A-F0-9-]{36}.*$/\1/')
OS_VERSION=$(xcrun simctl list devices | grep -B50 "$UDID" | grep -E "^-- iOS" | tail -1 | sed -E 's/-- iOS ([0-9.]+) --/\1/')
APP_VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP_PATH/Info.plist" 2>/dev/null || echo "?")

# ── Uygulama kurulu mu?
xcrun simctl get_app_container "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || xcrun simctl install "$UDID" "$APP_PATH"
xcrun simctl privacy "$UDID" grant all "$BUNDLE_ID" 2>/dev/null

RUN_ID=$(date "+%Y%m%d-%H%M%S")
EV_DIR="reports/evidence/$RUN_ID"
mkdir -p "$EV_DIR"
SUMMARY="reports/last-run.txt"
: > "$SUMMARY"
echo "RUN_ID=$RUN_ID" >> "$SUMMARY"
echo "DEVICE_NAME=$DEVICE_NAME" >> "$SUMMARY"
echo "DEVICE_UDID=$UDID" >> "$SUMMARY"
echo "OS_VERSION=iOS $OS_VERSION" >> "$SUMMARY"
echo "APP_VERSION=$APP_VERSION" >> "$SUMMARY"
echo "RUN_DATE=$(date '+%d.%m.%Y %H:%M')" >> "$SUMMARY"

FLOWS=("$@")
[ ${#FLOWS[@]} -eq 0 ] && FLOWS=(.maestro/tc-*.yaml)

TOTAL_S=$(date +%s)
for FLOW in "${FLOWS[@]}"; do
  NAME=$(basename "$FLOW" .yaml)
  S=$(date +%s)
  maestro --device "$UDID" test \
    -e TEST_EMAIL="$TEST_EMAIL" -e TEST_PASSWORD="$TEST_PASSWORD" \
    "$FLOW" > "/tmp/qa-$NAME.log" 2>&1
  RC=$?
  DUR=$(( $(date +%s) - S ))
  if [ $RC -eq 0 ]; then RESULT="PASS"; else RESULT="FAIL"; fi
  echo "TEST|$NAME|$RESULT|${DUR}sn" >> "$SUMMARY"
  # Başarısızsa hata satırını da kaydet
  [ $RC -ne 0 ] && grep -m1 -E "FAILED|Assertion|Element not found" "/tmp/qa-$NAME.log" | sed "s/^/ERROR|$NAME|/" >> "$SUMMARY"
  # Ekran görüntülerini topla (bu koşumun maestro dizininden)
  LAST_DIR=$(ls -td ~/.maestro/tests/*/ 2>/dev/null | head -1)
  if [ -n "$LAST_DIR" ]; then
    mkdir -p "$EV_DIR/$NAME"
    find "$LAST_DIR" -name "*.png" -exec cp {} "$EV_DIR/$NAME/" \; 2>/dev/null
    # Başarısızlıkta maestro'nun otomatik hata görüntüsü de gelir
  fi
done
echo "TOTAL_DURATION=$(( $(date +%s) - TOTAL_S ))sn" >> "$SUMMARY"
echo "─── ÖZET ───"
cat "$SUMMARY"
