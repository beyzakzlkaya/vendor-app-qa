# Vendor App — Test Otomasyonu

Getmobil vendor mobil uygulaması (iOS + Android) için AI destekli test otomasyonu projesi.

## Yapı

```
vendor-app-qa/
├── apps/          → Test edilecek build'ler (Android .apk, iOS .app)
├── .maestro/      → UI test senaryoları (Maestro flow'ları, YAML)
├── api-tests/     → API test koleksiyonları (Postman export'ları)
└── README.md      → Bu dosya
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

## Dev ekibinden istenecekler

- [ ] Android universal `.apk` (her release'te — CI artifact olarak idealdir)
- [ ] iOS simulator build `.app` (arm64, `xcodebuild -sdk iphonesimulator`)
- [x] Test ortamı (preprod) kullanıcı hesabı → `.env` dosyasında (git'e gönderilmez)
