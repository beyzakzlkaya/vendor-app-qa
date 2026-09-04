---
id: TC-IDENTITY-001
title: Satıcı girişi — mutlu yol (mobil)
domain: identity
sub_domain: authentication
priority: critical
type: e2e
surface:
  - partner-app
tags:
  - login
  - authentication
  - happy-path
  - vendor
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001 (mobil: .env TEST_EMAIL/TEST_PASSWORD)
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-identity-001-giris.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Aktif bir satıcının iOS Partner App'te geçerli kimlik bilgileriyle giriş yapabildiğini ve ana sayfanın (dashboard) doğru yüklendiğini doğrular. Tüm satıcı akışlarının ön koşuludur.

---

## Preconditions

- [ ] Satıcı hesabı preprod'da aktif
- [ ] Uygulama temiz durumda başlatılır (clearState) — oturum yok
- [ ] İzinler otomatik verilir (permissions: all allow)

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Uygulamayı temiz durumla başlat | Karşılama ekranı 'Kayıt Ol' sekmesiyle açılır |
| 2 | User | 'Giriş Yap' sekmesine dokun | Giriş formu görünür (login_username_input / login_password_input) |
| 3 | User | E-posta ve şifreyi gir (.env) | Alanlar dolar; klavye kapatılır |
| 4 | System | iOS 'Save Password?' diyaloğu çıkabilir | İki katmanlı savunma: koşullu 'Not Now' + kör nokta dokunuşu (32%,62%) |
| 5 | User | 'login_button'a dokun | Giriş isteği gönderilir |
| 6 | System | Karşılama balonu ('Anladım') çıkabilir | Koşullu kapatılır |
| 7 | System | Ana sayfa yüklenir | 'Anasayfa' sekmesi görünür (20 sn içinde) |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Giriş formu erişilebilir | login_username_input ve login_password_input görünür |
| ER-2 | Giriş başarılı | Ana sayfa 20 sn içinde yüklenir, 'Anasayfa' görünür |
| ER-3 | Sistem diyalogları akışı bozmaz | Save Password ve Anladım koşullu kapatılır |

## Mobil Uyarlama Notları

- **Yüzey:** iOS Partner App (`com.getmobil.vendor`), Maestro ile koşulur. Web case'inin URL/`data-testid` adımları mobil karşılıklarıyla değiştirilmiştir.
- **Doğrulama ilkesi:** her adım hedef sayfaya ÖZGÜ öğelerle doğrulanır; öğe bulunamazsa test hata verir.
- **Erişilebilirlik:** bazı öğeler ikon glifli birleşik metin taşır (örn. "<ikon>, Bidbook, <ikon>") — desenler `.*` ile yazılır. Metinler `maestro hierarchy` çıktısından birebir alınmıştır.
- **Kanıt:** her ekran geçişinde `takeScreenshot`; koşum raporlarında galeri olarak sunulur.
