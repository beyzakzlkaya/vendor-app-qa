---
id: TC-STORE-001 (öneri — kütüphane numaralandırması maintainer onayına tabi)
title: Mağaza modu panosu görüntüleme (mobil)
domain: store
sub_domain: store-dashboard
priority: medium
type: e2e
surface:
  - partner-app
tags:
  - store-mode
  - dashboard
  - mobile-only
precondition_refs:
  - (mobil: subflows/giris.yaml ile TC-IDENTITY-001 ön koşulu sağlanır)
test_data_refs:
  - FIXTURE-USER-VENDOR-001
automation_status: automated
automation_ref: "vendor-app-qa/.maestro/tc-store-001-magaza-panosu.yaml"
jira_ref: ""
last_updated: 2026-09-04
author: "Beyza Kızılkaya (QA otomasyonu — Claude ile)"
---

## Summary

Mobil uygulamaya özgü **Mağaza modu**nun (üst anahtar: Online ⇄ Mağaza) panosunun yüklendiğini doğrular: Bugünün Karı, Hızlı işlemler (Mağazadan sat / Tezgahtan al / Defterim / Servis), bekleyen sayaçları ve Satış Performansı. Kütüphanede birebir karşılığı olmayan, mobile özgü yeni bir case önerisidir.

---

## Steps

| # | Actor | Action | Expected Outcome |
|---|---|---|---|
| 1 | User | Ana sayfada üst anahtardan Mağaza moduna geç (point 61%,11%) | Mağaza panosu açılır |
| 2 | System | Pano yüklenir | '.*Bugünün Karı.*', 'Hızlı işlemler' görünür |
| 3 | User | Hızlı işlem kartlarını doğrula | Mağazadan sat / Tezgahtan al / Defterim / Servis |
| 4 | User | Sayaçları doğrula | `Tamirler, N Adet`, `Bekleyen Stok, N Adet`, `Vitrinde N cihaz`, 'Satış Performansı' |

---

## Expected Results

| # | Assertion | Pass Criteria |
|---|---|---|
| ER-1 | Pano yüklenir | Mağaza moduna özgü bölümler görünür, hata yok |
| ER-2 | Sayaç formatları | `[0-9]+ Adet` desenleri görünür |

## Bilinen Sınır

Derin mağaza ekranları (**Alım Listesi/BB-024**, **Servis/REFURB-001 adayı**) mağaza AKTİVASYONU gerektirir — FPPRO hesabı tanıtım aşamasında. Bu case'ler mağaza-yetkili test hesabıyla otomatikleştirilecek.
