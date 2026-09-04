---
id: TC-ORDER-006
title: Satıcı sipariş listesini görüntüler ve filtreler (mobil)
domain: order
sub_domain: order-list
priority: high
type: e2e
surface:
  - partner-app
tags:
  - order-list
  - filtering
  - vendor
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-order-006-siparis-listesi.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Satıcının sipariş listesine ulaşabildiğini, durum filtresi uygulayabildiğini ve bir siparişin detayına inebildiğini doğrular. **Mobil yapı web'den farklıdır:** alt menü 'Siparişler' bir HUB açar; gerçek liste hub'daki 'Siparişler' kartındadır.

---

## Preconditions

- [ ] Giriş yapılmış (TC-IDENTITY-001 alt akışı)
- [ ] Satıcının en az 1 siparişi var

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Alt menü 'Siparişler'e dokun | HUB açılır: Siparişler / Mağazada Sattıklarım / İade Yönetimi / İade Raporu / Fatura Yönetimi |
| 2 | User | Hub'daki 'Siparişler' kartına dokun (desen: '.*, Siparişler, .*') | Gerçek sipariş listesi açılır |
| 3 | System | Liste yüklenir | 'Sırala', 'Filtrele' butonları ve durum sekmeleri ('Yeni Sipariş', 'Kargoda', 'İptal Edildi') görünür |
| 4 | User | 'Kargoda' durum sekmesine dokun | Filtre uygulanır, liste hatasız yenilenir |
| 5 | User | 'Yeni Sipariş' sekmesine dön, ilk siparişte 'Detayı Gör'e dokun | Detay sayfası açılır |
| 6 | System | 'Devredilen Sipariş' modalı çıkabilir (gecikmeli) | İki turlu koşullu 'Anladım' kapatması |
| 7 | User | Detayı doğrula | 'Detay' başlığı ve 'Satış Kanalı' görünür |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Hub doğru | 'Mağazada Sattıklarım' ve 'İade Yönetimi' görünür (hub'a özgü) |
| ER-2 | Liste doğru sayfa | '.*Filtrele' ve '.*Sırala' görünür (listeye özgü) |
| ER-3 | Durum filtresi çalışır | 'Kargoda' seçimi sonrası liste hatasız |
| ER-4 | Detay açılır | 'Detay' + 'Satış Kanalı' görünür |
| ER-5 | Hata yok | 'Bir hata oluştu' görünmez |

## Mobil Uyarlama Notları

- **Yüzey:** iOS Partner App (`com.getmobil.vendor`), Maestro ile koşulur. Web case'inin URL/`data-testid` adımları mobil karşılıklarıyla değiştirilmiştir.
- **Doğrulama ilkesi:** her adım hedef sayfaya ÖZGÜ öğelerle doğrulanır; öğe bulunamazsa test hata verir.
- **Erişilebilirlik:** bazı öğeler ikon glifli birleşik metin taşır (örn. "<ikon>, Bidbook, <ikon>") — desenler `.*` ile yazılır. Metinler `maestro hierarchy` çıktısından birebir alınmıştır.
- **Kanıt:** her ekran geçişinde `takeScreenshot`; koşum raporlarında galeri olarak sunulur.
