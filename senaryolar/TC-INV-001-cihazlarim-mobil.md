---
id: TC-INV-001
title: Satıcı cihaz envanterini görüntüler (mobil)
domain: inventory
sub_domain: my-devices
priority: high
type: e2e
surface:
  - partner-app
tags:
  - inventory
  - device-list
  - value-check
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-inv-001-cihazlarim.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Cihaz envanterinin listelendiğini; ürün kodu, buybox/satış fiyatlarının doğru formatta gösterildiğini doğrular. **Mobil yapı:** alt menü 'Cihazlar' bir HUB açar (Cihazlarım / Aksesuarlarım); liste 'Cihazlarım' kartındadır.

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Alt menü 'Cihazlar' → hub'da '.*, Cihazlarım, .*' kartı | Cihazlarım listesi açılır |
| 2 | System | Liste yüklenir | 'Sırala', 'Filtrele', durum sekmeleri ('Online Satışa Açık' sayaçlı) görünür |
| 3 | User | Değerleri doğrula | Cihaz satırı 'Apple.*', 'Ürün Kodu', 'Buybox Fiyatı', 'Satış Fiyatı', `[0-9][0-9.,]* ₺` |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Hub doğru | 'Cihazlarım' ve 'Aksesuarlarım' kartları görünür |
| ER-2 | Liste doğru sayfa | '.*Filtrele' + 'Online Satışa Açık.*' görünür |
| ER-3 | Değerler | en az bir cihaz satırı + ürün kodu + ₺ fiyat formatı |

## Mobil Uyarlama Notları

- **Yüzey:** iOS Partner App (`com.getmobil.vendor`), Maestro ile koşulur. Web case'inin URL/`data-testid` adımları mobil karşılıklarıyla değiştirilmiştir.
- **Doğrulama ilkesi:** her adım hedef sayfaya ÖZGÜ öğelerle doğrulanır; öğe bulunamazsa test hata verir.
- **Erişilebilirlik:** bazı öğeler ikon glifli birleşik metin taşır (örn. "<ikon>, Bidbook, <ikon>") — desenler `.*` ile yazılır. Metinler `maestro hierarchy` çıktısından birebir alınmıştır.
- **Kanıt:** her ekran geçişinde `takeScreenshot`; koşum raporlarında galeri olarak sunulur.
