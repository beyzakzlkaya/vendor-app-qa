---
id: TC-INV-005
title: Bidbook teklif gönderme (mobil)
domain: inventory
sub_domain: bidbook
priority: high
type: e2e
surface:
  - partner-app
tags:
  - bidbook
  - offer
  - mutation
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001 (mevcut Bidbook teklifi olan model gerekli)
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/mut-inv-005-bidbook-teklif.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Satıcının Bidbook'ta bir model için teklif gönderebildiğini doğrular. **Güvenli mutasyon stratejisi:** editör mevcut teklif değerleriyle dolu gelir; değerler değiştirilmeden "Teklifi Gönder"e basılır — aynı teklif yeniden gönderilir, veri fiilen değişmez ama gönderim akışı uçtan uca doğrulanır.

> ⚠️ VERİ DEĞİŞTİREN test (mut- öneki) — varsayılan süit dışında, onayla/manuel koşulur.

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Çekmece → Bidbook → 'Teklifi Düzenle' | Teklif editörü açılır |
| 2 | User | Editör içeriğini doğrula | Model başlığı, 'Web Fiyatı' + `₺N` değeri (AYRI öğeler), `[A-Z] Grade` kartları, `Atanabilir Stok N`, 'Verilen Fiyat'/'İstenilen Stok' alanları, `N Kazanan` sayacı |
| 3 | User | Değer DEĞİŞTİRMEDEN 'Teklifi Gönder'e dokun | Gönderim başarılı (onay diyaloğu yok — varyantlar koşullu ele alınır) |
| 4 | System | Bidbook listesine dönülür | 'Günlük Alım Limitin' görünür, hata yok, 'Teklifi Düzenle' hâlâ mevcut (teklif korunuyor) |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Editör erişilebilir | 'Teklifi Gönder' görünür |
| ER-2 | Gönderim başarılı | Hata banner'ı yok, listeye dönülür |
| ER-3 | Teklif kayıtlı | 'Teklifi Düzenle' görünür (teklif varlığı sürer) |

## Mobil Uyarlama Notları

- **Ekran-bazlı metin farkı dersi:** listede "Web Fiyatı ₺90.000" TEK öğe; editörde 'Web Fiyatı' ve '₺90.000' AYRI öğeler — her hedef ekran için hiyerarşi ayrı dökülmeli.
