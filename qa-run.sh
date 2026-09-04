#!/bin/zsh
# Getmobil Partner QA — test suite runner
# Kullanım: ./qa-run.sh [flow1.yaml flow2.yaml ...]   (argümansız: tüm tc-*.yaml)
# - Açık (booted) simülatörü otomatik seçer (QA_DEVICE_UDID ile ezilebilir)
# - Yeni build'i (binary md5 değiştiyse) simülatöre kurar, izinleri verir
# - Her flow'u süre ölçümüyle koşar, ekran görüntülerini reports/evidence/ altına toplar
# - Özeti reports/last-run.txt dosyasına yazar (rapor ve Slack için)
set -u
cd "$(dirname "$0")"
set -a; source .env 2>/dev/null; set +a

APP_PATH="${QA_APP_PATH:-$HOME/qa-vendor-build/ios/build/Build/Products/Release-iphonesimulator/getmobilvendor.app}"
BUNDLE_ID="com.getmobil.vendor"
BUILD_REPO="$HOME/qa-vendor-build"

# ── Güncellik kontrolü: build, origin/preprod'un son haliyle aynı mı?
# Eski build'le koşulan test yanıltıcıdır — geride kalındıysa uyar (AUTO_UPDATE=1 → önce güncelle+derle)
if [ -d "$BUILD_REPO/.git" ] && [ -z "${QA_SKIP_FRESHNESS:-}" ]; then
  git -C "$BUILD_REPO" fetch origin preprod --quiet 2>/dev/null
  LOCAL_SHA=$(git -C "$BUILD_REPO" rev-parse HEAD 2>/dev/null)
  REMOTE_SHA=$(git -C "$BUILD_REPO" rev-parse origin/preprod 2>/dev/null)
  if [ -n "$REMOTE_SHA" ] && [ "$LOCAL_SHA" != "$REMOTE_SHA" ]; then
    BEHIND=$(git -C "$BUILD_REPO" rev-list --count HEAD..origin/preprod 2>/dev/null || echo "?")
    if [ "${AUTO_UPDATE:-0}" = "1" ]; then
      echo "⬆️  Build $BEHIND commit geride — AUTO_UPDATE=1: güncelleniyor ve yeniden derleniyor..."
      BRANCH=preprod "$(cd "$(dirname "$0")" && pwd)/ci/pr-check.sh" || { echo "güncelleme başarısız"; exit 1; }
    else
      echo "⚠️  UYARI: Build, origin/preprod'dan $BEHIND commit GERİDE (yerel: ${LOCAL_SHA:0:8}, uzak: ${REMOTE_SHA:0:8})."
      echo "    Güncel sürümle koşmak için: AUTO_UPDATE=1 ./qa-run.sh   veya   BRANCH=preprod ./ci/pr-check.sh"
    fi
  fi
fi

# ── Cihaz seçimi: QA_DEVICE_UDID > ilk açık simülatör > mevcut ilk iPhone'u boot et
UDID="${QA_DEVICE_UDID:-}"
if [ -z "$UDID" ]; then
  UDID=$(xcrun simctl list devices booted | grep -oE '[A-F0-9-]{36}' | head -1)
fi
if [ -z "$UDID" ]; then
  # Makineden bağımsız: mevcut ilk iPhone simülatörünü seç ve boot et (Lorin'in düzeltmesi)
  UDID=$(xcrun simctl list devices available | grep -E "iPhone" | grep -oE '[A-F0-9-]{36}' | head -1)
  [ -n "$UDID" ] && xcrun simctl boot "$UDID" 2>/dev/null
fi
[ -z "$UDID" ] && { echo "HATA: kullanılabilir iPhone simülatörü yok"; exit 1; }
xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1

DEVICE_NAME=$(xcrun simctl list devices | grep "$UDID" | head -1 | sed -E 's/^ *(.*) \([A-F0-9-]{36}.*$/\1/')
OS_VERSION=$(xcrun simctl list devices | grep -B50 "$UDID" | grep -E "^-- iOS" | tail -1 | sed -E 's/-- iOS ([0-9.]+) --/\1/')
APP_VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP_PATH/Info.plist" 2>/dev/null || echo "?")

# ── Uygulama kurulu mu / binary güncel mi? (Lorin'in düzeltmesi: eski binary'nin
# sessizce test edilmesini önlemek için kurulu binary ile yeni build md5 karşılaştırılır)
INSTALLED=$(xcrun simctl get_app_container "$UDID" "$BUNDLE_ID" 2>/dev/null || true)
NEW_MD5=$(md5 -q "$APP_PATH/getmobilvendor" 2>/dev/null || echo yeni-yok)
OLD_MD5=$([ -n "$INSTALLED" ] && md5 -q "$INSTALLED/getmobilvendor" 2>/dev/null || echo kurulu-yok)
if [ "$NEW_MD5" != "$OLD_MD5" ]; then
  echo "→ binary değişmiş/eksik: yeni build kuruluyor ($OLD_MD5 → $NEW_MD5)"
  xcrun simctl install "$UDID" "$APP_PATH" || { echo "HATA: kurulum başarısız"; exit 1; }
fi
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
echo "APP_COMMIT=$(git -C "$BUILD_REPO" rev-parse --short HEAD 2>/dev/null || echo bilinmiyor)" >> "$SUMMARY"
echo "RUN_DATE=$(date '+%d.%m.%Y %H:%M')" >> "$SUMMARY"

FLOWS=("$@")
[ ${#FLOWS[@]} -eq 0 ] && FLOWS=(.maestro/tc-*.yaml)

TOTAL_S=$(date +%s)
for FLOW in "${FLOWS[@]}"; do
  NAME=$(basename "$FLOW" .yaml)
  S=$(date +%s)
  RETRY=0
  maestro --device "$UDID" test \
    -e TEST_EMAIL="$TEST_EMAIL" -e TEST_PASSWORD="$TEST_PASSWORD" \
    "$FLOW" > "/tmp/qa-$NAME.log" 2>&1
  RC=$?
  # Flake koruması: düşen test bir kez daha denenir (CI standardı)
  if [ $RC -ne 0 ]; then
    RETRY=1
    maestro --device "$UDID" test \
      -e TEST_EMAIL="$TEST_EMAIL" -e TEST_PASSWORD="$TEST_PASSWORD" \
      "$FLOW" > "/tmp/qa-$NAME.log" 2>&1
    RC=$?
  fi
  DUR=$(( $(date +%s) - S ))
  if [ $RC -eq 0 ]; then
    [ $RETRY -eq 1 ] && RESULT="PASS(retry)" || RESULT="PASS"
  else RESULT="FAIL"; fi
  echo "TEST|$NAME|$RESULT|${DUR}sn|retry=$RETRY" >> "$SUMMARY"
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
