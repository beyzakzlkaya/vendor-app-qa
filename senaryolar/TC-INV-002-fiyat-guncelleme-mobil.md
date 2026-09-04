---
id: TC-INV-002
title: Fiyat güncelleme + geçersiz değer reddi (mobil) — BUG-2026-001
domain: inventory
sub_domain: price-update
priority: critical
type: e2e
surface:
  - partner-app
tags:
  - price-update
  - validation
  - mutation
  - known-bug
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001 · iPhone 13 Pro SKU 9999010155028 (45.349 ₺)
automation_status: in-progress
automation_ref: "vendor-app-qa/.maestro/mut-inv-002-fiyat-guncelleme.yaml"
jira_ref: "NE-13129"
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Satış fiyatı düzenleyicisinin geçerli değeri kaydettiğini ve **0/negatif değeri reddettiğini** doğrular (ER-5).

> 🐞 **AÇIK HATA — NE-13129 (BUG-2026-001):** 21 Ağu 2026, v3.6.0 preprod'da uygulama 0 ₺'yi doğrulamasız kaydediyor; Buybox 0,00 ₺ oluyor ve ürün 0 ₺ ile 'BUYBOX KAZANAN' kalıyor. Düzenleyicinin varsayılan değeri de 0 — tek dokunuşla tetiklenebilir. Bu test, hata düzelene kadar KIRMIZI kalacak şekilde beklentiyi assert eder.

---

## Preconditions

- [ ] ⚠️ VERİ DEĞİŞTİREN test — varsayılan süit DIŞINDA (mut- öneki), manuel koşulur
- [ ] Her koşum 'Fiyat Değiştirme Hakkı' kotasından tüketir (21 Ağu itibarıyla kalan: 3)
- [ ] Koşum sonrası fiyat 45.349 ₺'ye geri yüklenir (temizlik)

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Cihazlar → Cihazlarım → Satış Fiyatı kalem ikonu | Düzenleme sayfası açılır ('Eski fiyat' görünür) |
| 2 | User | 0 gir, 'Güncelle'ye dokun | **Beklenen:** doğrulama hatası, kayıt engellenir |
| 3 | System | Doğrulama mesajı | `.*(geçerli|hatalı|geçersiz|büyük olmalı|sıfır).*` görünmeli — bilinen hatada GÖRÜNMÜYOR |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Düzenleyici erişilebilir | 'Eski fiyat' ve 'Güncelle' görünür |
| ER-2 | Geçersiz değer reddi | 0 için doğrulama hatası gösterilir, kayıt engellenir — **ŞU AN İHLAL (NE-13129)** |

## Mobil Uyarlama Notları

- **Yüzey:** iOS Partner App (`com.getmobil.vendor`), Maestro ile koşulur. Web case'inin URL/`data-testid` adımları mobil karşılıklarıyla değiştirilmiştir.
- **Doğrulama ilkesi:** her adım hedef sayfaya ÖZGÜ öğelerle doğrulanır; öğe bulunamazsa test hata verir.
- **Erişilebilirlik:** bazı öğeler ikon glifli birleşik metin taşır (örn. "<ikon>, Bidbook, <ikon>") — desenler `.*` ile yazılır. Metinler `maestro hierarchy` çıktısından birebir alınmıştır.
- **Kanıt:** her ekran geçişinde `takeScreenshot`; koşum raporlarında galeri olarak sunulur.
