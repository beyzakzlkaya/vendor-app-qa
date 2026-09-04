---
id: TC-INV-006
title: Flaş ürün kampanyaları listesi (mobil)
domain: inventory
sub_domain: flash-products
priority: medium
type: e2e
surface:
  - partner-app
tags:
  - flash
  - campaign
  - value-check
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-inv-006-flas-urunler.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Flaş ürün kampanyalarının listelendiğini; kampanya tarihi, kalan zaman, komisyon dilimleri ve katılım aksiyonunun görünür olduğunu doğrular. **Mobil giriş:** çekmece → 'Fırsatlar' (genişlet) → 'Flaş Ürünler'.

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Çekmece → 'Fırsatlar, .*' → 'Flaş Ürünler, .*' | Flaş Ürünler sayfası açılır |
| 2 | System | Kampanya yüklenir | 'Kampanya Tarihi:' ve 'Kalan Zaman:' görünür |
| 3 | User | Değerleri doğrula | Tarih `.*[0-9]{2}.[0-9]{2}.[0-9]{4}.*`, ürün '(Apple|Samsung).*', 'Teklife Katıl', `%[0-9.]+ komisyon`, `Mevcut Stoğum: [0-9]+` |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Sayfa yüklenir | 'Kampanya Tarihi:' görünür (sayfaya özgü) |
| ER-2 | Kampanya dolu | en az bir ürün + 'Teklife Katıl' görünür |
| ER-3 | Değer formatları | tarih, komisyon yüzdesi, stok sayacı desenlere uyar |

## Mobil Uyarlama Notları

- **Yüzey:** iOS Partner App (`com.getmobil.vendor`), Maestro ile koşulur. Web case'inin URL/`data-testid` adımları mobil karşılıklarıyla değiştirilmiştir.
- **Doğrulama ilkesi:** her adım hedef sayfaya ÖZGÜ öğelerle doğrulanır; öğe bulunamazsa test hata verir.
- **Erişilebilirlik:** bazı öğeler ikon glifli birleşik metin taşır (örn. "<ikon>, Bidbook, <ikon>") — desenler `.*` ile yazılır. Metinler `maestro hierarchy` çıktısından birebir alınmıştır.
- **Kanıt:** her ekran geçişinde `takeScreenshot`; koşum raporlarında galeri olarak sunulur.
