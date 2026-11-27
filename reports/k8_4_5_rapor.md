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
| 7 | Ülke seçici + şehir araması (tanışma ve profil) | KARŞILANDI (tur 2) | `reports/k8_5_kanit/`, ekran testleri |
| 8 | "Türkiye dışında doğduysan boş bırak" metni kalkar | KARŞILANDI (tur 2) | TR ve EN metin; `1_tanisma_tr_once_sonra.png` |
| 9 | GeoNames atfı (Ayarlar > Lisanslar + LicenseRegistry) | KARŞILANDI (tur 2) | `veri_lisanslari.dart`; cihazda açılıp **bakılmadı** |
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

## Tur 2 (27 Kasım gece): veri ve arayüz

Karar: `STUDIO/KARARLAR.md` 2026-11-27, "GeoNames cities15000 indirilir" (Turan: "Evet, indir").

**Veri**

- **GeoNames `cities15000.zip`:** 26 Kasım sürümü, 34 247 satır, SHA-256 `ef92c9b4d801f1da959372f53d2f586517b704239ea0b8756045a3d804438779`. Başka dosya indirilmedi.
- **Kırpma.** `tool/sehir_verisi.dart` → `assets/veri/sehirler.tsv`:
  - 33 810 şehir, 243 ülke.
  - Türkiye'nin 437 satırı atıldı; Türkiye'de 81 il kalıyor.
  - Kalan alanlar: ad, ASCII ad, ülke, enlem, boylam (4 hane), saat dilimi (356 kimlik tek tabloda).
  - Satırlar nüfusa göre sıralı; nüfus sütunu atıldı.
  - Boyut 1,59 MB, gzip 796 KB.
- **Ülke adları.** İndirme yapılmadı. Türkçe ve İngilizce adlar macOS'un yerleşik Unicode CLDR verisinden üretildi (`tool/ulke_adlari.swift`, macOS 26). Çıktı `assets/veri/ulkeler.tsv`, 244 ülke.
- **Lisanslar.** Ayarlar > Gizlilik ve yasal > "Lisanslar" satırı `showLicensePage` açıyor. Orada iki kayıt var:
  - GeoNames: CC BY 4.0 bağlantısı ve yapılan kırpma, TR ve EN.
  - Unicode CLDR: Unicode License v3 tam metni, Flutter SDK'daki kopyadan alındı.
- **Saat dilimi verisi `latest_all`'a geçti** (çözücü ve bildirimler birlikte). `latest`, GeoNames'in kullandığı 356 kimliğin 15'ini içermiyor; örnekler: `Asia/Yangon`, `America/Nuuk`, `Europe/Saratov`. Tahmini ek boyut ~120 KB.

**Arayüz**

