---
id: TC-ORDER-011
title: İade raporu görüntüleme (mobil)
domain: order
sub_domain: returns
priority: medium
type: e2e
surface:
  - partner-app
tags:
  - returns
  - report
  - value-check
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-order-011-iade-raporu.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Satıcının iade raporuna ulaşabildiğini; iade sayaçları, kaybedilen ciro ve sebep dağılımının doğru formatlarla listelendiğini doğrular.

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Siparişler hub → 'İade Raporu' kartı (desen: '.*, İade Raporu, .*') | Rapor sayfası açılır |
| 2 | System | Rapor yüklenir | 'Toplam İade', 'Bayi Kaynaklı İade Sayısı', 'Müşteri Kaynaklı İade Sayısı', 'Kaybedilen Ciro' görünür |
| 3 | User | Değerleri doğrula | Sayaç `[0-9]+ Adet`, ciro `[0-9][0-9.,]* TL`, 'İade Sebepleri Dağılımı' görünür |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Sayfa yüklenir | Rapora özgü 4 blok görünür, hata banner'ı yok |
| ER-2 | Sayaç formatı | `[0-9]+ Adet` deseni görünür |
| ER-3 | Ciro formatı | `[0-9][0-9.,]* TL` deseni görünür |

## Mobil Uyarlama Notları

- **Yüzey:** iOS Partner App (`com.getmobil.vendor`), Maestro ile koşulur. Web case'inin URL/`data-testid` adımları mobil karşılıklarıyla değiştirilmiştir.
- **Doğrulama ilkesi:** her adım hedef sayfaya ÖZGÜ öğelerle doğrulanır; öğe bulunamazsa test hata verir.
- **Erişilebilirlik:** bazı öğeler ikon glifli birleşik metin taşır (örn. "<ikon>, Bidbook, <ikon>") — desenler `.*` ile yazılır. Metinler `maestro hierarchy` çıktısından birebir alınmıştır.
- **Kanıt:** her ekran geçişinde `takeScreenshot`; koşum raporlarında galeri olarak sunulur.
