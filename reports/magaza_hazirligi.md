# Solenia (eski çalışma adı Kader): mağaza hazırlığı listesi

27 Kasım 2026, gece oturumu. Bu liste kodu değiştirmez; yalnız durumu ve sırayı verir.
Kaynak: depodaki dosyalar (yollar aşağıda), denetim `STUDIO/raw/denetim/2026-11-26/eatgrow_luckapp.md`.

## Şu anki durum (koddan okundu)

| Konu | Durum | Nerede |
|---|---|---|
| Paket adı | `com.turan.kader`, sürüm `1.0.0+1`. **Yayın öncesi açık:** yayından önce değişecek, yeni kimliği Turan seçer (`reports/magaza_metni_taslak.md`) | `android/app/build.gradle.kts:23`, `pubspec.yaml:5` |
| AdMob uygulama kimliği | Google'ın herkese açık test kimliği (`ca-app-pub-3940…`) | `android/gradle.properties:7`, `ios/Runner/Info.plist:49` |
| AdMob birimleri (ödüllü, geçiş, banner) | Test kimlikleri. Üretim kimlikleri `--dart-define` ile veriliyor, kod hazır | `lib/features/ads/ads_config.dart` |
| UMP (gizlilik onayı) | Kodda var; AdMob panelinde mesaj açılmadı | `lib/features/ads/reklam_servisi.dart` |
| Release imzası | **Debug imzası.** `key.properties` yok, upload keystore yok | `android/app/build.gradle.kts:42` |
| Yasal adresler | Yer tutucu: `[Geliştirici adı / şirket unvanı]`, `[destek@alanadiniz.com]`, `https://[alanadiniz.com]/gizlilik`, `…/kosullar`. `--dart-define` ile doldurulabilir | `lib/features/legal/legal_config.dart` |
| Yasal metin tarihi | `11 Kasım 2026`. Gizlilik metni yeni veriyi anlatıyor: tam ad, doğum tarihi, isteğe bağlı doğum saati ve ili. Tanışma soruları çıkarıldı | `lib/features/legal/legal_texts.dart` |
| Play ürünleri | Kodda tanımlı, panelde açılmadı: `kader_premium_aylik`, `kader_premium_yillik` (abonelik), `kader_rapor_tam`, `kader_yil_2027` (tek seferlik) | `lib/features/premium/premium_config.dart` |
| Uygulama adı (K4) | **Kapandı (26 Kas):** Solenia, iki dilde. Launcher, uygulama içi metinler ve yasal metin güncellendi. Başlık taslağı: `reports/magaza_metni_taslak.md` | `INGILIZCE_SURUM_PLANI.md` §5 |
| Hukuk | Açık. 677 sayılı Kanun riski; "eğlence / kendini keşif" konumu, "fal" değil | `INGILIZCE_SURUM_PLANI.md` §1 |
| iOS açılış ekranı | Flutter'ın varsayılan `LaunchScreen.storyboard` dosyası | `ios/Runner/Base.lproj/` |

## Sıralı iş listesi

Sıra bağımlılığa göre. Hukuk görüşünün sonucu metinleri ve mağaza açıklamasını değiştirebilir. Bu yüzden ilk sırada; cevabı en uzun süren iş de bu.

