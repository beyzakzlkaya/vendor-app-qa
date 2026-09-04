---
id: TC-FIN-001
title: Satıcı cüzdan bakiyesini ve işlem geçmişini görüntüler (mobil)
domain: financials
sub_domain: wallet
priority: high
type: e2e
surface:
  - partner-app
tags:
  - wallet
  - financials
  - value-check
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-fin-001-kasam.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Kasam (cüzdan) sayfasında bakiyenin TRY formatında gösterildiğini, hızlı işlemlerin ve işlem geçmişinin (Son İşlemler) yüklendiğini doğrular. Mobilde 'Kasam' alt menüden doğrudan açılır (hub değildir).

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Alt menü 'Kasam'a dokun | Cüzdan sayfası açılır |
| 2 | System | Bakiye yüklenir | 'Toplam Bakiye', 'Vadesi Gelmiş', 'Hızlı İşlemler' görünür |
| 3 | User | Değerleri doğrula | Bakiye `-?[0-9][0-9.,]* ₺` (negatif olabilir), 'Kullanılabilir', '.*Para Yükle.*', '.*Para Çek.*' |
| 4 | User | 'Son İşlemler'e kadar kaydır | İşlem geçmişi bölümü görünür |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Cüzdan sayfası | 'Toplam Bakiye' görünür (sayfaya özgü) |
| ER-2 | Bakiye formatı | `-?[0-9][0-9.,]* ₺` desenine uyan değer görünür |
| ER-3 | İşlem geçmişi | 'Son İşlemler' bölümü kaydırmayla erişilebilir |

## Mobil Uyarlama Notları

- **Yüzey:** iOS Partner App (`com.getmobil.vendor`), Maestro ile koşulur. Web case'inin URL/`data-testid` adımları mobil karşılıklarıyla değiştirilmiştir.
- **Doğrulama ilkesi:** her adım hedef sayfaya ÖZGÜ öğelerle doğrulanır; öğe bulunamazsa test hata verir.
- **Erişilebilirlik:** bazı öğeler ikon glifli birleşik metin taşır (örn. "<ikon>, Bidbook, <ikon>") — desenler `.*` ile yazılır. Metinler `maestro hierarchy` çıktısından birebir alınmıştır.
- **Kanıt:** her ekran geçişinde `takeScreenshot`; koşum raporlarında galeri olarak sunulur.
