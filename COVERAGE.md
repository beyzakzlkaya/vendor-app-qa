# Test Kapsamı — getmobil-e2e-test-prompt-library → Mobil (partner-portal yüzeyi)

Kütüphanedeki 190 case'in **37'si** satıcı yüzeyini (`partner-portal`) hedefliyor — mobil
uygulamanın kapsamı bu. Diğer yüzeyler: backoffice (106), backend-api (71), web (20),
public-api (10) — bunlar web/API otomasyon hatlarına ait.

Durumlar: ✅ otomatik · 🔜 sırada (salt-okunur) · ✋ veri değiştiren (onayla koşulacak) · 🔌 API hattı · ❓ mobilde karşılığı araştırılacak

| Case | Başlık | Durum | Mobil flow |
|---|---|---|---|
| TC-IDENTITY-001 | Satıcı girişi | ✅ | tc-identity-001-giris.yaml |
| TC-IDENTITY-002 | Geçersiz giriş reddedilir | ✅ | tc-identity-002-gecersiz-giris.yaml |
| TC-ORDER-006 | Sipariş listesi + filtre | ✅ | tc-order-006-siparis-listesi.yaml |
| TC-ORDER-007 | Sipariş detayı içerikleri | ✅ | tc-order-007-siparis-detayi.yaml |
| TC-ORDER-011 | İade raporu | ✅ | tc-order-011-iade-raporu.yaml |
| TC-FIN-001 | Cüzdan bakiye + işlemler | ✅ | tc-fin-001-kasam.yaml |
| TC-INV-001 | Cihaz envanteri listesi | ✅ | tc-inv-001-cihazlarim.yaml |
| TC-INV-004 | Bidbook listesi | ✅ | tc-inv-004-bidbook.yaml |
| TC-INV-006 | Flash ürün listesi | ✅ | tc-inv-006-flas-urunler.yaml |
| TC-INV-008 | Fast buy fırsatları | ✅ | tc-inv-008-hizli-satis.yaml (uygulamadaki adı: Hızlı Satış) |
| TC-INV-009 | Katalog araması | 🔜 | ekran keşfi yapılacak |
| TC-REFURB-001 | Yeniletme siparişleri görünümü | 🔜 | "Yeniletip Gönder" akışı keşfedilecek |
| TC-BB-024 | Alım listesi başlangıç durumu | 🔜 | Mağaza modu ekran keşfi |
| TC-ORDER-008 | İade talebi oluşturma | 🔌 | müşteri+backoffice akışı — satıcı mobilinde karşılığı yok; web/API hattına |
| TC-INV-002 | Fiyat güncelleme | 🐞 | mut-inv-002-fiyat-guncelleme.yaml — **BUG-2026-001 / NE-13129**: 0 ₺ doğrulamasız kabul ediliyor (ER-5 ihlali); hata düzelene dek süit dışı, "Fiyat Değiştirme Hakkı" kotası nedeniyle manuel koşulur |
| TC-INV-003 | Toplu fiyat güncelleme | ✋ | veri değiştirir — onayla |
| TC-INV-005 | Bidbook teklif verme | ✋ | veri oluşturur — onayla |
| TC-INV-007 | Flash ürüne katılım | ✋ | veri oluşturur — onayla |
| TC-INV-011 | B2B katalog | ✅ | tc-inv-011-b2b-katalog.yaml (uygulamadaki adı: Tezgah) |
| TC-ORDER-001 | Checkout (müşteri) | 🔌 | API hattı — müşteri hesabı gerekli |
| TC-ORDER-010 | IMEI değişikliği | ✋ | backoffice adımı da var |
| TC-BB-005/007/008/025–049 | Buyback akışları (17 case) | ❓/✋ | çoğu veri değiştiren mağaza akışı |

## Çalışma şekli

1. Yeni case eklerken: `maestro hierarchy` ile hedef ekranın gerçek erişilebilirlik
   metinleri çekilir — tahmin edilmez.
2. Doğrulamalar sayfaya ÖZGÜ öğeler + DEĞER formatlarıyla yapılır
   (₺/TL tutarları, sipariş no desenleri, sayaçlar). Bulunamazsa test hata verir.
3. Veri değiştiren (✋) case'ler preprod'da koşulmadan önce Beyza'nın onayı alınır.
4. Kütüphane `git pull` ile güncellenir; yeni case'ler bu tabloya işlenir.
