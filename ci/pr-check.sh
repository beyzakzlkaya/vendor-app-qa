#!/bin/zsh
# Tek bir PR'ı (veya branch'i) kontrol eder: build → smoke süiti → PR yorumu + Slack
# Kullanım: ./ci/pr-check.sh <PR_NUMARASI>        (PR modu)
#          BRANCH=preprod ./ci/pr-check.sh        (branch modu, PR yorumu atlanır)
set -u
QA_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$HOME/qa-vendor-build"
APP_REPO="Getmobil/getmobil-vendor-mobile-app"
PR_NUM="${1:-}"
BRANCH="${BRANCH:-}"
SMOKE_FLOWS=(.maestro/tc-identity-001-giris.yaml .maestro/tc-order-006-siparis-listesi.yaml .maestro/tc-fin-001-kasam.yaml)
[ "${FULL:-0}" = "1" ] && SMOKE_FLOWS=(.maestro/tc-*.yaml)

set -a; source "$QA_DIR/.env" 2>/dev/null; set +a
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
LOG_DIR="$HOME/.qa-ci/logs"; mkdir -p "$LOG_DIR"
STAMP=$(date "+%Y%m%d-%H%M%S")
LOG="$LOG_DIR/pr-${PR_NUM:-$BRANCH}-$STAMP.log"
exec >> "$LOG" 2>&1
echo "=== PR check başladı: $(date) — PR=$PR_NUM BRANCH=$BRANCH ==="

# Mac uyumasın
caffeinate -i -w $$ &

# ── 1) Kodu getir
cd "$BUILD_DIR"
OLD_NPM_HASH=$(md5 -q package-lock.json 2>/dev/null || echo none)
OLD_POD_HASH=$(md5 -q ios/Podfile.lock 2>/dev/null || echo none)
git fetch origin --quiet
if [ -n "$PR_NUM" ]; then
  git fetch origin "pull/$PR_NUM/head:ci-pr-$PR_NUM" --force --quiet || { echo "PR fetch hatası"; exit 2; }
  git checkout -f "ci-pr-$PR_NUM" --quiet
  HEAD_SHA=$(git rev-parse HEAD)
else
  git checkout -f "$BRANCH" --quiet; git reset --hard "origin/$BRANCH" --quiet
  HEAD_SHA=$(git rev-parse HEAD)
fi
echo "HEAD: $HEAD_SHA"

# ── 2) Bağımlılıklar (yalnızca lock değiştiyse)
[ "$(md5 -q package-lock.json)" != "$OLD_NPM_HASH" ] && { echo "npm ci..."; npm ci --legacy-peer-deps >/dev/null 2>&1 || exit 3; }
# React sürüm yaması gerekiyorsa uygula (master tabanlı branch'ler için)
grep -q '"19.1.1" !== isomorphicReactPackageVersion' node_modules/react-native/Libraries/Renderer/implementations/ReactNativeRenderer-prod.js 2>/dev/null && \
  sed -i '' 's/"19\.1\.1" !== isomorphicReactPackageVersion/"19.1.2" !== isomorphicReactPackageVersion/g' node_modules/react-native/Libraries/Renderer/implementations/ReactNativeRenderer-*.js
[ "$(md5 -q ios/Podfile.lock)" != "$OLD_POD_HASH" ] && { echo "pod install..."; (cd ios && pod install) >/dev/null 2>&1 || exit 3; }
[ -f ios/.xcode.env.local ] || echo 'export NODE_BINARY=/opt/homebrew/bin/node' > ios/.xcode.env.local
[ -f .env ] || cp "$QA_DIR/ci/app-env-preprod" .env 2>/dev/null || true

# ── 3) Build
echo "xcodebuild başladı: $(date)"
cd ios
xcodebuild -workspace getmobilvendor.xcworkspace -scheme getmobilvendor \
  -configuration Release -sdk iphonesimulator -derivedDataPath build build \
  > /tmp/qa-ci-xcodebuild.log 2>&1
