---
id: TC-INV-011
title: B2B katalog görüntüleme (mobil — Tezgah)
domain: inventory
sub_domain: b2b-catalog
priority: medium
type: e2e
surface:
  - partner-app
tags:
  - b2b
  - catalog
  - marketplace
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-inv-011-b2b-katalog.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

B2B erişimli satıcının B2B kataloğu görüntüleyebildiğini ve filtre kontrollerinin sunulduğunu doğrular. **Mobilde bu özelliğin adı "Tezgah"tır** (çekmece → Tezgah): bayiler arası pazaryeri.

---

## Preconditions

- [ ] Giriş yapılmış (TC-IDENTITY-001 alt akışı)
- [ ] Satıcının B2B/Tezgah erişimi var

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Çekmeceyi aç (hamburger, point 10%,11%) → 'Tezgah'a dokun | Tezgah sayfası açılır |
| 2 | System | Sekme seti yüklenir | 'Bayi Cihazları', 'Getmobil Cihazları', 'Aksesuarlar', 'Cihaz Sat', 'Ürünlerim', 'Aldıklarım' |
| 3 | User | Filtre kontrollerini doğrula | 'Marka', 'Şehir', 'Kozmetik Durum' ve 'Liste filtrele' görünür |
| 4 | User | 'Getmobil Cihazları' sekmesine geç | İçerik hatasız yüklenir |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Tezgah açılır | 'Bayi Cihazları' sekmesi görünür (sayfaya özgü) |
| ER-2 | Filtreler sunulur | Marka / Şehir / Kozmetik Durum görünür |
| ER-3 | Sekme geçişi çalışır | 'Bir hata oluştu' görünmez (boş durum kabul) |

## Mobil Uyarlama Notları

- Kütüphane case'i web B2B kataloğu tarifler; mobil karşılığı Tezgah pazaryeridir. Satır içi fiyat/stok doğrulamaları, listede kart verisi keşfi sonrası derinleştirilecek (v2).