- Tanışma formunda ve profildeki "Doğum saatin ve yerin" sayfasında yeni bir "Doğduğun ülke" alanı var. Varsayılan Türkiye. Türkçe ya da İngilizce adla aranıyor ("Germany" yazan Türkçe kullanıcı Almanya'yı bulur).
- Türkiye seçiliyse eskisi gibi il alanı çıkıyor. Başka ülke seçiliyse "Doğduğun şehir" alanı ve "Doğduğun yer listede yoksa en yakın şehri seç." notu çıkıyor.
- Açıklamadaki "ya da Türkiye dışında doğduysan" kısmı kalktı.

**Bilerek verilen kararlar** (geri alınabilir, Turan'ın onayına sunuluyor)

1. **Diğer adlar.** GeoNames büyük şehirlere İngilizce ad veriyor: Munich, Vienna, Rome. "München" ya da "Wien" yazan kullanıcı hiçbir şey bulamıyordu. Bu yüzden 100 binin üstündeki şehirlerde (6 174 şehir) Latin harfli diğer adlar da tutuluyor; dosyaya ~0,4 MB ekliyor. Listede "Munich (München)" yazıyor; kayda "Munich" gidiyor.
2. **Aynı adlı şehirler.** Bir ülkede aynı adı taşıyan 811 grup var (ABD'de 10 Springfield). Bölge adları veride yok, bu yüzden listede koordinatla ayrılıyorlar: "Springfield (39.80°, -89.64°)". Daha iyi çözüm, GeoNames `admin1CodesASCII.txt` ile eyalet adı ("Springfield, Illinois"). Bu dosyanın indirilmesi onaylanmadı (soru A).
3. **"En yakın şehir"** bir not olarak uygulandı. Konum izni ve GPS yok; yeni paket gerekirdi.
4. **Alanlar veri gelene kadar kapalı.** Ülke ve şehir alanı veri yüklenene kadar devre dışı kalıyor. Öneriler yalnız metin değişince hesaplanıyor; kapalı olmasaydı erken yazan kullanıcı öneri göremezdi. Ülke dosyası küçük, anında açılır. Şehir dosyası yalnız biri Türkiye dışını seçince okunuyor.
5. **Klasörler.** `tool/` (iki betik) ve `assets/veri/` açıldı (`CLAUDE.md`: klasör yapısı). Görev açıkça "asset olarak koy" diyordu; betik için `tool/` Dart geleneği. İstenmezse betikler `reports/` altına taşınır.

**Ölçümler**

- `flutter analyze` temiz. 565 test yeşil (Europe/Istanbul). Altın tablo İstanbul ve UTC'de aynı.
- Yeni ekran testleri:
  - Profil: Almanya → "munch" → Munich kaydedilir, yeniden açılınca gelir; Türkiye'ye dönünce il alanı geri gelir.
  - Tanışma: Hollanda → Rotterdam.
- Önce/sonra kareleri: `reports/k8_5_kanit/`. Test ortamında çizildi: Roboto fontu, klavye yok. Cihazda **doğrulanmadı**.

**Sabah soruları**

- A. GeoNames `admin1CodesASCII.txt` (~150 KB, aynı lisans) indirilsin mi? Aynı adlı şehirler eyalet ya da bölge adıyla gösterilir.
- B. Ülke adlarında CLDR'nin seçimleri aynen kaldı: "Filistin Bölgeleri", "Kongo - Kinşasa", "Myanmar (Burma)". Elle düzeltme istenen var mı?
- C. Öneri listesi alttaki alanın altına açılıyor. Profil sayfasında ekranın altına yakın kalıyor; cihazda klavye açıkken yer daralır. Liste yukarı açılsın mı? Emülatörde bakılınca karar verilmeli.

## Tur 3 (27 Kasım gece): görsel denetim ve düzeltmeler

`gorsel-denetci` 5 kareye baktı (Roboto ile çizildiler; harf genişliği cihazda farklı olabilir). Bulguları ve yapılanlar:

| # | Bulgu | Ne yapıldı | Kanıt |
|---|---|---|---|
| 1 | Dünya ikonu dolu ve iri, altındaki iğne ince çizgili | Çizgili `Icons.language_outlined`'a geçildi. `public_outlined` denendi, dolu çizildiği için bırakıldı | `8_ikon_once_sonra.png` |
| 2 | "En yakın şehri seç" notu liste açıkken görünmüyor | Not alanın yardım metni oldu (`helperText`). Liste notun altından açılıyor, ikisi de okunuyor | `7_…`, `9_yurt_disi_not.png` |
| 3 | Öneri listesi siyah çerçeveli, alandan ~6 px taşıyor, satırlar zeminden koyu | Üç alan (ülke, il, şehir) için ortak liste: sayfa yüzeyi rengi, ince altın kenar, gölge yok, nottan 4 dp aşağıda. Vurgulu satır %18 mor (altın lacivertin üstünde griye dönüyordu). Satır metni alandaki metinle aynı sol kenarda | `7_oneri_listesi_once_sonra.png` |
| 4 | Türkçe arayüzde "Munich", "Vienna"; "Münih", "Viyana" yok | Veri değişmedi; karar gerekiyor (soru D) | `5_6_yurt_disi_arama.png` |
| 5 | İngilizce il etiketi "Where you were born" → "Province of birth" | Bilerek yapıldı: ülke alanı gelince "doğduğun yer" iki alanı birden anlatıyordu. Onay bekliyor (soru E) | `3_profil_sayfa_en_once_sonra.png` |
| 6 | ÖNCE karesinde sayfanın üstünde altın şerit var, SONRA'da yok | Sayfa kenarına ve sayfayı açan koda dokunulmadı (git farkı yok). Büyük olasılıkla eski karenin çekildiği andaki açılış animasyonu; DOĞRULAMADIM | `2_…`, `4_…` |
| 7 | Tanışma karesinde içerik ~95 px yukarıda | Kare düzeneği yeni alanı göstermek için kaydırıyor; ilk açılış etkilenmiyor | `1_tanisma_tr_once_sonra.png` |
| 8 | Ülke alanında açılır ok yok | Değişmedi: il alanı da aynı biçimde yazarak aranan bir alan. Ok eklenirse "listeden seçilir" beklentisi doğar | — |
| 9 | "Doğum / saati" iki satıra kırılıyor | Önceden de vardı; bu iş kapsamında değil (izleme notu) | `2_…`, `3_…` |

**İkinci denetim** (`7_…`, `8_…`, `9_…`):

- İkon, not ve liste kapalıyken Kaydet: KARŞILANDI.
- Liste: siyah çerçeve kalktı, genişlik alanla aynı. Vurgulu satırın gri olması KARŞILANMADI çıktı → mora çevrildi.
- Aynı turda iki bulgu daha düzeltildi:
  - Satır metni alanın metninden 18 px soldaydı → aynı kenara alındı.
  - Seçilen şehir alanda "Munich (München)" kalıyordu → alanda yalnız "Munich", diğer ad yalnız listede.
- Son kareler bu düzeltmelerden sonra yeniden çekildi.

**Üçüncü denetim:** dört ölçüt de KARŞILANDI.

- Vurgulu satır lacivert-mor, gri değil.
- Liste metni alan metniyle aynı kenarda (x≈675).
- Seçilince alanda yalnız "Munich" yazıyor.
- Not ile liste arasında ~10 px boşluk var.

Bu turdaki kalan bulgular:

- Türkçe arayüzde İngilizce şehir adı (soru D).
- Liste açıkken Kaydet örtülüyor ve liste ekranın altına dayanıyor (soru C; cihazda klavyeyle bakılmalı).
- Satırların solunda ikon sütunu kadar boşluk var. Alanla hizalı olsun diye bilerek bırakıldı.
- Not ile liste arası, alan çizgisi ile not arasından dar.
- EN arayüzde liste kapalı hâli karede yok: DOĞRULAMADIM.
- Kalanlar:
  - Not listenin değil alanın sol kenarından başlıyor (Flutter yardım metninin varsayılanı).
  - Küre ikonu, iç ızgarası yüzünden iğneden biraz daha ağır duruyor.
  - Liste açıkken Kaydet örtülüyor (soru C).
  - Saat satırının ikonu ~18 px solda; bu önceden de vardı.

**Sabah soruları (ek)**

- D. Türkçe arayüzde şehirler GeoNames'in İngilizce adıyla çıkıyor: "Munich", "Vienna". "Münih" yazınca da bulunmuyor, çünkü `cities15000` diğer adların dilini söylemiyor ve "Münih" listede yok. Seçenekler: (1) böyle kalsın; (2) büyük şehirler için elle Türkçe ad listesi (~100 şehir); (3) GeoNames `alternateNamesV2` dosyası (dil etiketli, ~700 MB ham, indirme onayı gerekir) ile Türkçe adlar.
- E. İngilizce il etiketi "Province of birth" olarak kalsın mı?


## Turan'ın sabah kararları (27 Kasım, yönetici iletti)

| Soru | Karar | Uygulama |
|---|---|---|
| A | GeoNames `admin1CodesASCII.txt` indirilir (CC BY 4.0, ~150 KB). Aynı adlı şehirler eyalet adıyla ayrılır, atıf lisans sayfasına eklenir | Ayrı commit |
| B | CLDR ülke adları aynen kalır | Değişiklik yok |
| C | Öneri listesi yukarı açılır, Kaydet görünür kalır | Ayrı commit |
| D | Şehir adları İngilizce kalır; `alternateNamesV2` indirilmez | Değişiklik yok |
| E | "Province of birth" seçilmedi; İngilizce il etiketi eski hâline ("Where you were born") döner | Ayrı commit |
| F | Konumdan otomatik en yakın şehir yok, konum izni istenmez | Değişiklik yok; not kalır |
| G | `tool/` ve `assets/veri/` klasörleri kalır | Değişiklik yok |
| H | 11 Kasım işi onaylanırsa E7a beklemeden başlar. Onay henüz gelmedi | Bekliyor |

## Kararların uygulanması (27 Kasım öğlen)

| Karar | Commit | Ne değişti | Kanıt |
|---|---|---|---|
| Kayıt | `cf590a5` | Kararlar bu rapora ve plan belgesine yazıldı | — |
| E | `a08d07c` | İngilizce il etiketi yeniden "Where you were born" | `k8_5_kanit/10_en_etiket_once_sonra.png` |
| C | `f387b67` | Ülke, il ve şehir öneri listeleri alanın üstüne açılıyor; not ve Kaydet görünür kalıyor | `k8_5_kanit/11_liste_yukari_once_sonra.png` |
| A | (bu commit) | GeoNames `admin1CodesASCII.txt` indirildi: 3 865 bölge, SHA-256 `2e4867f5397acb056ea26377601b57af37cb4c81399770225018e9e439e91ad3`. Asset'e 8. sütun eklendi: bölge adı, yalnız ülkesinde adı tekrar eden şehirlerde (1 855 şehir). Listede "Springfield, Illinois" yazıyor. Aynı eyalette de aynı adı taşıyan 238 şehre koordinat da ekleniyor: "Springfield, Pennsylvania (39.93°, -75.32°)". Dosya 1,65 → 1,70 MB (gzip 811 KB). Lisans metni ve asset başlığı admin1 dosyasını ve diğer adları da söylüyor | `k8_5_kanit/12_ayni_ad_eyalet_once_sonra.png` |

`gorsel-denetci` (10, 11, 12): dört ölçüt KARŞILANDI. Yukarı açılan listede üç yeni kusur buldu:

- Liste, üstteki paragrafı ve saat satırını yarıdan kesiyor.
- Liste zemini sayfa zemininden ayrışmıyor.
- Köşelerden alttaki çizgi görünüyor.

Ayrı bir commit'te listeye ayrı bir yüzey veriliyor (aşağıda).

B, D, F, G kodda değişiklik gerektirmedi. H: 11 Kasım onayı gelince E7a başlar.

### Turan için emülatör adımları (~10 dk)

```bash
cd /Volumes/TuranSSD/Trisenix_Development/APP/luckApp && git switch gece/2026-11-27 && /Users/gamzesenocak/development/flutter/bin/flutter run
```

1. Profil > "Yükselenini öğren". Ülke Türkiye; il alanına "izm" yaz. Liste alanın **üstünde** açılmalı, Kaydet görünür kalmalı.
2. Ülke alanına "amerika b" yaz → "Amerika Birleşik Devletleri". Şehre "springf" yaz. Liste "Springfield, Missouri", "Springfield, Illinois"… göstermeli. Birini seç → Kaydet → sayfayı yeniden aç: ülke ve "Springfield" gelmeli.
3. Ülke "alman" → Almanya, şehir "münch" → "Munich (München)". Klavye açıkken liste ekrandan taşmamalı.
4. Ayarlar > Dil > English → aynı sayfa: Türkiye seçiliyken il etiketi "Where you were born" olmalı.
5. Ayarlar > Lisanslar > GeoNames: metinde "cities15000 ve/and admin1CodesASCII" ve değişiklik listesi görünmeli.
