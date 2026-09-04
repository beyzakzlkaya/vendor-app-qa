---
id: TC-INV-004
title: Bidbook listesi (mobil)
domain: inventory
sub_domain: bidbook
priority: high
type: e2e
surface:
  - partner-app
tags:
  - bidbook
  - opportunities
  - value-check
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-inv-004-bidbook.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Bidbook bölümünün açıldığını; günlük alım limiti, model listesi, web fiyatları ve grade bazlı fiyat detayının doğru gösterildiğini doğrular. **Mobil giriş noktası:** sol üst hamburger çekmecesi → 'Bidbook'.

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Ana sayfada çekmeceyi aç (hamburger, point 10%,11%) | Modül çekmecesi açılır |
| 2 | User | 'Bidbook, .*' öğesine dokun | Bidbook sayfası açılır |
| 3 | System | Sayfa yüklenir | 'Günlük Alım Limitin', 'Kalan', 'Bidbook Teklif' sekmesi görünür |
| 4 | User | Değerleri doğrula | Limit `₺[0-9][0-9.,]*`, model '(Apple|Samsung).*', 'Web Fiyatı ₺[0-9.,]*', 'Grade Bazlı Verdiğin Fiyatlar' |
| 5 | User | 'Detayları Gör.*' ile detayı genişlet | Detay hatasız açılır |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Sayfa yüklenir | 'Günlük Alım Limitin' görünür (sayfaya özgü) |
| ER-2 | Model listesi dolu | en az bir '(Apple|Samsung).*' satırı |
| ER-3 | Değer formatları | limit ve web fiyatı ₺ desenlerine uyar |
| ER-4 | Detay açılır | 'Bir hata oluştu' görünmez |

## Mobil Uyarlama Notları

- **Yüzey:** iOS Partner App (`com.getmobil.vendor`), Maestro ile koşulur. Web case'inin URL/`data-testid` adımları mobil karşılıklarıyla değiştirilmiştir.
- **Doğrulama ilkesi:** her adım hedef sayfaya ÖZGÜ öğelerle doğrulanır; öğe bulunamazsa test hata verir.
- **Erişilebilirlik:** bazı öğeler ikon glifli birleşik metin taşır (örn. "<ikon>, Bidbook, <ikon>") — desenler `.*` ile yazılır. Metinler `maestro hierarchy` çıktısından birebir alınmıştır.
- **Kanıt:** her ekran geçişinde `takeScreenshot`; koşum raporlarında galeri olarak sunulur.