APP="$BUILD_DIR/ios/build/Build/Products/Release-iphonesimulator/getmobilvendor.app"
if [ ! -f "$APP/main.jsbundle" ] || [ ! -f "$APP/getmobilvendor" ]; then
  echo "BUILD BAŞARISIZ"; RESULT_TITLE="🔨 BUILD BAŞARISIZ"; BUILD_OK=0
else
  echo "build tamam: $(date)"; BUILD_OK=1
fi

# ── 4) Test süiti (build başarılıysa)
SUITE_SUMMARY=""
if [ "$BUILD_OK" = "1" ]; then
  cd "$QA_DIR"
  QA_APP_PATH="$APP" ./qa-run.sh "${SMOKE_FLOWS[@]}"
  SUITE_SUMMARY=$(cat "$QA_DIR/reports/last-run.txt")
  FAILS=$(echo "$SUITE_SUMMARY" | grep -c "|FAIL|" || true)
  TOTAL=$(echo "$SUITE_SUMMARY" | grep -c "^TEST|" || true)
  if [ "$FAILS" = "0" ]; then RESULT_TITLE="✅ TÜM TESTLER GEÇTİ ($TOTAL/$TOTAL)"; else RESULT_TITLE="❌ TEST BAŞARISIZ ($((TOTAL-FAILS))/$TOTAL geçti)"; fi
fi

# ── 5) Sonucu derle
VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP/Info.plist" 2>/dev/null || echo "?")
DEVICE=$(grep DEVICE_NAME "$QA_DIR/reports/last-run.txt" 2>/dev/null | cut -d= -f2)
TESTS_MD=$(echo "$SUITE_SUMMARY" | grep "^TEST|" | awk -F'|' '{icon=($3~/PASS/)?"✅":"❌"; print "| "icon" | `"$2"` | "$3" | "$4" |"}')
BODY="## 🤖 Getmobil QA Otomasyonu — PR Kontrolü

**Sonuç: $RESULT_TITLE**

| | Test | Durum | Süre |
|---|---|---|---|
$TESTS_MD

- **Commit:** \`${HEAD_SHA:0:10}\` · **Versiyon:** $VERSION · **Cihaz:** ${DEVICE:-—} (Simülatör)
- **Ortam:** Preprod · **Kapsam:** duman süiti (giriş, sipariş listesi, cüzdan)
$([ "$BUILD_OK" = "0" ] && echo "- ⚠️ Simulator build alınamadı — xcodebuild logu QA makinesinde: /tmp/qa-ci-xcodebuild.log")

_Kanıt ekran görüntüleri QA makinesinde saklanır; detaylı rapor istenirse QA ekibine ulaşın._"

# ── 6) Raporla: PR yorumu + Slack
if [ -n "$PR_NUM" ]; then
  echo "$BODY" | gh pr comment "$PR_NUM" --repo "$APP_REPO" --body-file - && echo "PR yorumu atıldı"
fi
SLACK_TEXT=$(python3 - "$RESULT_TITLE" "$PR_NUM" "$HEAD_SHA" "$VERSION" << 'PYEOF'
import json,sys,subprocess
title,pr,sha,ver=sys.argv[1:5]
lines=[l.split('|') for l in open('reports/last-run.txt').read().splitlines() if l.startswith('TEST|')]
tests="\n".join(("✅ " if "PASS" in l[2] else "❌ ")+l[1]+" — "+l[3] for l in lines) or "(build hatası — test koşulamadı)"
pr_line=f"*PR:* <https://github.com/Getmobil/getmobil-vendor-mobile-app/pull/{pr}|#{pr}>\n" if pr else ""
print(json.dumps({"text":f"🤖 *CI — PR KONTROLÜ*\n\n*Sonuç:* {title}\n{pr_line}*Commit:* `{sha[:10]}` · *Versiyon:* {ver} · *Ortam:* Preprod\n\n{tests}"}))
PYEOF
)
[ -n "${SLACK_WEBHOOK_URL:-}" ] && curl -sS -X POST -H "Content-Type: application/json" -d "$SLACK_TEXT" "$SLACK_WEBHOOK_URL" >/dev/null && echo "Slack gönderildi"
echo "=== bitti: $(date) ==="
[ "$BUILD_OK" = "1" ] && [ "${FAILS:-1}" = "0" ]
