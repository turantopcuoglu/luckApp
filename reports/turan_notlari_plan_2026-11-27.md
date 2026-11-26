# Turan'ın 26 Kasım notları: plan, iş listesi, sorular

Kaynak: `STUDIO/toplantilar/2026-11-26_luckapp_notlari.md`. Notlar K7 ve K8'i kapatıyor ve İngilizceyi tam kapsam yapıyor.
Bu belge yalnız plan. Kod değişmedi; uygulamaya Turan'ın onayıyla geçilecek. Dal: `gece/2026-11-27`.

Her başlıkta önce bulgu (kanıtla), sonra iş listesi, en sonda sorular var. Sıra ve süre tahmini sonda.

---

## 1. Saat dilimi ve doğum yeri (K8: konuma göre)

### 1.1 Astroloji pratiği (doğrulandı)

Yöneticinin özeti doğru. Kaynaklar:
- **Doğum haritası.** Doğum yerinin o tarihteki saat dilimi ve yaz saati kuralıyla yerel saat UT'ye çevrilir. Yükselen ve evler doğum yerinin enlem ve boylamıyla hesaplanır. Astrodienst bunu "dünya geneli ve tarih boyunca saat dilimi ve yaz saati veritabanı" ile otomatik yapıyor ([astro.com SSS](https://www.astro.com/cgi/xa.cgi/faq/fq_de_timezone_e.htm), [atlas](https://www.astro.com/atlas)). Yükselen yaklaşık 4 dakikada 1 derece kayar; saat diliminde bir saatlik hata yükseleni genellikle değiştirir ([astro.com SSS](https://www.astro.com/cgi/xa.cgi/faq/fq_de_time_e.htm)).
- **Ay evresi ve gökyüzü olayları.** Dünyanın her yerinde aynı an. "Bugün"ün sınırı kişinin bulunduğu yerin saati. Uygulamada gün zaten cihaz saatiyle başlıyor (`bugunProvider`, `GunDevri`).
- **Uyarı.** Astrodienst'e göre herkese açık IANA tz veritabanı, 1970 öncesinde bölgeyi adlandıran şehrin dışında güvenilmez. ABD ve Kanada'da yaz saatini 1967'ye kadar yerel yönetimler belirliyordu. Örneğin Illinois'de 1959'a kadar nüfus kayıtları yaz saatinde bile CST yazıyordu ([atlas](https://www.astro.com/atlas)). Yani dünya geneli 1970 öncesi doğumlarda saat dilimi "tahmin"dir.
- **Kaynak kullanımı.** Astrodienst atlası yazılımla sorgulanamaz; koşulları otomatik veri çekmeyi yasaklıyor ([atlas](https://www.astro.com/atlas)). Bu yüzden test referansı olarak atlas taranmaz, yayımlanmış haritalar kullanılır (1.5).

### 1.2 Bugün kodda ne var

| Hesap | Bugün | Konuma göre mi? |
|---|---|---|
| Doğum Ay'ı ve yükselen | `TurkiyeSaatDilimi` (Türkiye'ye özel geçmiş, IANA ile doğrulanmış) + 81 il koordinatı | Yalnız Türkiye |
| Günün Ay burcu | `Astronomi.gununAyBurcu`: sabit 09:00 UTC (`EngineConfig.gununAyBurcuUtcSaati`) | Hayır, herkese aynı an |
| Günün Ay evresi | `ayEvresiOrani`: yerel gece yarısı → `toUtc()` (`ay_evresi.dart:64`) | Evet, ama örtük: cihazın saat dilimini sessizce okuyor; test makineye bağlı |
| "Bugün" sınırı | Cihaz saati | Evet |

İki gökyüzü hesabı birbirinden farklı kurala uyuyor. Ay evresi testi makinenin saat dilimine bağlı: altın kayıt +07'de üretilmiş, İstanbul saatinde 3 test kırılıyor (gece raporu).

### 1.3 Önerilen kural

- **Doğum haritası:** doğum yerinin tarihsel saat dilimi. Türkiye doğumlarında bugünkü `TurkiyeSaatDilimi` aynen kalır; Türkiye testleri değişmez. Diğer ülkelerde IANA (`timezone` paketi, zaten bağımlılık).
- **Günün gökyüzü:** kişinin yerel takvim günü. Bu gün, cihazın o günkü UTC farkıyla **açık parametre** olarak motora verilir; motor makinenin saatini okumaz.
  - Ay evresi: yerel gece yarısında.
  - Ay burcu: yerel öğlende.
  - Türkiye (+03) için ikisi de bugünküyle birebir aynı: yerel öğlen 09:00 UTC'ye denk geliyor. **Türkiye'deki kullanıcının skoru ve metni değişmez.**
- **Testler** UTC farkını açıkça verir (+03). Altın tablo bir kez İstanbul değerleriyle yeniden üretilir. Bu değerler eski kodun İstanbul'daki çıktısıyla aynı olmalı; deneyle kontrol edilir. Sonra her makinede yeşil kalır.
- **Kural 8'in metni değişir.** Şu an "aynı (kullanıcı, gün) her zaman aynı sonuç" diyor. Yeni hâli: "aynı (kullanıcı, yerel gün, UTC farkı)". Seyahat eden kullanıcı o gün başka bir Ay evresi görebilir; konuma göre olmanın doğal sonucu. `CLAUDE.md` anayasa olduğu için bu cümleyi Turan değiştirir ya da onaylar (Soru 1).

### 1.4 Şehir verisi: lisans ve boyut

| Seçenek | İçerik | Lisans | Boyut | Not |
|---|---|---|---|---|
| **GeoNames `cities15000`** (öneri) | Nüfusu 15 binin üstündeki şehirler ve başkentler, yaklaşık 25 bin kayıt; koordinat ve **IANA saat dilimi kimliği** var | CC BY 4.0, ticari kullanım serbest, atıf zorunlu ([GeoNames export](https://geonames.org/export/), [readme](https://android.googlesource.com/platform/external/geonames/+/7a853d30915d91f323de5649b130afbd00e609de/export/dump/readme.txt)) | Ham zip yaklaşık 2,35 MB (eski bir kopya). Ad, ülke, enlem, boylam ve tz'ye kırpılırsa tahminen 0,8–1,2 MB asset | Önerim bu. Küçük kasabalar yok; kişi en yakın şehri seçer |
| GeoNames `cities5000` / `cities1000` | Yaklaşık 50 bin / 140 bin kayıt | Aynı | 2–6 kat büyük | Gerekmiyor |
| Natural Earth "populated places" | Yaklaşık 7 bin yer | Kamu malı | Çok küçük | Saat dilimi kimliği yok; eşleştirme ayrı iş. Kapsamı dar |

- **Atıf.** Ayarlar > Hakkında / Lisanslar'a "Şehir verisi: GeoNames (geonames.org), CC BY 4.0" yazılır. Flutter `LicenseRegistry` ile lisans sayfasına da eklenir. Mağaza açıklamasında gerekmez. Değişiklik yapıldıysa (kırpma), bu da belirtilir.
- **Şehir adının dili.** GeoNames'te ad ve ASCII ad var ("München" / "Munchen"). Türkçe ve İngilizce adlar ("Münih" / "Munich") için `alternateNames` dosyası gerekir; o çok büyük. Öneri: aramada ad + ASCII ad + elle yazılmış küçük bir eş anlamlı listesi (Türklerin en çok doğduğu yurt dışı şehirler: Almanya, Hollanda, Fransa ve Avusturya'daki büyük şehirler). Türkiye şehirlerinde bugünkü 81 il adı kalır.
- **Ülke adları** iki dilde gerekir (yaklaşık 250). GeoNames `countryInfo.txt` yalnız İngilizce veriyor. Türkçe adlar için Unicode CLDR verisi (izinli lisans) tek dosya olarak eklenir. Dart `intl` paketi ülke adı vermiyor.
- **Saat dilimi verisi:** `timezone` paketinin `latest_all` verisi (`.tzf` yaklaşık 444 KB). Bildirimler şu an `latest` (yaklaşık 327 KB) kullanıyor. İkisinin birden pakete girmemesi için bildirimler de `latest_all`'a geçirilir. Net ek tahminen +120 KB.
- **Uygulama boyutuna etki (tahmin):** APK/AAB'de yaklaşık +1–1,5 MB (şehir asset'i + tz farkı). Ölçüm, uygulama oturumunda release AAB ile yapılır.
- **Paket.** Yeni pub paketi gerekmiyor (`timezone` var; JSON `dart:convert` ile okunur). Asset eklemek için `pubspec.yaml` `assets:` satırı ve yeni bir asset klasörü gerekiyor; ikisi de `CLAUDE.md` gereği onay ister (Soru 2).

### 1.5 Var olan kullanıcıların verisi

- Bugünkü kayıt: `dogumIliPlaka` (int, 1–81) ve `dogumSaatiDakika`.
- Yeni kayıt: `dogumUlkeKodu` (ISO, ör. `TR`), `dogumSehirKimligi` (GeoNames kimliği), `dogumSaatDilimi` (IANA, ör. `Europe/Istanbul`), enlem ve boylam. Koordinat kayda da yazılır; asset değişse bile harita değişmez.
- Göç: okurken `dogumIliPlaka` varsa `TR` + o ilin kaydı + `Europe/Istanbul` kurulur. Hesap Türkiye doğumunda yine `TurkiyeSaatDilimi` ile yapılır; sonuç birebir aynı kalır. Eski anahtar silinmez (geri dönüş güvenli). `storage_v2_test` tarzı bir göç testi yazılır.
- 81 il koordinatı (±0.1°) mı, GeoNames koordinatı mı? Türkiye için **bugünkü il listesi kalır**. Değişirse sınırdaki yükselenler kayar ve altın kayıt bozulur.

### 1.6 Yabancı doğum testleri

- **Doğrulanacak:** New York 1985 yaz saati (EDT, UTC−4), Londra (yaz saati ve 1968–71 İngiliz standart saati gibi bir istisna), Tokyo (yaz saati yok, UTC+9).
- **Referans:** her biri için Astro-Databank'ta AA dereceli (doğum belgesinden) yayımlanmış bir harita. Yükselen burcu ve derecesi kaynağıyla test yorumuna yazılır. Kabul ölçütü: yükselen burcu aynı, derece farkı ≤ 1°.
- **Kişi seçimi:** uygulama oturumunda kaynağa bakılarak yapılır. Burada isim ve değer uydurmuyorum.
- **Ayrıca:** var olmayan saat (yaz saati geçişinde atlanan saat) ve iki kez yaşanan saat için davranış testi yazılır. Astrodienst bu durumda uyarı veriyor.

### 1.7 İş listesi (K8)

*26 Kas notu:* K8-1 bitti. Tablo yeniden üretilmeden geçiyor. İstanbul'daki 3 kırık testin nedeni ay evresi değil, test fikstürünün yaz saati hatasıydı (bkz. `reports/11_kasim_icerik_yeniden_yazimi.md` §5 sonu).

| # | İş | Sistem | Kim |
|---|---|---|---|
| 1 | Motor: "günün gökyüzü" açık UTC farkı alsın (Ay evresi yerel gece yarısı, Ay burcu yerel öğlen); `toUtc()` kalksın; birim testleri. Altın tabloyu +03 ile bir kez üret, eski kodun İstanbul çıktısıyla karşılaştır | `luck_engine` | Claude |
| 2 | Dünya geneli doğum saat dilimi: IANA çevirici (`timezone`), Türkiye için `TurkiyeSaatDilimi` önceliği, atlanan ve çift saat davranışı, yabancı yükselen testleri | `luck_engine` | Claude |
| 3 | Şehir verisi hazırlama betiği (GeoNames'ten kırpma, CLDR ülke adları), asset ve atıf | araç + asset | Claude (dosyayı Turan indirir; bu gece paket ve dosya indirme yasaktı) |
| 4 | Kayıt göçü: il → ülke + şehir + tz; göç testi | `storage` | Claude |
| 5 | Arayüz: ülke seçici + şehir araması (onboarding ve profil), "Türkiye dışında doğduysan boş bırak" metni kalkar, atıf satırı | `features/onboarding`, `features/profile` | Claude; görsel kontrol Turan (emülatör) |
| 6 | `CLAUDE.md` kural 8 cümlesi | anayasa | Turan |

Bu, plandaki **E10**'un yerine geçer ve öne alınır: artık "sonraya" değil, İngilizce yayından önce yapılacak.

---

## 2. Tanışma soruları kalkıyor (K7: hayır)

### 2.1 Bulgu

Sorular 11 Kasım'da onboarding'den ve Ayarlar'dan kaldırıldı; kayıt da artık cevap tutmuyor (`UserProfile.okuyucu` `tercihler` vermiyor). Ama içerik katmanı cevaba göre dallanan kodu ve metni hâlâ taşıyor. Üretimde bunlara hiç ulaşılmıyor; yalnız testler (`altin_kayit` t1/t2 setleri, `celiski_kapisi` 36 kombinasyon) çalıştırıyor.

### 2.2 Cevap kullanan yolların tam listesi (`lib/`, 27 Kas)

| # | Yer | Ne yapıyor | Karar |
|---|---|---|---|
| 1 | `okuyucu.dart`: `OkuyucuTercihleri`, `EnerjiTarzi`, `KararTarzi`, `IliskiDurumu`, `Ugras` | Cevap tipleri | `EnerjiTarzi` ve `KararTarzi` **kalır**, çünkü `Okuyucu.portre` bunları Güneş elementinden türetiyor (doğum verisi). `IliskiDurumu`, `Ugras` ve `OkuyucuTercihleri` alanı **silinir** |
| 2 | `Okuyucu.portre` | Cevap yoksa element | Yalnız elementten kurulur (`tercihler ??` dalı gider) |
| 3 | `fortune_composer.dart:73`, `slot_doldurucu.dart` `{ugrasAlani}`, `kisisel_havuzlar.dart:23` | "{ugrasAlani} için tek bir önceliği netleştir" | Yer tutucu kalkar, cümle genel öbekle yeniden yazılır ("işlerin için") |
| 4 | `fortune_composer.dart:394–405`, `GokyuzuMetinleri.sahneAnahtari` | Kategori sahnesi: Aşk'ta bekâr/partnerli, diğerlerinde uğraşa göre | Yalnız `genel` sahneler kalır; diğer anahtarların cümleleri silinir |
| 5 | `fortune_composer.dart:415–443`, `GokyuzuMetinleri.kisiselAnahtar`, `kisiselYap` (`gokyuzu_metinleri.dart:1135`–) | Cevaba göre bir "Yap" önerisi | Silinir (yalnız genel Yap listesi kalır) |
| 6 | `fortune_composer.dart:586`, `YorumYonu.gunSahneleri[k][ugras]` | Günlük sahne uğraşa göre | Yalnız `genel` kalır |
| 7 | `fortune_composer.dart:753–763`, `KisiselHavuzlar.enerjiTavsiyeleri` | Günün tavsiyesi enerji cevabına göre | **Doğum verisine bağlanır:** `portre.enerji` (element). Türkiye çıktısı değişir (bugün herkes `-` dalında) → Soru 3 |
| 8 | `fortune_composer.dart:980–1028`, `KisiselHavuzlar.profilIliskiEki`, `profilUgrasEki` | Kader Profili'nde ilişki ve uğraş ekleri | Silinir |
| 9 | `KisilikMetinleri.celiskiAnahtarlari` + `ContentConfig.celiskiIfadeleri['bekar'/'partnerli']` | İlişki bilinmiyorsa iki varsayımı da eler | Kural kalır (ilişki hep bilinmiyor). İlişki varsayan cümleler zaten hiç seçilmiyor; havuzlardan **silinir**. Böylece kapı yalnız enerji ve karar için çalışır |
| 10 | `KisilikMetinleri.profilUyarlamalari` | Cevaba göre profil cümlesi uyarlama | Yalnız `disaDonuk`/`iceDonuk`/`kalp`/`akil` (element) anahtarları kalır |
| 11 | `IcerikPaketi`/`TrIcerikPaketi`: `enerjiTarziAdi`, `kararTarziAdi`, `iliskiDurumuAdi`, `ugrasAdi`, `ugrasAlani` | Soru seçeneklerinin adları | Silinir (İngilizceye çevrilmez) |
| 12 | `legal_texts.dart:30` (`uyariMaddeleri`) | "Adın, doğum tarihin **ve verdiğin cevaplar**…" | **Eskimiş metin**, düzeltilir. Uyarı değişirse `uyariSurumu` artar (hukukçu sonrası) |
| 13 | Testler: `altin_kayit`, `celiski_kapisi`, `fortune_composer`, `gokyuzu_metinleri`, `icerik_paketi`, `kimlik_metinleri`, `storage_v2`, `tekrar_denetimi` | Cevap setleriyle çalışan testler | Cevap setleri yerine 12 burç × 3 harita durumu |

Eski kayıtlardaki `enerji`, `karar`, `iliski` ve `ugras` Hive anahtarları okunmuyor. İstenirse açılışta bir kez silinir (KVKK açısından temiz; Soru 4).

### 2.3 Etkisi

- Türkçe kullanıcının bugünkü çıktısı 1–6 ve 8–11'de **değişmez**, çünkü bu dallar üretimde hiç çalışmıyor. Yalnız 7 (tavsiye) değişir; ona Turan karar verir.
- Altın kayıtta yalnız t1/t2 anahtarları kalkar. t0 anahtarları üretimin aynısı; değişmemeli. Bu, kanıt olarak kullanılır.
- E7 küçülür: E7b'den `kisiselYap` ve tercih sahneleri, E7c'den ilişki ifadeleri çıkar. Kabaca %15 daha az çeviri.

### 2.4 İş listesi (K7)

| # | İş | Sistem | Kim |
|---|---|---|---|
| 1 | 2.2'deki 1–6 ve 8–11'i kaldır; t0 altın anahtarları değişmesin | `content` | Claude |
| 2 | 7. maddeyi Soru 3'ün cevabına göre uygula | `content` | Claude |
| 3 | `uyariMaddeleri` metni (12) | `features/legal` | Claude (metin), hukukçu (onay) |
| 4 | `INGILIZCE_SURUM_PLANI.md`: K7 "kapandı: hayır"; E7b ve E7c kapsamı küçülür | belge | Claude |

**Durum (26 Kas gece):** 1–4 yapıldı. 1: `9436741` (t0 çıktısı aynı, 43 680 anahtar). 2: `0530549` (tavsiye kişi-günlerin %97'sinde değişir; altın kayıtta 48 anahtar). Ek: eski cevaplar açılışta silinir `177a547`. 3: `7e1bbf1`, `uyariSurumu` artırılmadı (hukukçu/Turan). İçerik açıkları ve kanıt: `reports/k7_kanit/README.md`.

---

## 3. İngilizce tam kapsam

### 3.1 İngilizce adlar ve numeroloji

`numeroloji.dart` incelendi:

| Durum | Bugün | Sorun |
|---|---|---|
| İngilizce harfler (q, w, x dahil) | Pitagor tablosu a–z (`_tabloKur`) | Yok |
| Türkçe harfler | ç ğ ı ö ş ü â î û Latin karşılığının değerini alır | Yok (D6) |
| **Başka aksanlı Latin harfler** (é è ë á à ñ ä å ø æ ß ł …) | `harfDegeri` null döner, harf **sessizce atlanır** | **Hata.** "José", "Zoë", "Renée", "Søren", "Łukasz" ve "Müller" dışındaki Almanca adlar yanlış sayı alır. Düzeltme: ayrıştırma tablosu (é→e, ñ→n, ø→o, ß→ss, æ→ae, ł→l …) |
| Latin dışı yazı (Kiril, Yunan, Arap, CJK) | Atlanır; harf kalmazsa sayı null | Arayüz bunu "tam adını Latin harfleriyle yaz" diye söylemeli |
| Büyük I | Türkçe kurala göre `ı` olur | Değer aynı (9), sesli sayılıyor. Sorun yok |
| İki ya da daha çok kelimeli ad, tire, kesme ("Mary-Jane O'Neil") | Boşluk, tire ve kesme atlanır, harfler toplanır | Yok |
| Hitap adı | Tam adın ilk kelimesi | Batı adlarında doğru. "Dr. …" gibi unvanlarda yanlış; ipucu metniyle çözülür |
| **Y harfi** | Hep sessiz (D6, iki dilde aynı) | İngilizce numerolojide yaygın kural: Y, sesli gibi okunduğunda sesli sayılır ("Lynn", "Mary"). Ruh ve kişilik sayılarını değiştirir → Soru 5 |
| Skor tohumu (D5) | `isim.trim().toLowerCase()` SHA-256 | Dilden bağımsız. Sorun yok |
| İyelik ("Ayşe'nin" / "Mary's") | Yalnız Türkçe paket var | E7a'da İngilizce paketle gelir |

Test eklenecek: aksanlı adlar, tamamen Latin dışı ad, tireli ve kesmeli ad, Türkçe adın İngilizce arayüzde aynı sayıyı vermesi (D6).

**Durum (27 Kas):** aksanlı harfler ve Y kuralı yapıldı.
- Tek harfli aksanlılar Latin karşılığının değerini ve sesli/sessiz durumunu alıyor. Kapsam: Latin-1 Ek, Latin Genişletilmiş-A ve Rumence ș/ț.
- Bitişik harfler her harfi ayrı sayıyor: ß→ss, æ→ae, œ→oe, þ→th, ĳ→ij. Bu kural isim, ruh ve kişilik sayısında; sayı dağılımında, karmik derslerde, temel/tepe taşında ve denge sayısında; numara analizinde geçerli.
- Y iki dilde de sessiz (soru 5, karar (a)); kuralı bir test sabitliyor.
- Eski hâl: "José" isim 8, "Søren" 2, "Straße" 9 alıyordu. Yeni hâl: 4, 8, 2; aksansız yazılışlarıyla aynı.
- Türkçe adlar değişmedi; altın kayıt tablosu dokunulmadan geçti (Europe/Istanbul ve UTC).

### 3.2 Eksik listesi (İngilizce yayın bayrağından önce kapanmalı)

`DilConfig.ingilizceYayinda` şu an `false`. Aşağıdakilerin hepsi kapanmadan açılmaz.

| # | Alan | Durum (27 Kas) | Kapatan iş |
|---|---|---|---|
| 1 | Arayüz metinleri (ARB) | **Tamam**: 354/354 anahtar iki dilde | E12'de taşma kontrolü |
| 2 | Günlük okuma içeriği | Yok (yaklaşık 18 bin kelime) | E7a–E7e |
| 3 | Kader Profili, numeroloji raporu, yıllık rapor | Yok | E8 |
| 4 | Araçlar (isim, numara, bebek ismi), doğum haritası, uyum | Yok | E9 |
| 5 | Birleştiricilerdeki satır içi Türkçe (`'Özün · …'`, `'… burcu · …'`, `'Birlikte'`, `'Tavsiye'`) | Türkçe | E8 (E2 notu) |
| 6 | Ekranlarda motor `etiket` okumaları | 28 yer (`.etiket`/`.alan`); ör. `uyum_screen.dart:169` | E8–E9 sırasında paket üzerinden |
| 7 | Ekranda elle yazılmış Türkçe | `kader_profili_screen.dart:349` ("doğanda … var"), `kayitli_kisi.dart` rol etiketleri ("Hoşlandığım biri", "Arkadaşım") | Yeni küçük ARB işi (E6c) |
| 8 | Yasal metin gövdeleri, `LegalConfig.sonGuncelleme` ("11 Kasım 2026" düz metin) | Türkçe | E9 + hukukçu (K5) |
| 9 | Paylaşım görselleri | Çerçeve ARB'den geliyor; görseldeki okuma metni içerik katmanından, Türkçe | E7–E9 bitince kendiliğinden; E12'de görsel kontrol |
| 10 | Bildirimler | ARB'de tamam. Dil değişince yeniden planlanmıyor (E5 notu) | E12 |
| 11 | Tarih biçimi | ARB desenleri tamam (`tarihMetni`). İçerikteki tarih ("14 Mart doğumlusun") Türkçe ay adıyla | E7a (ay adları pakete) |
| 12 | **Fiyat biçimi** | `paywall_screen.dart:411–418` aylık karşılığı elle biçimliyor: metinde virgül varsa ondalığı virgül sayıyor. "$1,299.99" gibi binlik ayırıcılı fiyatta yanlış sonuç verir | Mağazanın para birimi koduyla `NumberFormat.simpleCurrency(locale)`. Küçük `features/premium` işi |
| 13 | Doğum yeri | Yalnız Türkiye illeri | Başlık 1 (E10 öne alındı) |
| 14 | Numeroloji: aksanlı adlar, Y kuralı | 3.1 | Küçük `luck_engine` işi + Soru 5 |
| 15 | Uygulama adı ve mağaza metni | "Kader"; K4 açık; İngilizce mağaza metni yok | K4 + E11 |
| 16 | Yasaklı ifade listesi (sağlık, para, kesinlik) | Yalnız Türkçe (`ContentConfig`) | E7a (§9'daki İngilizce liste) |
| 17 | Türkiye'ye özgü içerik | Bayram ve sınav dönemi gibi takvim kancaları varsa | E7'de taranır |

### 3.3 İş listesi (İngilizce)

Plandaki E7–E12 sırası geçerli. Değişenler:
- E10 öne alındı (başlık 1).
- K7 temizliği E7'den önce yapılır.
- İki küçük iş eklendi: **E6c** (madde 7: ekrandaki elle yazılmış Türkçe, rol etiketleri) ve **E6d** (madde 12: fiyat biçimi).
- Numeroloji düzeltmesi (madde 14) ayrı küçük bir `luck_engine` oturumu.

---

## Sıra ve tahmin

Her satır bir oturum (`CLAUDE.md` kural 1: tek sistem).

| Sıra | Oturum | Bağlı olduğu |
|---|---|---|
| 1 | K8-1: motor, açık UTC farkı + altın tablo (+03) | Soru 1 |
| 2 | K7-1/2: tanışma kalıntılarının temizliği (content) **— bitti** | Soru 3 |
| 3 | Numeroloji: aksanlı harfler (+ Y kuralı) **— bitti** | Soru 5 |
| 4 | K8-2: dünya geneli doğum saat dilimi + yabancı yükselen testleri | 1 |
| 5 | K8-3/4: şehir verisi + kayıt göçü | Soru 2; Turan GeoNames dosyasını indirir |
| 6 | K8-5: ülke/şehir arayüzü | 5; görsel kontrol Turan |
| 7 | E6c, E6d: kalan Türkçe arayüz ve fiyat biçimi | — |
| 8 | E7a–E7e: İngilizce günlük okuma | 1, 2 |
| 9 | E8, E9: profil, rapor, araçlar, harita, uyum, yasal taslak | 8; K5 |
| 10 | E11, E12: mağaza ve son kontrol; ardından `ingilizceYayinda = true` | K4; tüm eksikler |

Kabaca 18–22 oturum. E7, E8 ve E9 çeviri ağırlıklı olduğu için en uzunları.

## Turan'a sorular

1. **Kural 8.** "Aynı (kullanıcı, gün)" yerine "aynı (kullanıcı, yerel gün, UTC farkı)" yazılsın mı? Türkiye'deki kullanıcının sonucu değişmiyor; yalnız yurt dışında olan ya da seyahat eden etkileniyor. `CLAUDE.md`'yi sen değiştir ya da onayla.
2. **Şehir verisi.** GeoNames `cities15000` (CC BY 4.0, atıf Ayarlar > Hakkında'da) ve `assets/` altına yaklaşık 1 MB veri. Onaylıyor musun? Ham dosyayı geonames.org'dan sen indirirsin (`cities15000.zip`, `countryInfo.txt`); ben kırpma betiğini yazarım.
3. **Günün tavsiyesi.** Bugün herkes cevapsız (genel) dalda. Elementten türeyen enerjiye (içe/dışa dönük) bağlansın mı? Bağlanırsa Türkiye'deki kullanıcıların tavsiye cümlesi değişir. Önerim evet: "doğum verisinden üret" kararına uyar.
4. **Eski cevaplar.** Eski kullanıcıların telefonunda duran tanışma cevapları açılışta bir kez silinsin mi? Önerim evet (gereksiz kişisel veri).
5. **Y harfi.** İngilizce adlarda Y, sesli gibi okunduğunda sesli sayılsın mı? (a) Hayır, iki dilde aynı kural (D6, basit). (b) Evet, İngilizce numeroloji geleneği; aynı ad iki dilde farklı ruh sayısı verebilir. Önerim (a): kural bir kez açıklanır, ad dilden bağımsız kalır.
6. **K4 (İngilizce ad).** "İngilizce ad desteklenmeli" notunu iki türlü okudum: (1) İngilizce isimlerin numerolojide doğru hesaplanması, (2) uygulamanın İngilizce adı. (1) başlık 3.1'de. (2) için karar hâlâ gerekli: "Kader" adı kalıp alt başlık mı eklensin ("Kader: Numerology & Moon"), yoksa ayrı bir İngilizce ad mı olsun?
