# 11 Kasım 2026 işi: içerik yeniden yazımı ve E6b

Bu iş 11 Kasım'da yapıldı ve belgelenmeden, commit'lenmeden kaldı. 27 Kasım gecesi `gece/2026-11-27` dalına olduğu gibi kaydedildi (`2bbbe9d`). Bu belge kodu ve testleri okuyarak yazıldı. Yazarın kendi notu yok; "neden" kısımları kod yorumlarından ve araştırma raporundan alındı.

- Kaynak araştırma: `reports/Kişiye yakın yorum nasıl yazılır.md`, ham notlar `research_notes/Kişiye yakın yorum nasıl yazılır/` (4 dosya, 11 Kasım 20:49–20:55).
- Kapsam: 60 dosya, +5669 / −2525 satır. Raporlar ve testler dahil.
- Doğrulama (27 Kas): `flutter analyze` sorunsuz. `flutter test` 488/488 yeşil. Altın kayıt saat dilimine bağlı (§5).

## 1. Ne değişti, neden (tek paragraf)

Test kullanıcıları okumalar için "çoğu benimle ilgisiz, bazı kısımlar benziyor" demişti. Araştırma raporu bunun üç nedenini buldu: aynı okumada üç kez geçen Ay cümlesi, Güneş burcu ile yaşam yolunun birbiriyle çelişen portreleri ve onboarding cevaplarıyla çelişen cümleler. Rapor şu sırayı öneriyordu: önce çelişkiyi imkânsız yap, okumada her olgu bir kez geçsin, hesaplamayı tek satırlık bir "çünkü" ile görünür kıl. 11 Kasım işi bu üç maddeyi uyguladı. Yanında iki iş daha var: E6b (koleksiyon metinlerinin ARB'ye taşınması) ve gün devri hatasının düzeltilmesi. Raporun 3. önerisi "kullanıcının beyanlarını metne geri yansıt" idi. 11 Kasım işi bunun **tersini** yaptı ve tanışma sorularını kaldırdı. Gerekçe kod yorumunda yazıyor: kullanıcıda "bana sordu, şimdi cevabımı bana satıyor" hissi. Bu bir ürün kararıdır ve Turan'ın onayını bekliyor (plan dosyasında K7).

## 2. Değişiklikler, kullanıcının göreceği farkla

| # | Değişiklik | Kullanıcı ne görür | Kod |
|---|---|---|---|
| 1 | **"Çünkü" satırı**: okumanın başında, okumanın hangi veriye dayandığını söyleyen tek satır | Okuma kartının en üstünde altın zeminli kutu: "Sana özel, çünkü 14 Mart doğumlusun: burcun Balık (su), Ay burcun Terazi, yükselenin Boğa. Ay da bugün bir su burcunda." | `NedenMetinleri.cunku`, `GunlukOkuma.cunku`, `comment_card.dart` |
| 2 | **Ay bir kez anılır**: kategori paragrafları gökyüzü cümlesinin Ay'ı anan ilk yarısını atar (`ayOnekisizHali`) | Eskiden bir okumada "Ay senin elementinde (Yengeç)" üç kez geçiyordu, artık yalnız açılışta geçiyor | `fortune_composer.dart` `ayOnekisizHali`, `ContentConfig.gokyuzuAyraci` |
| 3 | **Tek ses**: bir gün ya burç ya yaşam yolu konuşur. Sayının konuşmadığı günde, harita biliniyorsa yükselen × Ay portresi gelir | Gün aşırı "Yükselenin Boğa seni acele etmeyen, huzur veren biri gibi gösterir; Ay burcun Terazi ise içeride başka konuşur: …" | `kimlik_metinleri.dart` (yeni), `ContentConfig.kisilikDonusumu` |
| 4 | **Çelişki kapısı**: her metin havuzu seçimden önce kişinin "çekirdek portresi"yle çelişen cümlelerden temizlenir. Portre, cevap yoksa Güneş burcunun elementinden türetilir (ateş/hava dışa dönük, toprak/su içe dönük vb.) | İçe dönük bir burca "kalabalıkta parla" denmez. İlişki durumu bilinmeyene "partnerin" de "flört" da denmez | `Okuyucu.portre`, `KisilikMetinleri.uyumlular`, `_kapi` |
| 5 | **Tanışma soruları kaldırıldı** (enerji, karar, ilişki, uğraş). Onboarding tek veri adımı: tam ad, doğum tarihi, isteğe bağlı doğum saati ve ili. Hitap adı tam adın ilk kelimesi | Onboarding'de "Seni biraz tanıyalım" ekranı yok. Ayarlar'daki "Tanışma cevapların" satırı yok. Form "Kaderimi hesapla" düğmesiyle bitiyor | `tanisma_screen.dart` silindi, `profile_form_screen.dart`, `user_profile.dart` |
| 6 | **Doğum haritası okumaya bağlandı**: profil, haritadan Ay ve yükselen burcu yalnız kesin olduklarında okuyucuya verir | Doğum saati ve yeri girenin okumasında Ay/yükselen geçer; girmeyende geçmez, yanlış burç söylenmez | `UserProfile.okuyucu`, `dogumHaritasi` |
| 7 | **Gün devri**: uygulama bellekte açık kalıp ertesi gün öne gelince ya da gece yarısı ekrandayken yeni güne geçer. Akşam kartı saatini de ayrıca izler | Eskiden uygulamayı kapatmayan kullanıcı ertesi sabah dünün kartını görüyordu | `gun_devri_gozcusu.dart` (yeni), `daily_luck_providers.dart`, `main.dart` |
| 8 | **Günlük ekran düzeni**: okuma bölümlere ayrıldı ("Günün enerjisi", "Öne çıkan · Aşk", "Dikkat · Risk"; her kategori bölümünde "okumanın tamamı" bağlantısı). Beş küçük karonun yerine tam genişlikte "Bugünün alanları" satırları geldi (glif, kısa başlık, skor çubuğu, "Günün yıldızı" rozeti). Kilitli satır günün başlığını önizleme olarak gösteriyor, skoru gizliyor. Skor kartında okunurluk için opak madalyon ve başlık gölgesi var | Ana ekran görsel olarak değişti | `daily_luck_screen.dart`, `category_card.dart`, `comment_card.dart`, `gunun_puani.dart`, `kilit_secenekleri.dart` |
| 9 | **E6b**: koleksiyon metinleri ARB'ye taşındı (12 arayüz anahtarı + 24 kart × ad/söz) | Türkçe metin aynı (testle korunuyor) | `koleksiyon_strings.dart` silindi, `app_tr.arb`, `app_en.arb` |
| 10 | **Yasal metin**: gizlilik metni yeni veriyi anlatıyor (tanışma cevapları çıktı; doğum saati ve il girdi). `sonGuncelleme` 11 Kasım 2026 | Gizlilik politikası metni değişti | `legal_texts.dart`, `legal_config.dart` |

**Görsel doğrulama yapılmadı (DOĞRULAMADIM):** 8. madde ekranı değiştiriyor ama bu gece emülatör yok. Turan'ın bakacağı adımlar sabah raporunda.

## 3. Silinen ve eklenen dosyalar

**Silinen (4):**

| Dosya | Neydi | Etkisi |
|---|---|---|
| `lib/core/content/kategori_durumlari.dart` | Kategori × kişinin durumu × ton "durum" cümleleri | **20 Ekim'den beri ölü koddu.** `3ac2c95`'te beş kategori de zaten gökyüzü yapısına geçmişti (`GokyuzuMetinleri.kategoriler` beşini de içeriyordu). Kullanıcının gördüğü hiçbir metin kaybolmadı |
| `lib/core/content/category_pools.dart` | Eski kategori detay havuzları (açılış + tavsiye) | Aynı nedenle ölü kod |
| `lib/features/onboarding/tanisma_screen.dart` | Tanışma soruları ekranı | Bilerek kaldırıldı (madde 5) |
| `lib/features/koleksiyon/koleksiyon_strings.dart` | Koleksiyon sabitleri | E6b: ARB'ye taşındı |

Ayrıca `yorum_yonu.dart` dosyasından `kategoriDurumlari`, `temaKategori` ve `durumAnahtari` çıktı. Bunlar da aynı ölü yoldu.

**Eklenen (9):**
- `lib/core/content/kimlik_metinleri.dart`: yükselen (dış görünüş) × Ay burcu (iç dünya) portre cümleleri.
- `lib/features/daily_luck/widgets/gun_devri_gozcusu.dart`: gün ve akşam devrini izleyen kök widget.
- Testler: `test/content/celiski_kapisi_test.dart` (12 burç × 36 cevap × 10 gün; hiçbir okuma portreyle çelişmiyor), `test/content/kimlik_metinleri_test.dart`, `test/daily_luck/gun_devri_test.dart`.
- Araştırma: `reports/Kişiye yakın yorum nasıl yazılır.md` ve `research_notes/` altında 4 not.

**Mevcut kullanıcılar için not:** Eski kayıtlarda tanışma cevapları (`enerji`, `karar`, `iliski`, `ugras` anahtarları) Hive'da durur ama artık okunmaz. Çökme olmaz; eski cevap verenler de element portresine geçer.

## 4. Örnek okuma: eski ve yeni

Aynı kişi, aynı gün. Ayşe Yılmaz, 14 Mart 1990, 08:30, İzmir (Balık, yaşam yolu 9). Çıktı gerçek koddan alındı: eski hâl `3ac2c95`, yeni hâl `2bbbe9d`. Geçici test betiği `test/ornek_okuma_test.dart` iki koda da kopyalanıp koşuldu, depoya girmedi. Mac saat dilimi +07.

### 27 Kasım 2026 (sayı günü)

| Bölüm | Eski (20 Ekim) | Yeni (11 Kasım) |
|---|---|---|
| Çünkü | (yok) | Sana özel, çünkü 14 Mart doğumlusun: burcun Balık (su), Ay burcun Terazi, yükselenin Boğa. Ay da bugün bir su burcunda. |
| Günün enerjisi | Ayşe, bugün tek başına zorlamak yerine birlikte hareket ettiğinde işler daha kolay akıyor. Ay senin elementinde dolaşıyor (Yengeç); olduğun gibi davrandığında işler kendiliğinden yerine oturur. Birini dinlemek için ayıracağın birkaç dakika aranızdaki bağı sandığından çok güçlendirebilir. Başkalarına verdiğin desteği kendi ihtiyaçlarınla dengele. | Ayşe, bugün tek başına zorlamak yerine birlikte hareket ettiğinde işler daha kolay akıyor. Ay senin elementinde dolaşıyor (Yengeç); olduğun gibi davrandığında işler kendiliğinden yerine oturur. Senden sabırlı olmak ve başkalarıyla uyum içinde ilerlemek bekleniyor; bunu kendi tarzınla, yani başkalarına şefkat göstermek ve büyük resmi görmek yoluyla yaparsan gün dengeli ve verimli geçer. Başkalarına verdiğin desteği kendi ihtiyaçlarınla dengele. |
| Öne çıkan · Aşk | **Ay senin elementinde dolaşıyor (Yengeç);** duygularını kendi dilinle söylemek için an yerinde. Geçmiş ilişkilerin izlerini uzun süre taşıyabilirsin; kapanış senin için önemli. 16:00 - 18:00 arasında sevdiğin birine onu neden önemsediğini tek cümleyle söyle. | Duygularını kendi dilinle söylemek için an yerinde. Geçmiş ilişkilerin izlerini uzun süre taşıyabilirsin; kapanış senin için önemli. 16:00 - 18:00 arasında sevdiğin birine onu neden önemsediğini tek cümleyle söyle. |
| Dikkat · Sosyal | **Ay senin elementinde (Yengeç);** kendin gibi davrandığında insanlar sana daha kolay yaklaşıyor. Yabancılarla bile kısa sürede samimi olursun; insanlar yanında anlaşıldığını hisseder. Dedikoduya ortak olma. | Kendin gibi davrandığında insanlar sana daha kolay yaklaşıyor. Balık burcu olarak kalabalıkta kolay yorulabilirsin; sana iyi gelen birkaç kişiyle vakit geçirmek seni yeniler. Dedikoduya ortak olma. |
| Kapanış | Bu ayın havası ilişkilerden yana; yakınlaşmalar ve uzlaşmalar ön planda. | (aynı) |

### 28 Kasım 2026 (burç günü, portre)

| Bölüm | Eski (20 Ekim) | Yeni (11 Kasım) |
|---|---|---|
| Günün enerjisi | … Ay Yengeç burcunda, Balık burcunla aynı elementte; doğallığın parlıyor ve günün enerjisi seninle aynı dili konuşuyor. Bu tür günlerde rahat edersin, çünkü kendini ifade etmek ve insanlarla bağ kurmak senin için çaba değil, alışkanlık. … | … Ay Yengeç burcunda, Balık burcunla aynı elementte; doğallığın parlıyor ve günün enerjisi seninle aynı dili konuşuyor. **Yükselenin Boğa seni acele etmeyen, huzur veren biri gibi gösterir; Ay burcun Terazi ise içeride başka konuşur: huzuru uyumlu ilişkilerde ararsın.** … |
| Öne çıkan · Aşk | **Yengeç burcundaki Ay duygularını parlatıyor;** içinden geçeni söylemek için daha iyi bir an zor bulunur. Aşkı bir masal gibi yaşamak istersin; … | İçinden geçeni söylemek için daha iyi bir an zor bulunur. Aşkı bir masal gibi yaşamak istersin; … |
| Dikkat · Sosyal | **Ay Yengeç burcunda, Balık burcunla aynı elementte;** seni tanıyan insanlarla vakit geçirmek en iyi gelen şey. … | Seni tanıyan insanlarla vakit geçirmek en iyi gelen şey. … |

Doğum saati ve ili girmeyen aynı kişide (yalnız tarih) "çünkü" satırı kısalıyor ("burcun Balık, elementin su"). Portre yerine gündelik sahne geliyor: "Bunu en çok bir arkadaşınla konuşurken ya da seni ifade eden bir işe vakit ayırırken fark edebilirsin." Ay burcu söylenmiyor, çünkü Ay o gün burç değiştiriyor ve kesin değil.

**Örnekte görülen kusur (düzeltilmedi, içerik kararı):** 27 Kasım bir sayı günü. Enerji paragrafı yaşam yolu 9'un sesiyle konuşuyor ("başkalarına şefkat göstermek ve büyük resmi görmek"). Aynı gün Dikkat paragrafı burç sesiyle konuşuyor: "Balık burcu olarak kalabalıkta kolay yorulabilirsin". "Tek ses" kuralı (madde 3) burada delinmiş. Olası neden: kategori paragrafında yaşam yolu havuzu çelişki kapısından yeterli cümle bırakmayınca burç cümlesine düşülüyor (`fortune_composer.dart` `sayiYeterli` / `ContentConfig.enAzKisilikSecenegi`). İki cümle birbiriyle çelişmiyor ama iki ayrı ses var. Bu oturumda düzeltilmedi; ayrı içerik oturumu ister.

## 5. Altın kayıt: hash değişikliği bilinçli mi?

**Kısa cevap:** `cunku` alanının özete eklenmesi bilinçli. İçerikten gelen değişiklikler de bilinçli. Ama tablo **+07 saat diliminde** üretilmiş. Türkiye saatinde 14 anahtar kırılıyor. Bunun kök nedeni 11 Kasım'dan eski bir motor davranışı.

Kanıt (27 Kas, `altin_kayit_test.dart`, 207 anahtar):

Ham çıktılar: `reports/gece_2026-11-27_kanit/` (`altin_*.txt`, örnek okuma logları, test ve analiz özeti).

| Deney | Sonuç |
|---|---|
| `git diff 3ac2c95 2bbbe9d -- test/content/altin_kayit_test.dart` | Üç değişiklik var. (1) `_Doku` özetine `ekle('cunku', o.cunku)` satırı eklendi. (2) Harita girdisi UTC'de kuruluyor; yorum: "yerel DateTime'a Duration eklemek yaz saati geçişlerinde saati kaydırıyor, kayıt makineden makineye değişiyordu". (3) 87 hash güncellendi: gunluk 36, kategori 31, begeni 12, profil 6, harita 2. |
| Yeni kod, özetten `cunku` çıkarılarak tablo yeniden üretildi (`ALTIN_KAYIT_YAZDIR=1`) | 48 günlük ve beğeni anahtarının hepsi değişiyor: `cunku` her okumaya giriyor, beklenen bu. `cunku` olmadan da 48'in hiçbiri eski kodla aynı değil: metin kurgusu da değişmiş (Ay öneki, tek ses, portre, kapı). Kategori ve profil hash'lerine `cunku` dokunmuyor; onları çelişki kapısı ve `profilMetniniUyarla(…, okuyucu.portre)` değiştiriyor. İsim, numara, rapor, uyum, yıllık ve bebek grupları (84 anahtar) eskisiyle birebir aynı. |
| Eski kod (`3ac2c95`), Mac'in saat dilimi (+07, Asia/Ho_Chi_Minh) | 17 anahtar kendi tablosuyla uyuşmuyor: yy2 ve yy33 okuyucuları ile harita. |
| Eski kod, `TZ=Europe/Istanbul` | **11/11 test yeşil.** Eski tablo Türkiye saatinde üretilmiş, doğru. |
| Yeni kod, `TZ=Europe/Istanbul` | **14 anahtar kırık**: `gunluk`, `kategori` ve `begeni` gruplarında yy2 ve yy33. Harita artık geçiyor; 11 Kasım'ın harita düzeltmesi işe yarıyor. |
| Yeni kod, `TZ=UTC` | Daha çok anahtar kırık (gunluk yy1/yy9, kategori 30 anahtar). |

**Kök neden:** `lib/core/luck_engine/ay_evresi.dart:64` `ayEvresiOrani` fonksiyonu yerel `DateTime`'ı `gun.toUtc()` ile çeviriyor. Gece yarısının UTC anı cihazın saat dilimine göre kayıyor. Bu yüzden evre sınırına yakın günlerde Ay evresi değişiyor ve evre skoru, "Neden bugün?" çipini ve metin seçimini etkiliyor. Türkiye'deki telefonlarda (2016'dan beri sabit +03) sonuç her gün aynı. Ama aynı (kullanıcı, gün) çifti yurt dışındaki bir telefonda başka skor verebilir (CLAUDE.md kural 8). Test de makinenin saat dilimine bağlı. Bu davranış 11 Kasım'dan önce de vardı; 11 Kasım tabloyu +07'de üretince görünür oldu.

**Öneri (karar bekliyor, kod değiştirilmedi):** Ay evresinde takvim günü Türkiye gece yarısı (UTC+3) olarak yorumlansın: `DateTime.utc(y, m, d).subtract(3 saat)`. Türkiye'deki kullanıcıların sonucu değişmez; test her makinede aynı sonucu verir. İngilizce sürümde dünya genelinde de deterministik olur. Bu bir `luck_engine` oturumu (birim testleriyle). Sonra altın tablo bir kez yeniden üretilir ve İstanbul tablosuyla aynı çıkmalıdır. O zamana kadar `flutter test` bu Mac'te yeşil, Türkiye saatindeki bir makinede ya da CI'da 3 test kırmızı olur.
