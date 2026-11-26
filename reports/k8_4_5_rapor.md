# K8-4 ve K8-5: doğum yeri, profil ve arayüz (27 Kasım gecesi)

Karar: `STUDIO/KARARLAR.md`, 2026-11-27. Turan: "LuckApp: önerdiğin gibi olsun." Dal `gece/2026-11-27`.

## Ne bitti

**K8-4: kayıt ve profil (commit `10ac847`)**

- `DogumYeri` (`luck_engine`): ülke kodu, şehir adı, IANA kimliği, koordinat, GeoNames kimliği ya da il plakası.
- Profilde yeni alan `yabanciDogumYeri`. Yeni Hive anahtarları: `dogumUlkeKodu`, `dogumSehirAdi`, `dogumSehirKimligi`, `dogumSaatDilimi`, `dogumEnlem`, `dogumBoylam`.
- **Göç okurken yapılır.** Eski kayıttaki `dogumIliPlaka` Türkiye + il + `Europe/Istanbul` olarak okunur. Diske yazma gerekmiyor, eski anahtar yerinde kalıyor.
- Doğum haritası farkı K8-2 çözücüsünden alıyor. Yer seçilmediyse Türkiye kuralı kullanılıyor; bu, eski davranışın aynısı.
- **Türkiye haritaları değişmedi.** 81 il × 6 tarih × 4 saat = 1 944 durumda yeni hesap eski hesapla birebir aynı. Altın tablo da aynı.
- **Cihaz saat dilimi hatası kapandı.** Doğum anı artık `DateTime.utc` ile taşınıyor. Eskiden cihazın kendi diliminde atlanan bir saat (ör. cihaz İstanbul'dayken 28 Mart 2010 03:30) bir saat ileri kayıyordu.
- **Yükselen güvenilirlik notu nedene göre seçiliyor.** Üç metin var: Türkiye kaydı (eski metin), yurt dışında 1970 öncesi (yeni) ve geçiş gecesi (yeni).

**K8-5: veri ve arama katmanı (arayüz yok)**

- `DunyaSehri` ve `DunyaSehirleri` (`luck_engine`, saf Dart):
  - GeoNames `cities15000` satırını okur; Türkiye satırlarını almaz.
  - Kompakt asset biçimini yazar ve okur (8 sütun, koordinat 4 hane).
  - Ülke içinde arar: aksan ve büyük/küçük harf gözetmez, ASCII adı da bulur. Adı sorguyla başlayanlar önce gelir, her grupta kalabalık şehir önce.
- `Numeroloji.latinSadelestir`: aramada numeroloji ile aynı harf tablosu kullanılıyor ("München" → "munchen", "Łódź" → "lodz").

## Ölçütler

| # | Ölçüt | Durum | Kanıt |
|---|---|---|---|
| 1 | Eski kayıt (plaka) Türkiye ili olarak okunur, yazma yok | KARŞILANDI | `test/storage/dogum_yeri_gocu_test.dart` |
| 2 | Yabancı yer Hive'a yazılıp geri okunur, plaka yazılmaz | KARŞILANDI | aynı test |
| 3 | Türkiye haritaları ve altın tablo değişmez | KARŞILANDI | 1 944 durum birebir; altın tablo İstanbul ve UTC'de geçti |
| 4 | Yabancı doğumda Yükselen şehrin koordinatı ve IANA farkıyla hesaplanır | KARŞILANDI | Berlin testi; K8-2'de 4 AA kaydı |
| 5 | Cihaz diliminde atlanan saat kaymaz | KARŞILANDI | test İstanbul, UTC ve New York makine saatinde geçti |
| 6 | Şehir verisi biçimi ve araması saf Dart, testli | KARŞILANDI | `test/luck_engine/dunya_sehirleri_test.dart` |
| 7 | Ülke seçici + şehir araması (tanışma ve profil) | KARŞILANMADI | Şehir verisi yok, hedef kare yok (sorular 1–3) |
| 8 | "Türkiye dışında doğduysan boş bırak" metni kalkar | KARŞILANMADI | Arayüzle birlikte; yabancı şehir seçilemeden kalkarsa yanlış olur |
| 9 | GeoNames atfı (Hakkında + lisans sayfası) | KARŞILANMADI | Veriyle birlikte |
| 10 | `flutter analyze` 0, testler yeşil | KARŞILANDI | Sayılar commit mesajlarında |
| 11 | Cihazda deneme | DOĞRULAMADIM | Emülatör testi Turan'da |

Görsel değişiklik yok, ekran görüntüsü alınmadı. Kullanıcının göreceği tek fark harita okumasındaki not metni; o da yalnız geçiş saatinde doğanlarda (madde 6).

## Turan'a sorular (iş burada duruyor)

1. **Ham dosyaları kim indirecek?** Bu gece dosya indirmek yasaktı. Gereken üç dosya:
   - `cities15000.zip` (geonames.org/export/dump)
   - `countryInfo.txt` (aynı yer)
   - Türkçe ülke adları: Unicode CLDR, `cldr-json` deposundaki `cldr-localenames-full/main/tr/territories.json` ve `.../main/en/territories.json`

   Senin indirmen ya da bir sonraki oturumda benim indirmeme izin vermen yeterli.
2. **İki klasör için onay** (`CLAUDE.md`: klasör yapısı sorulmadan değişmez):
   - **`tool/`:** kırpma betiği (`dart run tool/sehir_verisi.dart`) burada durur.
   - **`assets/veri/`:** şehir ve ülke dosyası (~1 MB), `pubspec.yaml`'a bir `assets:` satırı.

   Soru 2'deki onayı asset için yeterli saydım; yalnız klasör adını soruyorum.
3. **Arayüz için hedef kare.** Onaylı plan "ülke seçici + şehir araması" diyor. Kurala göre önce hedef kare çizilip onaylanmalı. Veri gelince, gerçek şehirlerle iki seçenek çizerim:
   - (a) ayrı ülke alanı + şehir alanı;
   - (b) tek "Doğduğun yer" arama alanı, sonuç satırında "Berlin · Almanya".

   Karar sende.
4. **Yeni not metinleri** (`harita_metinleri.dart`), uygun mu?
   - **Geçiş gecesi:** "Doğduğun saat, saatlerin ileri ya da geri alındığı geceye denk geliyor; bu saatin hangi saat dilimine göre yazıldığı kesin değil. Yükselenin bir burç kayabilir. Yorumu bir eğilim olarak oku."
   - **Yurt dışı 1970 öncesi:** "Doğduğun tarihte o bölgede uygulanan saate dair kayıtlar kesin değil; Yükselenin bir burç kayabilir. Yorumu bir eğilim olarak oku."

## Bilinmesi gerekenler

5. **Eski sürüme dönüş.** Eski sürüm yeni kaydı okur, ama profili kaydederken yabancı yer alanlarını düşürür. Türkiye ili (plaka) korunur. Yalnız yabancı şehir seçmiş biri eski sürüme dönerse yerini yeniden seçer.
6. **Türkiye'de tek davranış farkı.** Saatlerin ileri ya da geri alındığı gece, atlanan ya da iki kez yaşanan saatte doğanlarda Yükselen'in altına geçiş notu düşüyor. Bu, K8-2 kuralının sonucu. Harita ve skor aynı.
7. **`latest` → `latest_all`.** Plan bildirimlerin de `latest_all`'a geçmesini söylüyor. Bu adımı veri gelince yapacağım: betik GeoNames'teki her saat dilimi kimliğinin `latest`'te olup olmadığını sayacak. Hepsi varsa geçişe gerek yok, uygulama küçük kalır. İki taraf aynı anda geçmeli: veri ilk kim yüklerse onunki kullanılıyor.
8. **Türkçe şehir adları** ("Münih", "Viyana") için elle yazılmış eş anlamlı listesi plandaydı. Veriyle birlikte yazılacak.
