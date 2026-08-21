#!/bin/zsh
# App repodaki açık PR'ları izler; yeni/güncellenmiş her PR head'i için pr-check.sh koşar.
# launchd tarafından periyodik çağrılır (tek geçiş). Eşzamanlı koşumları lockfile serileştirir.
set -u
QA_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_REPO="Getmobil/getmobil-vendor-mobile-app"
STATE_DIR="$HOME/.qa-ci"; mkdir -p "$STATE_DIR"
STATE="$STATE_DIR/tested-shas.txt"; touch "$STATE"
LOCK="$STATE_DIR/run.lock"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Zaten bir koşum sürüyorsa çık (sonraki tetiklemede yakalanır)
if [ -f "$LOCK" ] && kill -0 "$(cat "$LOCK")" 2>/dev/null; then exit 0; fi
echo $$ > "$LOCK"; trap 'rm -f "$LOCK"' EXIT

gh pr list --repo "$APP_REPO" --state open --json number,headRefOid --limit 20 2>/dev/null | \
python3 -c "import json,sys; [print(p['number'], p['headRefOid']) for p in json.load(sys.stdin)]" | \
while read -r NUM SHA; do
  grep -q "^$NUM $SHA$" "$STATE" && continue
  echo "$(date) — PR #$NUM ($SHA) test ediliyor" >> "$STATE_DIR/watcher.log"
  "$QA_DIR/ci/pr-check.sh" "$NUM"
  # Sonuç ne olursa olsun bu SHA işlendi olarak işaretlenir (yeni push'ta yeniden test edilir)
  grep -v "^$NUM " "$STATE" > "$STATE.tmp" 2>/dev/null || true
  echo "$NUM $SHA" >> "$STATE.tmp"; mv "$STATE.tmp" "$STATE"
done
