---
id: TC-ORDER-007
title: Sipariş detayı içerik ve değer kontrolleri (mobil)
domain: order
sub_domain: order-detail
priority: high
type: e2e
surface:
  - partner-app
tags:
  - order-detail
  - value-check
  - vendor
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-order-007-siparis-detayi.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Sipariş listesindeki alanların DEĞER formatlarını (sipariş no deseni, ₺ tutar) ve detay sayfasının içeriklerini (adres blokları) doğrular.

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Siparişler hub → Siparişler listesi | Liste açılır |
| 2 | User | Liste değerlerini doğrula | 'Sipariş Numarası' etiketi + no deseni `[A-Z][A-Z0-9]{2,5}[0-9]{6,}` (ONGMN00847406, B2BN84926980 gibi kanal önekleri) + 'Toplam Tutar:' + `[0-9][0-9.,]* ₺` |
| 3 | User | 'Detayı Gör'e dokun | Detay açılır; 'Devredilen Sipariş' modalı iki turlu kapatılır |
| 4 | User | 'Teslimat Adresi:'ne kadar kaydır | 'Teslimat Adresi:' ve 'Fatura Adresi:' blokları görünür |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Sipariş no formatı | `[A-Z][A-Z0-9]{2,5}[0-9]{6,}` desenine uyan değer listede görünür |
| ER-2 | Tutar formatı | `[0-9][0-9.,]* ₺` desenine uyan tutar görünür |
| ER-3 | Detay içerikleri | 'Satış Kanalı', 'Teslimat Adresi:', 'Fatura Adresi:' görünür |

> **Öğrenilen ders (4 Eyl 2026):** sipariş no önekinde rakam olabilir (BBTS kanalı: B2BN…) — desen kanal öneklerini kapsayacak şekilde genişletildi.

## Mobil Uyarlama Notları

- **Yüzey:** iOS Partner App (`com.getmobil.vendor`), Maestro ile koşulur. Web case'inin URL/`data-testid` adımları mobil karşılıklarıyla değiştirilmiştir.
- **Doğrulama ilkesi:** her adım hedef sayfaya ÖZGÜ öğelerle doğrulanır; öğe bulunamazsa test hata verir.
- **Erişilebilirlik:** bazı öğeler ikon glifli birleşik metin taşır (örn. "<ikon>, Bidbook, <ikon>") — desenler `.*` ile yazılır. Metinler `maestro hierarchy` çıktısından birebir alınmıştır.
- **Kanıt:** her ekran geçişinde `takeScreenshot`; koşum raporlarında galeri olarak sunulur.