| # | İş | Kim | Neye bağlı | Not |
|---|---|---|---|---|
| 1 | **Hukukçu görüşmesi** (677 sayılı Kanun, KVKK aydınlatma metni, sorumluluk reddi) | Turan | — | Sorulacaklar bu listenin altında. Görüş gelmeden satışa açılmaz. |
| 2 | Hukukçu notlarına göre Türkçe yasal metinleri ve uyarıyı güncellemek | Claude | 1 | `legal_texts.dart`. Uyarı metni değişirse `LegalConfig.uyariSurumu` artırılır; böylece herkes yeniden onaylar. |
| 3 | Alan adı, gizlilik ve koşullar sayfalarının yayını; destek e-postası | Turan | 2 (metin) | Claude sayfa metnini `legal_texts.dart`'tan HTML'e çevirebilir (ayrı iş). |
| 4 | Yasal adresleri derlemeye vermek | Claude (komut), Turan (değerler) | 3 | Kod değişikliği gerekmez: `--dart-define=KADER_GELISTIRICI=… KADER_DESTEK_EPOSTA=… KADER_GIZLILIK_URL=… KADER_KOSULLAR_URL=…`. İstenirse bir `build_release.sh` yazılır. |
| 5 | Upload keystore oluşturup yedeklemek; `android/key.properties` yazmak | Turan | — | Şifreler sohbete yazılmaz. Keystore iki yerde yedeklenir. |
| 6 | `build.gradle.kts`'e release `signingConfig` eklemek (`key.properties` okur, yoksa debug'a düşer) | Claude | 5 | Küçük kod işi; ayrı commit. |
| 7 | AdMob: uygulama, 3 reklam birimi (ödüllü, geçiş, banner), UMP mesajı (GDPR + gerekirse ABD eyaletleri) | Turan | — | iOS da çıkacaksa aynı birimler iOS için de açılır. |
| 8 | AdMob uygulama kimliğini `gradle.properties` dosyasına, birim kimliklerini derleme komutuna eklemek | Claude | 7 | Kimlikler önekleriyle kontrol edilir. Rapora tamamı yazılmaz. |
| 9 | Play Console: uygulama kaydı, 2 abonelik + 2 tek seferlik ürün (kimlikler yukarıda) | Turan | 1 (fiyat ve açıklama dili) | `kader_yil_2027` yıl değişince yenisi açılır (`satistakiYil`). |
| 10 | Data safety formu ve içerik derecelendirmesi | Turan (gönderir), Claude (taslak cevaplar) | 2, 7 | Toplanan veri: ad, doğum tarihi, isteğe bağlı doğum saati ve il; hepsi cihazda. Reklam kimliği AdMob üzerinden. |
| 11 | Türkçe mağaza metni ve ekran görüntüsü listesi | Claude (metin), Turan (görüntüler, emülatör) | 1 (konum dili) | "Fal" kelimesi kullanılmaz; "eğlence ve kendini keşif". |
| 12 | Release AAB, kapalı test kanalı, telefonda tur | Turan | 4, 6, 8, 9 | |
| 13 | ~~K4: İngilizce ad~~ **Kapandı:** Solenia (26 Kas) | — | — | Kalan: paket kimliği ve Play ürün kimlikleri (`kader_*`) panelde açılmadan önce karara bağlanmalı. |
| 14 | iOS: açılış ekranı, App Store Connect, iOS AdMob kimlikleri | Turan + Claude | 7 | Yalnız iOS da çıkacaksa. Önce Android. |

Kısa yol: Türkçe Android yayını için gereken en az iş 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ve 12'dir. 11 aynı anda yürür. 13 ve 14 Türkçe yayını bekletmez.

## Hukukçuya sorulacaklar (Turan için not)

1. **677 sayılı Kanun:** Uygulama, falcılığı yasaklayan Tekke ve Zaviyelerle Türbelerin Seddine ve Türbedarlıklar ile Birtakım Unvanların Men ve İlgasına Dair Kanun kapsamına girer mi? Konumlandırma "eğlence ve kendini keşif" (numeroloji, burç, Ay). "Fal", "kehanet", "gelecek görme" kelimeleri kullanılmıyor. Bu konum yeterli mi? Mağaza metninde ve uygulama içinde kaçınılması gereken başka ifadeler var mı?
2. **Ücretli içerik:** Abonelik ve tek seferlik "numeroloji raporu", "kişisel yıl raporu" satışının ayrıca bir riski var mı? "Eğlence amaçlıdır" uyarısı ödeme ekranında yeterli mi?
3. **KVKK:** Veriler (tam ad, doğum tarihi, doğum saati ve ili) yalnız cihazda saklanıyor, sunucu yok. AdMob reklam kimliği işliyor. Aydınlatma metni (`legal_texts.dart`) yeterli mi? Açık rıza gerekiyor mu? VERBİS kaydı gerekiyor mu?
4. **Tüketici mevzuatı:** Abonelikte cayma hakkı ve iptal bilgisi nasıl verilmeli? Mağaza faturalaması bunu karşılıyor mu?
5. **Geliştirici unvanı:** Uygulama şahıs adına mı, şirket adına mı yayımlanmalı? Bu karar `KADER_GELISTIRICI` değerini belirliyor.
6. **İngilizce sürüm (K5):** İngilizce gizlilik metni ve koşulların taslağını Claude yazacak (E9). Hukukçu bunu onaylayacak mı, yoksa ayrı biri mi gerekiyor?
