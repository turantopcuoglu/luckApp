# İngilizce Sürüm Planı ve Devir Notu

> **Yeni sohbete başlarken:** Bu dosyayı ve `CLAUDE.md`'yi baştan sona oku.
> Sonra "Oturum sırası" bölümünde işaretlenmemiş ilk oturumu, "Hazır
> komut" metniyle başlat. Her oturum sonunda bu dosyadaki ilgili kutuyu
> `[x]` yap ve "Son durum" tablosunu güncelle.

---

## 1. Son durum (bu dosya yazıldığında)

| Bilgi | Değer |
|---|---|
| Tarih | 27 Kasım 2026 (E0–E6b tamamlandı; 11 Kasım içerik yeniden yazımı commit'lendi, Turan onayı bekliyor) |
| Son commit | `gece/2026-11-27` dalında; `main` hâlâ `3ac2c95` (20 Eki). 11 Kasım işi `2bbbe9d` kurtarma commit'inde, değiştirilmeden |
| Dal | `gece/2026-11-27` (birleştirme Turan'ın kararı). Önceki oturumlar doğrudan `main`'e commit edildi |
| Testler | 488 test, tamamı yeşil (`flutter test`, 27 Kas; E6b'deki 415'ten bu yana 20 Eki commit'leri ve 11 Kasım işi: çelişki kapısı, kimlik portresi, gün devri) |
| Analiz | `flutter analyze` → No issues found (`build/**` 27 Kas'ta analizden çıkarıldı) |
| Uygulama dili | Türkçe. gen-l10n altyapısı kurulu (E3); İngilizce `DilConfig.ingilizceYayinda = false` ile kapalı (yalnız debug'da Ayarlar'dan seçilebilir) |

### Bu sohbette tamamlanan büyük işler (commit sırasıyla)

1. Metin denetimi: tekrar önleyici havuzlar + `tekrar_denetimi_test.dart`
2. Derin numeroloji motoru (zirveler, zorluklar, karmik sayılar…)
3. Numeroloji raporu metinleri + ekranı + tek seferlik satın alma (`kader_rapor_tam`)
4. Kişisel Yıl Raporu (içerik, ekran, ana ekran kartı, `kader_yil_2027` ürünü)
5. Keşfet sekmesi: isim analizi, numara analizi, bebek ismi + görsel paylaşım
6. Astronomi motoru (Meeus), 81 il, Türkiye saat dilimi geçmişi (IANA ile doğrulandı),
   Ay/Yükselen metinleri, Büyük Üçlü kartı ve doğum bilgisi girişi

### Geliştiricinin (Turan) bekleyen işleri

- [ ] **11 Kasım işine bak ve karar ver** (dal `gece/2026-11-27`): emülatör turu, sonra `main`'e birleştirme izni. Belge: `reports/11_kasim_icerik_yeniden_yazimi.md`. E7 buna bağlı.
- [x] **K7** (§5): **kapandı, hayır** (26 Kas, KARARLAR). Tanışma kalıntıları silindi (9436741, 0530549, 177a547, 7e1bbf1); E7b–E7c küçüldü. Kanıt ve içerik açıkları: `reports/k7_kanit/README.md`.
- [ ] **K8** (§5): saat dilimi ve doğum yeri. 26 Kas kararı: "Önerilerle git". K8-1 (motor açık UTC farkı) kapandı; K8-2…K8-5 açık.
- [ ] Mağaza işleri sıralı listede: `reports/magaza_hazirligi.md`.
- [ ] Play Console: `kader_rapor_tam` ve `kader_yil_2027` tek seferlik ürünlerini aç.
- [ ] Emülatör kontrolü: yıl raporu kartı, 5 sekmeli alt menü, paylaşım görseli,
      doğum saati seçici, il otomatik tamamlama.
- [ ] Satışa açmadan önce hukuki danışmanlık (Türkiye'de 677 sayılı Kanun riski;
      konumlandırma "eğlence / kendini keşif", "fal" değil).
- [ ] İl koordinatlarını bir kez resmî kaynaktan kontrol et (±0.1° yazıldı).
- [x] K4: uygulama adı **Solenia**, iki dilde (26 Kas, KARARLAR `d024d2e`). Mağaza başlığı taslağı: `reports/magaza_metni_taslak.md`.
- [ ] K5: E9'daki İngilizce yasal metin taslağını hukukçuya onaylat.
- [ ] **Görseller:** Ayrı plana taşındı: `GORSEL_YENILEME_PLANI.md` (durum,
      oturum sırası) ve `GORSEL_URETIM_REHBERI.md` (GPT istemleri).
      `CIZIM_LISTESI.md` eskidi.

---

## 2. Çalışma kuralları (yeni sohbet için kritik)

`CLAUDE.md` geçerlidir. Ek olarak bu projede oturmuş pratikler:

1. **Bir oturum = bir sistem.** Sistemler: `luck_engine`, `content`, `storage`,
   ve her `features/<ad>` klasörü. İki sisteme zorunlu dokunuş olursa minimum
   tut ve özette açıkça söyle.
2. **Paket ekleme ve yeni klasör = kullanıcı onayı.** Aşağıdaki "Onay
   gerektiren kararlar" bölümü onaylanmadan i18n işine başlanmaz.
3. **Her oturum sonunda:** `flutter analyze` sıfır sorun, `flutter test`
   tamamı yeşil, kısa Türkçe özet. Commit yalnızca kullanıcı isteyince.
4. **Commit mesajı biçimi:** Türkçe başlık + madde işaretli gövde + son satır
   `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
5. **`dart format` yalnızca düzenlenen dosyalara.** Klasöre toplu format
   atma; dokunulmamış dosyalar biçimlenirse `git checkout -- <dosya>` ile geri al.
6. **Ortam (8 Ekim 2026'dan beri macOS):** *27 Kasım notu: proje artık
   `/Volumes/TuranSSD` (APFS) diskinde; `flutter test` doğrudan diskte
   çalıştı (488 test, 35 sn), rsync kopyasına gerek kalmadı. `build/**`
   analizden çıkarıldı, `flutter analyze` de doğrudan çalışır. Mac'in saat
   dilimi +07 (Asia/Ho_Chi_Minh). Altın kayıt 26 Kas'tan (K8-1) beri
   makinenin saat diliminden bağımsız.
   Aşağısı eski exFAT notudur.* Proje exFAT biçimli harici
   diskte (`/Volumes/PortableSSD`). macOS her yazılan dosyanın yanına `._*`
   (AppleDouble) dosyası bırakır; bu yüzden `flutter test` diskte
   `FileSystemException: Deletion failed` ile çöker (native assets/ephemeral
   kopyalama). Çözüm: depoyu scratchpad'e `rsync -a --exclude build/
   --exclude .dart_tool/ --exclude '._*' --exclude ios/Pods/ --exclude
   ios/Flutter/ephemeral/` ile kopyalayıp testi orada çalıştır.
   `flutter analyze` diskte çalışır ama `build/ios/SourcePackages` da
   tarandığı için `flutter analyze lib test` kullan. Eski Windows notu:
   `python` yok. Çok satırlı düzenlemeler için scratchpad
   dizininde küçük Dart betikleri (`dart run <betik>.dart`) ya da Edit aracı
   kullanıldı. Bash heredoc içinde `₺` gibi karakterler ve tırnaklar sorun
   çıkarabilir; o durumda betiği Write ile dosyaya yaz. Dart betiğinde
   `$` içeren metinler için raw string (`r'''…'''`) kullan.
7. **Testlerde kaydırma:** Sayfada TextField varsa `scrollUntilVisible`'a
   `scrollable: find.byType(Scrollable).first` ver; henüz çizilmemiş öğeyi
   `.first` ile arama, önce bilinen bir başlığa kaydır.
8. **Adlandırma:** Kod Türkçe adlandırılır (`gunlukOkuma`, `KaderProfili`).
   İngilizce sürümde de bu sürer; yalnızca kullanıcıya görünen metin İngilizce olur.

---

## 3. Bozulmaması gereken değişmezler

Bu maddeler İngilizce sürüm yapılırken **Türkçe kullanıcıların deneyimini
bozmamak** için konuldu. Her biri bir testle korunmalı.

| # | Değişmez | Neden / Nerede |
|---|---|---|
| D1 | Aynı (kullanıcı, gün) → aynı skor ve aynı metin seçimi (kural 8). | `LuckEngine.hesapla`, `donguselIndeks`. |
| D2 | **Amaç etiketleri ve havuz boyutları değişmez.** Varyant seçimi `donguselIndeks(amac, havuzBoyutu)` ile yapılır; `ContentConfig.amac*` dizgileri ya da bir havuzun eleman sayısı değişirse Türkçe kullanıcının o günkü metni değişir. | `content_config.dart`, `fortune_composer.dart` |
| D3 | **İngilizce havuzlar Türkçeyle indeks hizalı olmalı:** aynı sayıda varyant, aynı sırada. Böylece iki dilde aynı gün aynı anlamdaki varyant seçilir ve D2 bozulmaz. | Tüm içerik havuzları |
| D4 | Geri bildirim kimliği (`bolumKimligi`) metnin FNV özetidir; Türkçe metinler değişirse kayıtlı "beni anlatmadı" işaretleri eşleşmez. Türkçe metinlere i18n sırasında **dokunma**. | `fortune_composer.dart`, `slot_doldurucu.dart` (`metinKimligi`) |
| D5 | Skor tohumu görünen isimden (`isim.toLowerCase()`) türer; dil/locale ayarı tohumu etkilememeli. | `user_seed.dart` |
| D6 | Numeroloji harf tablosu (Pitagor, Türkçe harfler Latin karşılığı, Y sessiz) iki dilde **aynı** kalır; aksi hâlde aynı adın sayıları dile göre değişir. | `numeroloji.dart` |
| D7 | Türkçe içerik çıktısı byte düzeyinde aynı kalmalı. **İlk i18n oturumundan önce** Türkçe çıktıların "altın kayıt" testini yaz (bkz. E1). | yeni test |
| D8 | Satın alma ürün kimlikleri dilden bağımsız: `kader_premium_aylik`, `kader_premium_yillik`, `kader_rapor_tam`, `kader_yil_<yıl>`. | `premium_config.dart` |
| D9 | Mevcut testlerdeki Türkçe beklentiler (ör. "Bugün" açılış kuralı) Türkçe paket için aynen geçmeye devam eder; İngilizce için **ayrı** eşdeğer testler yazılır. | `test/content/*` |

---

## 4. Dile bağlı noktaların envanteri

### 4.1 Arayüz metinleri (kısa, ARB'ye uygun)

`lib/features/**/*_strings.dart` ve birkaç dağınık sabit:

| Dosya | Satır (yaklaşık) |
|---|---|
| ~~`features/daily_luck/tr_strings.dart`~~ (E5'te ARB'ye taşındı, silindi) | — |
| ~~`features/onboarding/onboarding_strings.dart`~~ (E4'te ARB'ye taşındı, silindi) | — |
| ~~`features/profile/profile_strings.dart`~~ (E6'da ARB'ye taşındı, silindi) | — |
| ~~`features/premium/premium_strings.dart` + `PremiumHatalari`~~ (E6) | — |
| ~~`features/tools/tools_strings.dart`~~ (E6) | — |
| `features/settings/ayarlar_strings.dart` | 113 |
| ~~`features/compatibility/uyum_strings.dart`~~ (E6) | — |
| ~~`features/feedback/feedback_strings.dart`~~ (E5) | — |
| ~~`features/share/share_strings.dart`~~ (E5) | — |
| ~~`features/categories/categories_strings.dart`~~ (E5) | — |
| `features/home/ana_sekme.dart` (sekme etiketleri enum içinde) | — |
| ~~`features/profile/tam_ad_duzenle.dart` (`TamAdStrings`)~~ (E6) | — |
| ~~`features/koleksiyon/koleksiyon_strings.dart`~~ (E6b) | — |
| `features/legal/legal_texts.dart` (KVKK/koşullar — **hukuki metin**, çeviri değil yeniden yazım) | 216 |

### 4.2 Motor içindeki Türkçe etiketler (taşınmalı)

`luck_engine` enum'larında kullanıcıya görünen `etiket` alanları var; motor
UI metni taşımamalı. Bunlar içerik katmanında dil bazlı etiket tablolarına
taşınacak (E2):

- `Burc.etiket`, `BurcElementi.etiket` (`burc.dart`)
- `LuckCategory.etiket` (`luck_category.dart`)
- `AyEvresi.etiket` (`ay_evresi.dart`)
- `UyumDerecesi.etiket` (`uyum.dart`)
- `content/okuyucu.dart`: `EnerjiTarzi`, `KararTarzi`, `IliskiDurumu`, `Ugras` etiketleri ve `Ugras.alan`

### 4.3 Uzun içerik (ARB'ye uygun değil; dil paketleri)

`lib/core/content/` toplam ~7.900 satır. Başlıcaları:

| Dosya | İçerik |
|---|---|
| `gokyuzu_metinleri.dart`, `yorum_yonu.dart`, `karakter_yonleri.dart`, `kisilik_metinleri.dart`, `kimlik_metinleri.dart`, `kisisel_havuzlar.dart` | Günlük okuma ve kategori detayı (tekrar denetimine ve çelişki kapısına tabi; 27 Kas güncel) |
| `fortune_pools.dart`, `dongu_metinleri.dart`, `neden_metinleri.dart` ("çünkü" satırı dahil), `sans_rengi.dart` | Günlük okuma yardımcıları |
| ~~`kategori_durumlari.dart`, `category_pools.dart`~~ | 11 Kasım'da silindi (20 Ekim'den beri ölü koddu) |
| `sayi_metinleri.dart`, `burc_metinleri.dart` | Kader Profili |
| `rapor_metinleri.dart` | Numeroloji raporu |
| `yillik_rapor_metinleri.dart` | Kişisel Yıl Raporu |
| `arac_metinleri.dart` | Keşfet araçları |
| `harita_metinleri.dart` | Ay / Yükselen |
| `uyum_metinleri.dart` | Uyum |

### 4.4 Dilbilgisine bağlı mantık

- `content/turkce_ek.dart`: ünlü uyumu ve ekler (`{isminin}` → "Ayşe'nin").
  İngilizcede iyelik ("Ayşe's") için ayrı yardımcı gerekir.
- Yer tutucular (`slot_doldurucu.dart`): `{gunIstegi}` ve `{doga}` **mastar
  öbekleri** cümle içine gömülür ("…bugün senden {gunIstegi} istiyor").
  İngilizce karşılıklar **-ing biçiminde** yazılmalı ve cümleler buna göre kurulmalı.
- `ContentConfig.kalipIfadeler` ve "Bugün" açılış kuralı Türkçeye özgü.
  İngilizcede karşılığı: "Today" yalnızca açılışta, kalıplar
  ("a good day to", "is a great day for" …).

### 4.5 Türkiye'ye özgü veri

- `TurkiyeIlleri` (81 il) ve `TurkiyeSaatDilimi` yalnızca Türkiye doğumları içindir.
- İngilizce sürümün ilk yayınında **Yükselen yalnızca Türkiye'de doğanlar için**
  hesaplanır; diğerleri için `HaritaMetinleri.yukselenIcinBilgiEksik`
  karşılığı gösterilir. Dünya geneli (E10) ayrı ve büyük bir iştir.

---

## 5. Onay gerektiren kararlar (E0'da soruldu, 8 Ekim 2026)

| # | Karar | Önerilen | Cevap (Turan) |
|---|---|---|---|
| K1 | Arayüz metinleri için Flutter `gen-l10n` (ARB). `pubspec.yaml`'a `flutter_localizations` (sdk), `intl` ve `flutter: generate: true` eklenir. | Evet | **Evet.** pubspec değişikliği ve `lib/l10n/` klasörü (+ kökte `l10n.yaml`) E3 için onaylı. |
| K2 | İçerik dil paketleri için klasör düzeni: `lib/core/content/tr/` ve `lib/core/content/en/` (mevcut dosyalar `tr/` altına taşınır) **ya da** taşımadan `*_en.dart` ek dosyaları. | Taşıma yok: `*_en.dart` ek dosyaları (daha az kırılma riski, D4/D7 için güvenli) | **`*_en.dart` ek dosyaları**, taşıma yok. |
| K3 | Dil seçimi: cihaz dili `tr` ise Türkçe, değilse İngilizce; Ayarlar'dan elle değiştirilebilir. Seçim `UygulamaDurumu`'na yazılır. | Evet | **Evet** (cihaz dili + Ayarlar'dan elle seçim, `UygulamaDurumu`'nda saklanır). |
| K4 | İngilizce uygulama adı (mağaza ve launcher). | Kullanıcı karar verir (ör. "Kader: Numerology & Luck") | **Kapandı (26 Kas):** Solenia. EN başlık "Solenia: Birth Chart & Moon", TR "Solenia: Doğum Haritası ve Ay" (taslak). Paket kimliği `com.turan.kader` yayından önce değişecek (Turan). |
| K5 | İngilizce yasal metinler (gizlilik, koşullar, sorumluluk reddi) kim tarafından yazılacak/onaylanacak? | Taslağı Claude yazar, hukukçu onaylar | **Taslağı Claude yazar (E9), hukukçu onaylar** (yayın öncesi Turan'ın işi). |
| K7 | *(27 Kas, yeni)* Tanışma soruları (enerji, karar, ilişki, uğraş) 11 Kasım'da onboarding'den kaldırıldı. Kod hâlâ `OkuyucuTercihleri`'ne göre dallanan havuzlar taşıyor: Aşk'ta bekâr/partnerli sahneleri, uğraş sahneleri, `kisiselYap`, `profilUyarlamalari`, `{ugrasAlani}`. Üretimde bunlara hiç ulaşılmıyor. Seçenekler: (a) sorular kalıcı olarak yok; bu havuzlar Türkçeden silinir (ayrı oturum, altın kayıtta yalnız t1/t2 anahtarları değişir) ve E7'de çevrilmez. (b) Sorular ileride geri gelecek; havuzlar kalır ve E7'de çevrilir (yaklaşık %15 daha çok iş). (c) Araştırma raporunun önerisi: kısa bir öz-tanım sorusu geri gelir, cevap metinde görünür kullanılır. | (a), sorular geri gelmeyecekse. Karar ürünü ilgilendiriyor | **Kapandı: (a)** (26 Kas, Turan: "Tanışma soruları olmasın bence…"). Havuzlar silindi; t0 çıktısı aynı kaldı (43 680 anahtarlık döküm). Günün tavsiyesi doğum elementine bağlandı (bilinçli değişiklik). `reports/k7_kanit/README.md` |
| K8 | *(27 Kas, yeni)* `ayEvresiOrani` (`ay_evresi.dart:64`) yerel günü `toUtc()` ile çeviriyor; evre, skor ve metin cihazın saat dilimine göre değişebiliyor. Türkiye'de (+03) sonuç sabit, yurt dışında değil. Altın kayıt da bu yüzden makineye bağlı: tablo +07'de üretildi, Türkiye saatinde 3 test kırılıyor. | Takvim gününü Türkiye gece yarısı (UTC+3) say: Türkiye'deki kullanıcının sonucu değişmez, her yerde deterministik olur. `luck_engine` oturumu + tablo yeniden üretimi | **K8-1 kapandı (26 Kas).** Motor yerel gün + açık UTC farkı alıyor; tablo değişmedi. İstanbul'daki 3 kırık testin nedeni ayrıca test fikstürünün yaz saati hatasıydı, düzeltildi. K8-2…K8-5 (doğum saat dilimi, şehir verisi, arayüz) açık: `reports/turan_notlari_plan_2026-11-27.md`. |
| K6 | Dünya geneli doğum yeri (E10): `timezone` paketi zaten var (tz verisi içerir); şehir veritabanı için GeoNames `cities15000` (CC BY 4.0, ~2 MB asset, atıf gerekir). | İlk yayında yok; sonra | **İlk yayında yok**, E10 sonraya. İngilizce sürümde Yükselen yalnız Türkiye doğumlular için (§4.5). |

---

## 6. Mimari öneri

### 6.1 Arayüz metinleri

- `lib/l10n/app_tr.arb` ve `app_en.arb` (gen-l10n varsayılanı; K1 onayıyla klasör de onaylanmış sayılır).
- `*_strings.dart` sınıfları **bir anda silinmez**: her feature oturumunda o
  feature'ın sabitleri ARB'ye taşınır, widget'lar `AppLocalizations.of(context)`
  kullanır, eski sınıf boşalınca silinir.
- `luck_engine` ve `content` testleri `BuildContext` istemez; bu yüzden
  içerik katmanı ARB'yi **kullanmaz** (bkz. 6.2).

### 6.2 İçerik dil paketleri

```dart
/// Dil bağımsız içerik erişimi (content katmanı, saf Dart).
enum IcerikDili { tr, en }

abstract class IcerikPaketi {
  Map<int, GunTemasi> get gunTemalari;
  Map<int, KarakterYonu> get karakterler;
  // … her havuz için bir getter
  String iyelik(String isim); // "Ayşe'nin" / "Ayşe's"
}

final class TrIcerikPaketi implements IcerikPaketi { /* mevcut sabitlere yönlendirir */ }
final class EnIcerikPaketi implements IcerikPaketi { /* *_en.dart sabitleri */ }
```

- Birleştiriciler (`gunlukOkuma`, `raporOkumasi`, `yillikRaporOkumasi`,
  `haritaOkumasi`, `isimOkumasi`…) isteğe bağlı `IcerikPaketi paket = const TrIcerikPaketi()`
  parametresi alır; varsayılan Türkçe olduğu için mevcut çağrılar ve testler
  değişmeden çalışır (D7).
- Riverpod: `icerikPaketiProvider` dil ayarından paketi seçer; ekranlar
  birleştiriciye bunu verir.

### 6.3 Etiketler

`luck_engine` enum'larındaki `etiket` alanları yerine içerik katmanında
`Map<Burc, String>` gibi tablolar (`paket.burcAdi(Burc)`). Geçiş boyunca enum
`etiket`'i `@Deprecated` kalır; tüm kullanım taşınınca silinir.

---

## 7. Oturum sırası

Her satır tek oturumdur. Kutuyu bitince işaretle.

- [x] **E0 — Kararlar.** K1–K6'yı kullanıcıya sor, cevapları bu dosyaya yaz. Kod yok. (8 Eki; K4 açık)
- [x] **E1 — Altın kayıt testleri (content).** Türkçe çıktıları sabitleyen
      testler: 12 yaşam yolu × 3 tercih × 10 gün `gunlukOkuma.kartMetni`,
      `raporOkumasi`, `yillikRaporOkumasi(2027)`, `profilOkumasi`, `uyumOkumasi`,
      `isimOkumasi`, `numaraOkumasi`, `haritaOkumasi` çıktılarının FNV özetleri
      tek bir test dosyasında. Sonraki her oturumda yeşil kalmalı (D7).
      **Yapıldı (8 Eki):** `test/content/altin_kayit_test.dart`, 207 FNV-1a
      özeti, 11 test: günlük okuma (12 yy × 3 tercih × 10 gün), geri
      bildirimli günlük okuma, kategori detayı (5 kategori), profil (3 yıl),
      uyum (6 kişi), numeroloji raporu (adlı/adsız × 5 yaş), yıllık rapor
      (2026–2034), harita (3 bilgi durumu × 60 doğum), isim (16 ad), numara
      (tarama + biçimli), bebek ismi (3 ebeveyn seti). Dökümde metinler,
      başlıklar, bölüm sırası/türü, premium bayrakları ve geri bildirim
      kimlikleri var. Bilinçli bir Türkçe metin değişikliğinde tablo
      `ALTIN_KAYIT_YAZDIR=1 flutter test test/content/altin_kayit_test.dart`
      ile yeniden üretilir; **E2–E9 boyunca tablo değişmez.** Duyarlılık
      denendi: 10 içerik dosyasında tek kelime değişince 8 grup kırıldı.
- [x] **E2 — Etiketlerin içerik katmanına taşınması (content).** `IcerikDili`,
      `IcerikPaketi` arayüzü, `TrIcerikPaketi` (mevcut sabitlere yönlendirir),
      etiket tabloları. Birleştiricilere `paket` parametresi (varsayılan TR).
      E1 testleri yeşil.
      **Yapıldı (8 Eki):** `content/icerik_paketi.dart` (`IcerikDili`,
      `IcerikPaketi`), `content/tr_icerik_paketi.dart` (`TrIcerikPaketi`,
      tek örnek `trIcerik`; kapsayıcı `switch` ile burç, element, kategori,
      ay evresi, uyum derecesi, 4 tercih enum'u, uğraş öbeği, iyelik).
      İçerik katmanında enum `etiket`/`alan` okuması kalmadı
      (`fortune_composer`, `harita_metinleri`, `neden_metinleri`).
      Tüm birleştiricilerde `paket` parametresi (varsayılan `trIcerik`);
      rapor/yıllık/harita/araç birleştiricilerinde şimdilik kullanılmıyor
      (havuzlar E8/E9'da bağlanır). Test: `icerik_paketi_test.dart`
      (tablolar = enum etiketleri; sahte paketle adların paketten geldiği).
      **Kalanlar:** (1) `features/` hâlâ enum `etiket`'lerini okuyor (~70
      yer); ekranlar E5/E6'da `icerikPaketiProvider` üzerinden pakete geçer.
      (2) Enum `etiket`'leri o zamana dek `@Deprecated` YAPILMADI (analyze
      sıfır sorun kuralı); tüm kullanım taşınınca silinir. (3) Birleştirici
      içindeki satır içi Türkçe kalıplar (`'… burcu · …'`, `'Özün · …'`,
      `'Birlikte'`, `'Tavsiye'` …) E8'de paket getter'larına taşınır.
- [x] **E3 — i18n altyapısı (K1 onayı sonrası).** pubspec, `l10n.yaml`, boş
      ARB'ler, `MaterialApp` locale bağlantısı, `dilProvider` (K3), Ayarlar'da dil
      seçimi. Bu oturumda yalnızca `ana_sekme` ve `ayarlar` metinleri taşınır.
      **Yapıldı (8 Eki):** pubspec (`flutter_localizations`, `intl: any` →
      0.20.2, `generate: true`), `l10n.yaml` (şablon `app_tr.arb`,
      `nullable-getter: false`), `lib/l10n/app_tr.arb` + `app_en.arb` (sekme +
      ayarlar, 41 anahtar). Üretilen `app_localizations*.dart` depoya
      commit'lenir (ARB değişince `flutter gen-l10n`). `lib/l10n/dil_config.dart`
      (`DilConfig.ingilizceYayinda`, dillerin yerel adları),
      `lib/l10n/dil_providers.dart` (`uygulamaDiliniCoz`, `cihazDilKoduProvider`,
      `dilTercihiProvider`, `uygulamaDiliProvider`); tercih
      `UygulamaDurumu.dilKodu`'nda. `KaderApp` locale + delegeler.
      `AnaSekme.etiketi(metinler)`; `AyarlarStrings` silindi. Testler:
      `test/l10n/dil_test.dart`; `test_ortami.dart`'a `testUygulamasi(ev)` ve
      `trMetinler` (AppLocalizations okuyan ekranların testleri bunu kullanır).
      **Notlar:** (1) Yayın anahtarı kapalıyken herkes Türkçe görür; E12'de
      `true` yapılınca K3 devreye girer. (2) Material/Cupertino bileşenleri
      artık Türkçe yerelleştirilmiş (ör. saat seçici, tarih tekerleği gün-ay-yıl
      sırası, geri düğmesi ipucu "Geri"); emülatörde kontrol edilmeli.
      (3) Testte `tester.pageBack()` İngilizce "Back" ipucu aradığı için
      çalışmaz; `find.byType(BackButton)` kullan.
- [x] **E4 — ARB taşıma: onboarding + legal ekranları (UI).** Yasal metin
      gövdesi hâlâ Türkçe kalabilir; E9'da yazılır.
      **Yapıldı (11 Eki):** `OnboardingStrings` (33 metin) → `onboarding*`
      ARB anahtarları, dosya silindi; `hazirlikAdimlari` listesi üç anahtara
      bölündü (sıra `OnboardingConfig.adimEsikleri` ile aynı).
      `RituelNotu.metin` artık `String?` (boşsa ARB'den). Legal'den yalnız
      arayüz metinleri taşındı: `yasalUyariBaslik`, `yasalDevam`,
      `yasalGizlilikPolitikasi`, `yasalKullanimKosullari`;
      `YasalBelge.baslik` alanı `baslik(AppLocalizations)` metoduna döndü
      (paywall ve ayarlar çağrıları güncellendi, tek satır). Testler:
      `dil_test.dart`'a İngilizce karşılama/uyarı ve form/tanışma testleri;
      paywall'u açan iki test `testUygulamasi` ile sarıldı.
      **E9'a kalanlar (bilinçli olarak Türkçe):** `YasalMetinler.uyariMaddeleri`,
      `uyariKabul`, `kisaNot` (sorumluluk reddi, K5 hukukçu onayı) ve
      gizlilik/koşullar gövdeleri. Tanışma seçenek etiketleri
      (`EnerjiTarzi.etiket` …) içerik katmanından gelir, E8 kapsamında.
      **Ortam notu:** `flutter gen-l10n` de `lib/l10n/._*` dosyalarını ARB
      sanıp çöker; önce `find lib test -name '._*' -delete`.
- [x] **E5 — ARB taşıma: daily_luck + categories + feedback + share.**
      `TrStrings.tarihMetni` → `intl` `DateFormat.yMMMMEEEEd(locale)`.
      **Yapıldı (11 Eki):** dört `*_strings.dart` silindi; anahtarlar
      `gunluk*`, `kategori*`, `geriBildirim*`, `bildirim*`, `paylasim*`.
      **Tarih:** `yMMMMEEEEd` Türkçede virgülü düşürdüğü için (D9) kullanılmadı;
      ARB'de desen var: `tarihDeseni` ("d MMMM y, EEEE" / "EEEE, MMMM d, y")
      ve `kisaTarihDeseni`; `lib/l10n/tarih_bicimi.dart` →
      `tarihMetni(l, gun)`, `kisaTarihMetni(l, gun)`. Koleksiyon, profil ve
      ayarlardaki `tarihMetni(...).split(',').first` kısa desene çevrildi
      (İngilizcede "Monday" kalıyordu). `tarih_bicimi_test`: Türkçe çıktı 2
      yıl boyunca eski elle kurulan biçimle birebir aynı.
      **Widget dışı metin:** `dil_providers.dart`'a `arayuzMetinleriProvider`
      (`lookupAppLocalizations`). `ShareService(metinler:)` provider'dan alır
      (araç çağrıları değişmedi); `StoryCard`/`AracStoryCard` `metinler`
      parametresi alır (ekran dışı çizimde `Localizations` yok);
      `AracPaylasimi.paylasimMetni(l)`, `PaylasimTemasi.etiket(l)`.
      Bildirim: `gunlukBildirimleriPlanla(simdi:, metinler:)`; kanal adı ve
      12 sabah varyasyonu ARB'de (`bildirimSabah1..12`, sıra iki dilde aynı;
      testle korunur). `main.dart`'ta planlama `ProviderContainer`
      kurulduktan sonraya alındı.
      **Dile bağlanmayanlar:** `DailyLuckConfig.misafirIsmi` (skor tohumu, D5),
      geri bildirim emojileri → `FeedbackConfig`.
      **Testler:** `MaterialApp(home:)` ile açılan ekran testleri
      `testUygulamasi` ile sarıldı; kart testleri `initializeDateFormatting`
      çağırır. **E12 notu:** dil değişince planlı bildirimler bir sonraki
      açılışta yeni dile geçer; anında geçmesi istenirse Ayarlar'daki dil
      seçimine yeniden planlama eklenmeli.
- [x] **E6 — ARB taşıma: profile + premium + tools + compatibility.**
      **Yapıldı (11 Eki):** dört `*_strings.dart`, `TamAdStrings` ve
      `PremiumHatalari` silindi; 164 anahtar: `profil*`, `tamAd*`,
      `premium*` (`premiumHata*` dahil), `araclar*`, `uyum*`. Liste/kayıt
      sabitleri ekran içinde yardımcıya döndü: `_ozellikler(l)` (paywall),
      `_numaraTurleri(l)` (numara analizi); dönem eki iki anahtar.
      `hesapSatirlari(hesap, metinler)` (adım etiketleri dilde, işlem satırı
      dilden bağımsız; testli). `PremiumKontrolcu` hata metinlerini
      `arayuzMetinleriProvider`'dan alır (testli). Dile bağlanmayanlar:
      doğum saati "08:05" biçimi (`_saatMetni`, iki dilde 24 saat),
      `ProfileConfig.bilinmeyenDeger` ('?').
      **E10'a not (Türkiye'ye özgü):** doğum yeri alanı il listesi; İngilizce
      ipucu şimdilik "Type a province (e.g. İzmir)". Plaka/telefon ipuçları
      İngilizcede genel örneklerle yazıldı.
      **Kalanlar:** burç/rol/bant/yıl lakabı gibi etiketler içerik
      katmanından gelir (E8).
- [x] **E6b — ARB taşıma: koleksiyon** (envanterde unutulmuştu).
      **Yapıldı (11 Eki):** `KoleksiyonStrings` silindi; 12 arayüz anahtarı
      + 24 kartın adı ve sözü (`koleksiyonKart<Ad>Ad/Soz`, 48 anahtar).
      `KoleksiyonKarti.ad(l)` / `soz(l)`; kimlik (`id`) ve katalog sırası
      dilden bağımsız, günün kartı seçimi değişmez. `koleksiyonGunSayisi`
      ICU çoğul biçimi. Test: iki dilde her kartın metni var, Türkçe metinler
      eskisiyle aynı. **Durum:** `lib/features/**` içinde `*_strings.dart`
      kalmadı; arayüzde elle yazılmış Türkçe metin yok (yasal gövde ve
      `LegalConfig.sonGuncelleme` E9'da).
- [ ] **E7 — İngilizce günlük okuma (content).** *27 Kasım'da yeniden
      yazıldı.* Eski E7 planı 11 Kasım içerik yeniden yazımından önceydi;
      silinen `kategori_durumlari.dart` ile `category_pools.dart` dosyalarını
      içeriyordu ve yeni katmanları (gökyüzü, kişilik, kimlik portresi,
      "çünkü" satırı, çelişki kapısı) hiç saymıyordu. Ayrıntı:
      `reports/11_kasim_icerik_yeniden_yazimi.md`.
      **Ön koşul:** Turan 11 Kasım işini onaylamış olmalı (dal
      `gece/2026-11-27`), K7'yi cevaplamalı ve K8 çözülmüş olmalı (§5).

      **Yeni Türkçe günlük okumanın parçaları (çevrilecek olanlar):**

      | Okuma parçası | Türkçe kaynak | Boyut (yaklaşık) |
      |---|---|---|
      | "Çünkü" satırı | `NedenMetinleri.cunku` + `_cunkuAy` (4 şablon); ay adları `YillikRaporMetinleri.ayAdlari` | 5 şablon + 12 ay |
      | Enerji: günün durumu | `YorumYonu.gunTemalari[k].durum` | `yorum_yonu.dart` (~3,2 bin kelime, tüm dosya) |
      | Enerji: günün gökyüzü | `GokyuzuMetinleri.gunler` (element ilişkisi × gün tonu) | `gokyuzu_metinleri.dart` (~6,1 bin kelime, tüm dosya) |
      | Enerji: sayı günü / burç günü | `YorumYonu.bulusmaCumleleri`; burç günü `KimlikMetinleri.portreler` (harita biliniyorsa) ya da `YorumYonu.gunSahneleri` | `kimlik_metinleri.dart` (~340 kelime) |
      | Enerji: öneri | `KarakterYonu` tavsiyeleri (`YorumYonu.karakterler` = `KarakterYonleri.hepsi`) | `karakter_yonleri.dart` (~4,1 bin kelime) |
      | Öne çıkan / Dikkat | `GokyuzuMetinleri.gokyuzu` (Ay yarısı `ayOnekisizHali` ile atılır), kişilik `KisilikMetinleri.burc` ya da `KarakterYonu.kategoriTarzi`, gün aşırı `GokyuzuMetinleri.sahneler`, `KisiselHavuzlar.eylemCumleleri`, `GokyuzuMetinleri.yapma` | `kisilik_metinleri.dart` (~2,4 bin), `kisisel_havuzlar.dart` (~600) |
      | Kapanış, başlık, tavsiye, renk | `DonguMetinleri.kisiselYil`/`gunBasliklari`, `YorumYonu.kapanisHavuzu`, `FortunePools.gununTavsiyeleri`/`sansRenkleri` | ~800 kelime |
      | "Neden bugün?" çipleri | `NedenMetinleri.*Etiketi/*Aciklamasi` | ~200 kelime |
      | Kategori detayı | `GokyuzuMetinleri.basliklar/gokyuzu/sahneler/yap/yapma` (+ `kisiselYap`) | yukarıdakilerin içinde |

      Toplam yaklaşık **18 bin Türkçe kelime**. Tek oturuma sığmaz; beş
      oturuma bölündü.

      **Türkçeye bağlı mantık (E7a'da pakete taşınmalı):**
      - `ayOnekisizHali`: `ContentConfig.gokyuzuAyraci` (`'; '`),
        `bugunOneki` (`'bugün '`), `bagimliKuyrukBaslangiclari`,
        `bagimliKuyrukIfadeleri`. İngilizce gökyüzü cümleleri de "Ay
        yarısı; alan yarısı" biçiminde ve `'; '` ayracıyla yazılmalı.
      - Çelişki kapısı: `ContentConfig.celiskiIfadeleri` (Türkçe ifade
        listeleri) ve `KisilikMetinleri._harf` (Türkçe harf kümesi, kelime
        başı eşleşmesi). İngilizcenin kendi ifade listesi olmalı.
      - Büyük/küçük harf: `TurkceEk.kucukHarf`, `KimlikMetinleri._buyukBasla`
        (i/İ). İngilizcede düz `toUpperCase`.
      - Kimlik kalıpları `{dis}`/`{ic}`/`{Ic}` yan cümle varsayar
        ("içinde ise {ic}."). İngilizce kalıplar ifadelerle birlikte yazılır.
      - "Çünkü" satırında tarih: `"14 Mart doğumlusun"` → İngilizcede
        `"born on 14 March"` ya da `"born March 14"` (ARB `tarihDeseni` ile
        aynı sıra seçilmeli).

      **Oturumlar:**
      - [ ] **E7a: altyapı (kod; İngilizce metin yok).** `IcerikPaketi`'ne
            günlük okuma havuzlarının getter'ları ve yukarıdaki Türkçe
            sezgiler (ayraç, önek, bağımlı kuyruk, çelişki ifadeleri, harf
            kümesi, büyük/küçük harf, ay adları). `TrIcerikPaketi` bugünkü
            sabitlere yönlendirir. `gunlukOkuma`, `kategoriOkumasi` ve
            `NedenMetinleri.cunku` `paket` üzerinden okur. **Altın kayıt
            değişmez (D7).** D3 hizalama testinin iskeleti (EN boşken atlanır).
      - [ ] **E7b: İngilizce gökyüzü.** `gokyuzu_metinleri_en.dart`
            (~570 cümle): `gunler`, `gokyuzu`, `basliklar`,
            `sahneler`, `yap`, `yapma` (K7 kapandı: `kisiselYap` ve
            tercih sahneleri silindi, çevrilmez). Test: her İngilizce gökyüzü cümlesinde
            `'; '` ayracı Türkçedekiyle aynı yerde mi; `ayOnekisizHali` iki
            dilde aynı indekste null mı.
      - [ ] **E7c: İngilizce kişilik, kimlik ve çelişki kapısı.**
            `kisilik_metinleri_en.dart`, `kimlik_metinleri_en.dart`, İngilizce
            `celiskiIfadeleri` (K7: yalnız enerji, karar ve iki ilişki
            varsayımı anahtarı kaldı). **Dil arası kapı testi:** her portre için
            `celisir(tr[i]) == celisir(en[i])`. Böylece iki dilde aynı kişiye
            aynı cümleler elenir ve D3 bozulmaz.
      - [ ] **E7d: İngilizce gün temaları ve karakterler.**
            `yorum_yonu_en.dart`, `karakter_yonleri_en.dart` (~7,4 bin kelime;
            gerekirse yarıya bölünür). `{gunIstegi}`/`{doga}` "-ing" öbeği (§4.4).
      - [ ] **E7e: küçük havuzlar, "çünkü" ve uçtan uca testler.**
            `kisisel_havuzlar_en`, `dongu_metinleri_en`, `fortune_pools_en`,
            `neden_metinleri_en` (`cunku` dahil). İngilizce
            `tekrar_denetimi_en_test.dart` (eşikler TR ile aynı: benzersiz
            ≥ %55, aynı cümle ≤ 6, açılış dışı "Today" yok). Uçtan uca: 12 burç
            × 3 harita durumu (tam / yalnız Ay / hiçbiri) × 30 gün İngilizce
            okumada yer tutucu, Türkçe harf ya da çift boşluk kalmaz; "çünkü"
            satırı `ContentConfig` sınırını aşmaz.

      **Her E7 oturumunda:** altın kayıt testi yeşil kalır. Türkçe tek
      harf değişmez. Bir Türkçe cümle hatalı bulunursa ayrı oturumda,
      bilinçli olarak düzeltilir (bkz. altın kayıt başlığı).
- [ ] **E8 — İngilizce profil + rapor + yıllık rapor (content).**
      `sayi_metinleri_en`, `burc_metinleri_en`, `rapor_metinleri_en`,
      `yillik_rapor_metinleri_en`.
      **27 Kas: geçerli, küçük değişiklikle.** Profil okuması artık
      `profilMetniniUyarla(…, okuyucu.portre)` kullanıyor: İngilizce
      `profilUyarlamalari` E7c'deki çelişki ifadeleriyle aynı anahtarları
      kullanmalı (K7 (a) seçildi: tablo yalnız portre anahtarlarıyla). Ay adları
      (`ayAdlari`) E7a'da pakete taşınır; burada yeniden yapılmaz.
- [ ] **E9 — İngilizce araç + harita + uyum (content) ve yasal metin taslağı.**
      **27 Kas: geçerli.** İki not: (1) `harita_metinleri.dart` ile
      `kimlik_metinleri.dart` aynı portreyi anlatır; İngilizce harita
      metinleri E7c'deki `kimlik_metinleri_en` ile tutarlı yazılmalı.
      (2) Yasal metin 11 Kasım'da değişti: tanışma cevapları çıktı, doğum
      saati ve ili girdi. İngilizce taslak yeni metinden yazılır; önce
      Türkçe metin hukukçudan geçmeli (`reports/magaza_hazirligi.md`).
- [ ] **E10 — (Sonraya) Dünya geneli doğum yeri ve saat dilimi (luck_engine + storage + UI; 3 oturum).**
      **27 Kas: geçerli; önemi arttı.** 11 Kasım'dan beri "çünkü" satırı
      ve portre doğum haritasına dayanıyor. Türkiye dışında doğan biri
      ili boş bırakır (onboarding metni böyle diyor); yükselen ve portre
      gelmez, okuma daha az kişisel olur. Doğum Ay'ı Türkiye saat
      dilimiyle hesaplanıyor (yalnız "kesin" olduğunda kullanıldığı için
      hata payı küçük). İlk İngilizce yayından sonra ilk iş bu olmalı.
- [ ] **E11 — Mağaza:** İngilizce mağaza metni taslağı, ekran görüntüsü listesi,
      Play Console dil ekleme notları (kod yok; md dosyası).
      **27 Kas: geçerli.** K4'e ve Türkçe mağaza hazırlığına bağlı
      (`reports/magaza_hazirligi.md`, madde 11 ve 13). Ekran görüntüleri
      11 Kasım'daki yeni günlük ekrandan alınmalı.
- [ ] **E12 — Son kontrol:** İngilizce cihazda uçtan uca test listesi, taşma
      kontrolü, eksik çeviri taraması (ARB anahtarları eşit mi testi).
      **27 Kas: geçerli, listeye ekle:** "çünkü" kutusu ve "Bugünün
      alanları" satırlarında İngilizce taşma; kilitli satır önizlemesi;
      gün devri (gece yarısı açıkken dil İngilizce).

---

## 8. Hazır komutlar (yeni sohbete yapıştır)

**Ortak giriş (her oturumun başına):**

```
INGILIZCE_SURUM_PLANI.md ve CLAUDE.md dosyalarını oku. "Bozulmaması gereken
değişmezler" bölümüne uy. Sıradaki işaretlenmemiş oturumu yap, yalnızca o
oturumun kapsamında kal. Sonunda flutter analyze + flutter test çalıştır,
özet ver, plan dosyasında kutuyu işaretle. Commit'i ben isteyince at.
```

**E0:** `Ortak giriş + "E0'ı yap: K1–K6 kararlarını bana sor, cevapları dosyaya işle."`

**E1:** `Ortak giriş + "E1'i yap: Türkçe çıktılar için altın kayıt testlerini yaz; hiçbir lib dosyasına dokunma."`

**E2–E12:** `Ortak giriş + "E<n>'i yap."`

---

## 9. İngilizce içerik yazım rehberi

- Ton: ikinci tekil ("you"), sıcak, gündelik, mistik ama abartısız. Türkçe
  rehberin aynısı (`sayi_metinleri.dart` başındaki yorum).
- Gelecek kesin dille anlatılmaz: "may", "could", "is a good time to", "will" değil.
- Sağlık/para/hukuk yönlendirmesi yok; yasaklı ifade listesinin İngilizce
  karşılığı `ContentConfig`'e eklenir ("guaranteed", "definitely", "diagnosis",
  "invest in", "crypto", "stock", "death", "accident"…).
- Kelimesi kelimesine çeviri yapma; **aynı anlamı ve aynı uzunluğu** koru
  (D3 için sıra ve sayı aynı, içerik doğal İngilizce).
- Yer tutucular aynı adla kalır; `{gunIstegi}` ve `{doga}` İngilizcede
  "-ing" öbeğidir ("starting something new with courage").
- Numeroloji terimleri: Life Path, Expression (isim), Soul Urge (ruh),
  Personality (kişilik), Birthday, Maturity, Pinnacle, Challenge, Karmic Debt,
  Karmic Lesson, Hidden Passion, Cornerstone, Capstone, Balance, Personal Year/Month/Day.
- Burçlar: Aries, Taurus, Gemini, Cancer, Leo, Virgo, Libra, Scorpio,
  Sagittarius, Capricorn, Aquarius, Pisces; "Rising sign", "Moon sign", "Big Three".

---

## 10. Hızlı başvuru: önemli dosyalar

| Konu | Dosya |
|---|---|
| Proje anayasası | `CLAUDE.md` (Codex için `AGENTS.md`) |
| İlk geliştirme planı | `SANS_APP_GELISTIRME_PLANI.md` |
| Çizim listesi | `CIZIM_LISTESI.md` |
| Motor girişi | `lib/core/luck_engine/luck_engine.dart` (tüm export'lar) |
| Günlük okuma birleştirici | `lib/core/content/fortune_composer.dart` |
| İçerik sabitleri / eşikler | `lib/core/content/content_config.dart` |
| Tekrar denetimi | `test/content/tekrar_denetimi_test.dart` |
| Premium ve ürünler | `lib/features/premium/premium_config.dart`, `premium_kontrolcu.dart` |
| Test ortamı yardımcısı | `test/test_ortami.dart` |
