# Vendor App — Test Otomasyonu

Getmobil vendor mobil uygulaması (iOS + Android) için AI destekli test otomasyonu projesi.

## Yapı

```
vendor-app-qa/
├── .maestro/      → Çalıştırılabilir testler (tc-* = süit, mut-* = veri değiştiren/manuel,
│                    subflows/giris.yaml = ortak giriş akışı)
├── senaryolar/    → Senaryo dokümanları (kütüphane formatı .md — prompt-library PR kaynağı)
├── ci/            → PR izleyici + kontrolcü + resmi workflow önerisi
├── templates/     → Slack test sonuç şablonu ve doldurma kuralları
├── reports/       → Koşum özetleri + ekran kanıtları (git dışı)
├── qa-run.sh      → Süit koşucusu (cihaz seçimi, md5'li kurulum, retry, kanıt toplama)
└── COVERAGE.md    → Kütüphane case'lerinin mobil kapsam durumu
```

## Nasıl çalışır?

1. **Build gelir** — Dev ekibi her release'te `apps/` klasörüne konacak build'leri üretir:
   - Android: `.apk` (universal APK)
   - iOS: `.app` (simulator build, arm64)
2. **Senaryo tarif edilir** — Test edilecek akış Türkçe anlatılır
   ("kullanıcı giriş yapar, sipariş listesini görür" gibi).
3. **Claude flow'u yazar** — Senaryo `.maestro/` altında YAML flow'a dönüşür.
   Aynı flow hem Android hem iOS'ta çalışır.
4. **Test koşar** — Android emülatöründe / iOS simülatöründe çalıştırılır,
   sonuç ve ekran kayıtları raporlanır.
5. **API testleri** — Postman koleksiyonları ile backend endpoint'leri test edilir;
   Postman Monitor ile zamanlanmış otomatik koşum yapılabilir.

## Kurulu araçlar

| Araç | Durum |
|------|-------|
| Maestro 2.8.0 | ✅ Kurulu |
| adb (Android platform tools) | ✅ Kurulu |
| Java (OpenJDK) | ✅ Kurulu |
| Android emülatör (`vendor-test`, Pixel 7 / Android 15) | ✅ Kurulu, duman testi geçti |
| Xcode 26.6 + iOS Simulator (iPhone 17) | ✅ Kurulu — login testi GEÇİYOR |

## Notlar

- iOS build'i dev ekibinden istenmez — `~/qa-vendor-build` klonundan derlenir (`AUTO_UPDATE=1 ./qa-run.sh`)
- Android fazı başladığında `.apk` akışı buraya eklenecek (emülatör `vendor-test` hazır)

## CI — PR başına otomatik kontrol (21 Ağustos 2026)

Her açık PR, bu Mac'te 10 dakikada bir çalışan izleyiciyle otomatik test edilir:

- `ci/pr-watcher.sh` — launchd (`com.getmobil.qa-pr-watcher`, 10 dk) app repodaki PR'ları izler; yeni head SHA'yı `ci/pr-check.sh`'a verir
- `ci/pr-check.sh` — PR branch'ini çeker, gerekirse bağımlılıkları kurar, simulator build alır, duman süitini koşar (FULL=1 → 7'li tam süit), sonucu **PR yorumu + Slack** olarak yayınlar
- Durum/loglar: `~/.qa-ci/` (watcher.log, logs/, tested-shas.txt)
- Durdur/başlat: `launchctl unload|load ~/Library/LaunchAgents/com.getmobil.qa-pr-watcher.plist`
- `ci/github-workflow-onerisi.yml` — dev ekibi onaylayınca app repoya taşınacak resmi Actions workflow'u (status check + merge engelleme için)

## Yeni QA makinesi kurulumu (4 Eylül 2026 — Lorin'in kurulumundan dersler)

1. **Önkoşullar:** Xcode + iOS platformu, `brew install mobile-dev-inc/tap/maestro cocoapods node`, `gh auth login`
2. **Build klonu:** `gh repo clone Getmobil/getmobil-vendor-mobile-app ~/qa-vendor-build` → `.env`'i preprod değerleriyle oluştur (bkz. ci/app-env-preprod şablonu — QA ekibinden isteyin, git'te YOK)
3. **Bu repo:** `.env` dosyasını oluştur (TEST_EMAIL, TEST_PASSWORD, SLACK_WEBHOOK_URL — git'te YOK)
4. **Simülatörde AutoFill'i kapatın** (bir kez): Settings → General → AutoFill & Passwords → kapalı.
   Kapatılmazsa her girişte "Save Password" diyaloğu çıkar; testler yine geçer (iki katmanlı savunma var)
   ama süreler uzar ve retry oranı artar.
5. İlk koşum: `AUTO_UPDATE=1 ./qa-run.sh` (güncel preprod'u derler + koşar)

**Hesaba bağlı etiketler:** bazı ekran etiketleri hesabın yeteneklerine göre değişir
(mağaza modlu hesapta: "Satışa Açık • N", "SKU:", "Online Satış Fiyatı"). Test desenleri
iki varyantı da kapsar — yeni varyant görürseniz deseni genişletin, testi hesaba özel yazmayın.
