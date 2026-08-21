# Test Result Template (Slack mesaj formatı)

Her Maestro koşumundan sonra bu şablon doldurulur ve belirlenen Slack kanalına gönderilir.

## Başarılı / genel şablon

```
📱 *APPLICATION TEST RESULT*

━━━━━━━━━━━━━━━━━━━━━━
*Durum:* {{STATUS_EMOJI}} *{{STATUS}}*
*Test:* {{TEST_NAME}}
*Platform:* {{PLATFORM}}
*Ortam:* {{ENVIRONMENT}}
*Build / Versiyon:* {{APP_VERSION}}
*Branch:* `{{BRANCH_NAME}}`
*Koşum zamanı:* {{EXECUTION_DATE}}
*Toplam süre:* {{DURATION}}
━━━━━━━━━━━━━━━━━━━━━━

*Test Adımları*

{{STEP_N_STATUS}} <her adım ayrı satır — flow'daki gerçek adımlar>

*Özet*

✅ Başarılı: {{PASSED_COUNT}}
❌ Başarısız: {{FAILED_COUNT}}
⏭️ Atlanan: {{SKIPPED_COUNT}}
📊 Toplam: {{TOTAL_TEST_COUNT}}

{{FAILURE_SECTION}}

🔗 *Detaylı rapor:* {{REPORT_URL}}
🎬 *Video / ekran görüntüsü:* {{EVIDENCE_URL}}
👤 *Tetikleyen:* {{TRIGGERED_BY}}
```

## Başarısız koşumda {{FAILURE_SECTION}}

```
*Hata Detayı*

📍 Başarısız adım: {{FAILED_STEP}}
📝 Hata mesajı: `{{ERROR_MESSAGE}}`
📱 Cihaz: {{DEVICE_NAME}}
🧩 İşletim sistemi: {{OS_VERSION}}
🔁 Deneme sayısı: {{RETRY_COUNT}}
📋 Jira kaydı: {{JIRA_KEY}} — {{JIRA_URL}}
```

## Bug → Jira kuralı (Beyza'nın talimatı, 21 Ağu 2026)

Gerçek bir uygulama hatası bulunduğunda (test altyapı hatası DEĞİL):
1. NE projesinde **Bug** tipinde kayıt aç (öncelik: etkiye göre, etiketler: qa-otomasyon, partner-app, ortam)
2. Kaydı **aktif sprint'e** ekle (Board 35 — Getmobil Technology Board)
3. Test result Slack mesajının Hata Detayı bölümüne **Jira linkini** ekle
4. Kayıt içeriği: özet, beklenen/gerçekleşen, yeniden üretme adımları, artifact rapor linki, temizlik notu

## Doldurma kuralları

- Başarılı koşum: STATUS_EMOJI=✅, STATUS=TEST BAŞARILI, tüm adımlar ✅, FAILURE_SECTION boş
- Başarısız koşum: STATUS_EMOJI=❌, STATUS=TEST BAŞARISIZ, başarısız adım ❌, sonrası ⏭️ (atlanan)
- DURATION: koşum başı/sonu arasındaki gerçek süre (date ile ölçülür)
- REPORT_URL / EVIDENCE_URL: Maestro debug klasörü (~/.maestro/tests/<tarih>) — URL yoksa yerel yol
- APP_VERSION: .app Info.plist CFBundleShortVersionString
- TRIGGERED_BY: koşumu isteyen kişi
