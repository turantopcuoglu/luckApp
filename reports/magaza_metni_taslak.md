# Solenia: mağaza metni taslağı

Durum: **taslak.** Hukukçu görüşü gelmeden (bkz. `reports/magaza_hazirligi.md` madde 1) açıklama metni yazılmaz; burada yalnız ad ve başlık var.

Karar: uygulamanın adı **Solenia** (26 Kasım 2026, `STUDIO/KARARLAR.md`, commit `d024d2e`). Turan bilinen kusurları kabul etti: App Store'da aynı adlı İsveç uygulaması var, @solenia kullanıcı adları dolu, ilaç ve takviye adlarına benzerlik var. Kaynak: `STUDIO/raw/denetim/2026-11-26/luckapp_ulvi_adlar.md` §4.

## Uygulama adı ve başlık

| Alan | Türkçe | İngilizce | Sınır |
|---|---|---|---|
| Ana ekran adı (launcher) | Solenia | Solenia | iOS ~12 karakter görünür |
| Mağaza başlığı (önerilen) | Solenia: Doğum Haritası ve Ay (29) | Solenia: Birth Chart & Moon (27) | Play 30, App Store 30 |
| Alternatif | — ("Solenia: Astroloji ve Numeroloji" 32 karakter, sığmıyor) | Solenia: Astrology & Numbers (28) | |

Karakterler Python `len()` ile sayıldı.

Dil notu: "Fal" kelimesi kullanılmaz; konum "eğlence ve kendini keşif" (677 sayılı Kanun, hukukçuya soruluyor).

## Yayın öncesi açıklar (ad değişikliğinden kalan)

1. **Paket kimliği `com.turan.kader`.** Yayından önce değişecek; yeni kimliği Turan seçer. Play'de ilk yüklemeden sonra kimlik hiç değişmez. Yerleri: `android/app/build.gradle.kts:9` (`namespace`) ve `:23` (`applicationId`), iOS `PRODUCT_BUNDLE_IDENTIFIER` (`ios/Runner.xcodeproj`). Kotlin `MainActivity` paket yolu da namespace'e bağlı.
2. **Play ürün kimlikleri `kader_*`** (`lib/features/premium/premium_config.dart`). Kullanıcı görmez. Play Console'da açıldıktan sonra yeniden adlandırılamaz. Panelde açmadan önce `solenia_*` mi olacak, karar gerekli.
3. **Derleme değişkenleri `KADER_*`** (`legal_config.dart`) ve Dart paket adı `kader`: yalnız kod içi, kullanıcı görmez. Bilerek değiştirilmedi.
4. Alan adı (solenia.app / soleniaapp.com) ve TÜRKPATENT kontrolü: Turan.
