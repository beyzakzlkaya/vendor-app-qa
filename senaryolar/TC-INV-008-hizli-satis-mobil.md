---
id: TC-INV-008
title: Hızlı Satış fırsatları (mobil)
domain: inventory
sub_domain: fast-buy
priority: medium
type: e2e
surface:
  - partner-app
tags:
  - fast-buy
  - opportunities
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-inv-008-hizli-satis.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Hızlı Satış fırsatlar sayfasının açıldığını, sayaçlı sekmelerin ('Hızlı Satış Cihazların' / 'Envanterinden Öneriler') geldiğini ve sekme geçişinin hatasız çalıştığını doğrular. Kütüphanedeki 'Fast Buy' özelliğinin uygulamadaki adı **Hızlı Satış**'tır.

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Çekmece → 'Fırsatlar, .*' → 'Hızlı Satış, .*' | Hızlı Satış sayfası açılır |
| 2 | System | Sekmeler yüklenir | 'Hızlı Satış Cihazların, N Adet' ve 'Envanterinden Öneriler, N Adet' |
| 3 | User | Sayaç formatını doğrula | `.*[0-9]+ Adet.*` deseni görünür |
| 4 | User | 'Envanterinden Öneriler.*' sekmesine geç | İçerik hatasız yüklenir |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Sekmeler görünür | iki sekme de sayaçlarıyla görünür |
| ER-2 | Sayaç formatı | `[0-9]+ Adet` desenine uyar |
| ER-3 | Sekme geçişi | 'Bir hata oluştu' görünmez (boş durum kabul — ER-5) |

## Mobil Uyarlama Notları

- **Yüzey:** iOS Partner App (`com.getmobil.vendor`), Maestro ile koşulur. Web case'inin URL/`data-testid` adımları mobil karşılıklarıyla değiştirilmiştir.
- **Doğrulama ilkesi:** her adım hedef sayfaya ÖZGÜ öğelerle doğrulanır; öğe bulunamazsa test hata verir.
- **Erişilebilirlik:** bazı öğeler ikon glifli birleşik metin taşır (örn. "<ikon>, Bidbook, <ikon>") — desenler `.*` ile yazılır. Metinler `maestro hierarchy` çıktısından birebir alınmıştır.
- **Kanıt:** her ekran geçişinde `takeScreenshot`; koşum raporlarında galeri olarak sunulur.
