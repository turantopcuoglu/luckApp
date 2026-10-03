# İngilizce Sürüm Planı ve Devir Notu

> **Yeni sohbete başlarken:** Bu dosyayı ve `CLAUDE.md`'yi baştan sona oku.
> Sonra "Oturum sırası" bölümünde işaretlenmemiş ilk oturumu, "Hazır
> komut" metniyle başlat. Her oturum sonunda bu dosyadaki ilgili kutuyu
> `[x]` yap ve "Son durum" tablosunu güncelle.

---

## 1. Son durum (bu dosya yazıldığında)

| Bilgi | Değer |
|---|---|
| Tarih | 3 Ekim 2026 |
| Son commit | `b427a6e` Büyük Üçlü: doğum saati/ili, harita ekranı ve Yükselen girişi |
| Dal | `main` (her oturum doğrudan `main`'e commit edildi) |
| Testler | 347 test, tamamı yeşil (`flutter test`) |
| Analiz | `flutter analyze` → No issues found |
| Uygulama dili | Yalnızca Türkçe; tüm metinler Dart sabitleri, i18n altyapısı yok |

### Bu sohbette tamamlanan büyük işler (commit sırasıyla)

1. Metin denetimi: tekrar önleyici havuzlar + `tekrar_denetimi_test.dart`
2. Derin numeroloji motoru (zirveler, zorluklar, karmik sayılar…)
3. Numeroloji raporu metinleri + ekranı + tek seferlik satın alma (`kader_rapor_tam`)
4. Kişisel Yıl Raporu (içerik, ekran, ana ekran kartı, `kader_yil_2027` ürünü)
5. Keşfet sekmesi: isim analizi, numara analizi, bebek ismi + görsel paylaşım
6. Astronomi motoru (Meeus), 81 il, Türkiye saat dilimi geçmişi (IANA ile doğrulandı),
   Ay/Yükselen metinleri, Büyük Üçlü kartı ve doğum bilgisi girişi

### Geliştiricinin (Turan) bekleyen işleri

- [ ] Play Console: `kader_rapor_tam` ve `kader_yil_2027` tek seferlik ürünlerini aç.
- [ ] Emülatör kontrolü: yıl raporu kartı, 5 sekmeli alt menü, paylaşım görseli,
      doğum saati seçici, il otomatik tamamlama.
- [ ] Satışa açmadan önce hukuki danışmanlık (Türkiye'de 677 sayılı Kanun riski;
      konumlandırma "eğlence / kendini keşif", "fal" değil).
- [ ] İl koordinatlarını bir kez resmî kaynaktan kontrol et (±0.1° yazıldı).
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
6. **Ortam (Windows):** `python` yok. Çok satırlı düzenlemeler için scratchpad
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
| `features/daily_luck/tr_strings.dart` (tarih biçimi `tarihMetni` dahil) | 119 |
| `features/onboarding/onboarding_strings.dart` | 84 |
| `features/profile/profile_strings.dart` | 210 |
| `features/premium/premium_strings.dart` (+ `PremiumHatalari` in `premium_kontrolcu.dart`) | 143 |
| `features/tools/tools_strings.dart` | 115 |
| `features/settings/ayarlar_strings.dart` | 113 |
| `features/compatibility/uyum_strings.dart` | 69 |
| `features/feedback/feedback_strings.dart` (bildirim metinleri) | 38 |
| `features/share/share_strings.dart` | 17 |
| `features/categories/categories_strings.dart` | 11 |
| `features/home/ana_sekme.dart` (sekme etiketleri enum içinde) | — |
| `features/profile/tam_ad_duzenle.dart` (`TamAdStrings`) | — |
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
| `yorum_yonu.dart`, `karakter_yonleri.dart`, `kategori_durumlari.dart`, `kisisel_havuzlar.dart` | Günlük okuma (tekrar denetimine tabi) |
| `fortune_pools.dart`, `category_pools.dart`, `dongu_metinleri.dart`, `neden_metinleri.dart`, `sans_rengi.dart` | Günlük okuma yardımcıları |
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

## 5. Onay gerektiren kararlar (E0'da kullanıcıya sor)

| # | Karar | Önerilen |
|---|---|---|
| K1 | Arayüz metinleri için Flutter `gen-l10n` (ARB). `pubspec.yaml`'a `flutter_localizations` (sdk), `intl` ve `flutter: generate: true` eklenir. | Evet |
| K2 | İçerik dil paketleri için klasör düzeni: `lib/core/content/tr/` ve `lib/core/content/en/` (mevcut dosyalar `tr/` altına taşınır) **ya da** taşımadan `*_en.dart` ek dosyaları. | Taşıma yok: `*_en.dart` ek dosyaları (daha az kırılma riski, D4/D7 için güvenli) |
| K3 | Dil seçimi: cihaz dili `tr` ise Türkçe, değilse İngilizce; Ayarlar'dan elle değiştirilebilir. Seçim `UygulamaDurumu`'na yazılır. | Evet |
| K4 | İngilizce uygulama adı (mağaza ve launcher). | Kullanıcı karar verir (ör. "Kader: Numerology & Luck") |
| K5 | İngilizce yasal metinler (gizlilik, koşullar, sorumluluk reddi) kim tarafından yazılacak/onaylanacak? | Taslağı Claude yazar, hukukçu onaylar |
| K6 | Dünya geneli doğum yeri (E10): `timezone` paketi zaten var (tz verisi içerir); şehir veritabanı için GeoNames `cities15000` (CC BY 4.0, ~2 MB asset, atıf gerekir). | İlk yayında yok; sonra |

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

- [ ] **E0 — Kararlar.** K1–K6'yı kullanıcıya sor, cevapları bu dosyaya yaz. Kod yok.
- [ ] **E1 — Altın kayıt testleri (content).** Türkçe çıktıları sabitleyen
      testler: 12 yaşam yolu × 3 tercih × 10 gün `gunlukOkuma.kartMetni`,
      `raporOkumasi`, `yillikRaporOkumasi(2027)`, `profilOkumasi`, `uyumOkumasi`,
      `isimOkumasi`, `numaraOkumasi`, `haritaOkumasi` çıktılarının FNV özetleri
      tek bir test dosyasında. Sonraki her oturumda yeşil kalmalı (D7).
- [ ] **E2 — Etiketlerin içerik katmanına taşınması (content).** `IcerikDili`,
      `IcerikPaketi` arayüzü, `TrIcerikPaketi` (mevcut sabitlere yönlendirir),
      etiket tabloları. Birleştiricilere `paket` parametresi (varsayılan TR).
      E1 testleri yeşil.
- [ ] **E3 — i18n altyapısı (K1 onayı sonrası).** pubspec, `l10n.yaml`, boş
      ARB'ler, `MaterialApp` locale bağlantısı, `dilProvider` (K3), Ayarlar'da dil
      seçimi. Bu oturumda yalnızca `ana_sekme` ve `ayarlar` metinleri taşınır.
- [ ] **E4 — ARB taşıma: onboarding + legal ekranları (UI).** Yasal metin
      gövdesi hâlâ Türkçe kalabilir; E9'da yazılır.
- [ ] **E5 — ARB taşıma: daily_luck + categories + feedback + share.**
      `TrStrings.tarihMetni` → `intl` `DateFormat.yMMMMEEEEd(locale)`.
- [ ] **E6 — ARB taşıma: profile + premium + tools + compatibility.**
- [ ] **E7 — İngilizce günlük okuma (content).** `yorum_yonu_en.dart`,
      `karakter_yonleri_en.dart`, `kategori_durumlari_en.dart`,
      `kisisel_havuzlar_en.dart`, `fortune_pools_en.dart`, `dongu_metinleri_en.dart`,
      `neden_metinleri_en.dart`; D3 indeks hizası testi; İngilizce
      `tekrar_denetimi_en_test.dart` (eşikler TR ile aynı: benzersiz ≥ %55,
      aynı cümle ≤ 6, açılış dışı "Today" yok).
- [ ] **E8 — İngilizce profil + rapor + yıllık rapor (content).**
      `sayi_metinleri_en`, `burc_metinleri_en`, `rapor_metinleri_en`,
      `yillik_rapor_metinleri_en`.
- [ ] **E9 — İngilizce araç + harita + uyum (content) ve yasal metin taslağı.**
- [ ] **E10 — (Sonraya) Dünya geneli doğum yeri ve saat dilimi (luck_engine + storage + UI; 3 oturum).**
- [ ] **E11 — Mağaza:** İngilizce mağaza metni taslağı, ekran görüntüsü listesi,
      Play Console dil ekleme notları (kod yok; md dosyası).
- [ ] **E12 — Son kontrol:** İngilizce cihazda uçtan uca test listesi, taşma
      kontrolü, eksik çeviri taraması (ARB anahtarları eşit mi testi).

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
