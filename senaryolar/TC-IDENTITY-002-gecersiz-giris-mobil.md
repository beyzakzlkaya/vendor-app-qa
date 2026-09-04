---
id: TC-IDENTITY-002
title: Geçersiz kimlik bilgisiyle giriş reddedilir (mobil)
domain: identity
sub_domain: authentication
priority: high
type: e2e
surface:
  - partner-app
tags:
  - login
  - negative
  - validation
  - mobile
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001 (e-posta) + sabit yanlış şifre
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-identity-002-gecersiz-giris.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Yanlış şifreyle giriş denemesinin reddedildiğini, kullanıcıya anlamlı hata mesajı gösterildiğini ve formun etkileşimli kaldığını doğrular.

---

## Preconditions

- [ ] Uygulama temiz durumda, oturum yok

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Giriş Yap sekmesi → geçerli e-posta + 'YanlisSifre123!' gir | Form dolar |
| 2 | User | 'login_button'a dokun | Giriş isteği gönderilir |
| 3 | System | Hata mesajı gösterilir | 'Giriş bilgileri veya şifre yanlış girildi' (desen: .*(yanlış|hatalı).*) |
| 4 | User | Ekranı doğrula | Giriş formu hâlâ görünür ve etkileşimli |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Yönlendirme yok | Giriş ekranında kalınır (login_username_input görünür) |
| ER-2 | Hata mesajı | '.*(yanlış|hatalı).*' desenine uyan mesaj 15 sn içinde görünür |
| ER-3 | Form etkileşimli | login_button görünür ve dokunulabilir |

> **Uygulama gerçek metni:** "Giriş bilgileri veya şifre yanlış girildi" — kütüphanenin beklediği "E-posta veya şifre hatalı" metninin eşdeğeri kabul edilmiştir (ER-2 'or equivalent').

## Mobil Uyarlama Notları

- **Yüzey:** iOS Partner App (`com.getmobil.vendor`), Maestro ile koşulur. Web case'inin URL/`data-testid` adımları mobil karşılıklarıyla değiştirilmiştir.
- **Doğrulama ilkesi:** her adım hedef sayfaya ÖZGÜ öğelerle doğrulanır; öğe bulunamazsa test hata verir.
- **Erişilebilirlik:** bazı öğeler ikon glifli birleşik metin taşır (örn. "<ikon>, Bidbook, <ikon>") — desenler `.*` ile yazılır. Metinler `maestro hierarchy` çıktısından birebir alınmıştır.
- **Kanıt:** her ekran geçişinde `takeScreenshot`; koşum raporlarında galeri olarak sunulur.
