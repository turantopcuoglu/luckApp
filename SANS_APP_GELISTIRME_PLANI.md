# ŞANS UYGULAMASI — GELİŞTİRME PLANI (Flutter + Claude Code)

Çalışma modeli: **Claude Code = kod yazar, sen = mimar/entegratör.**
Her prompt = tek session = tek sistem. Session bitince emülatörde test et, commit at, sonrakine geç.

---

## 0. TEKNİK KARARLAR

| Konu | Karar | Neden |
|---|---|---|
| Framework | Flutter (Dart) | En iyi animasyon API'si, tek codebase, hot reload |
| State | Riverpod | Test edilebilir, Claude Code iyi bilir |
| Storage | Hive | Lokal, hızlı, backend gerektirmez |
| Şans motoru | Saf Dart paketi (`lib/core/luck_engine/`) | UI'dan izole, %100 unit test |
| Görseller | SVG (`flutter_svg`) + CustomPainter | Claude üretebilir, ölçeklenir, hafif |
| Animasyon | Flutter native (AnimationController, Hero, PageRouteBuilder) | Harici bağımlılık minimum |
| Font/İkon | Google Fonts + Lucide | Ücretsiz, lisans temiz |

Klasör yapısı (feature-first):

```
lib/
  core/
    luck_engine/      # saf Dart, UI bilmez
    theme/            # renkler, text stilleri, spacing
    storage/          # Hive wrapper
  features/
    onboarding/
    daily_luck/       # ana ekran
    categories/       # aşk/para/sağlık/risk/sosyal
    share/            # story kartı üretimi
    feedback/         # akşam geri bildirimi
  shared/widgets/     # ortak animasyonlu widget'lar
assets/
  svg/                # Claude'un ürettiği görseller
test/
  luck_engine/        # motor testleri (zorunlu)
```

---

## 1. CLAUDE.md (repo köküne koy)

```markdown
# CLAUDE.md — Şans Uygulaması Proje Anayasası

## Roller
- Claude Code: kod yazar, test yazar, SVG asset üretir.
- Geliştirici (Turan): mimari kararlar, entegrasyon, emülatör testi.
- Claude Code ASLA: pubspec'e sormadan paket eklemez, klasör
  yapısını değiştirmez, birden fazla feature'a aynı anda dokunmaz.

## Kurallar
1. Her session TEK sistem üzerinde çalışır. Kapsamı genişletme.
2. Tüm public class/metotlara /// dartdoc yorumu, karmaşık
   bloklara satır içi yorum ZORUNLU.
3. luck_engine saf Dart kalır: Flutter import'u YASAK.
4. luck_engine'e yazılan her fonksiyonun unit testi aynı
   session'da yazılır. Test yoksa iş bitmemiştir.
5. State yönetimi sadece Riverpod. setState sadece lokal
   animasyon state'i için kullanılabilir.
6. Magic number yasak: sabitler core/theme veya ilgili
   config dosyasında tanımlanır.
7. Her session sonunda: `flutter analyze` sıfır hata,
   testler yeşil, kısa değişiklik özeti.
8. Skor algoritması deterministik: aynı (kullanıcı, gün)
   çifti HER ZAMAN aynı sonucu üretir. Bunu bozan PR reddedilir.

## Yapılamayanlar (bunları geliştirici yapar)
- Emülatör/gerçek cihaz testi
- Store metadata, imzalama, release build
- Firebase/servis hesabı bağlama
```

---

## 2. SESSION PROMPTLARI (sırayla)

### SESSION 0 — Repo İskeleti
```
Yeni bir Flutter projesi kur: "kader" (com.turan.kader).
CLAUDE.md dosyasındaki anayasayı oku ve tüm session boyunca uygula.

Görevler:
1. Feature-first klasör yapısını oluştur (CLAUDE.md'deki şema).
2. pubspec.yaml: flutter_riverpod, hive, hive_flutter,
   flutter_svg, google_fonts ekle. Başka paket EKLEME.
3. core/theme: dark tema. Renk paleti: derin lacivert zemin
   (#0A0E1A), altın vurgu (#F4C95D), soft mor ikincil (#8B7EC8).
   TextTheme, spacing sabitleri, radius sabitleri tanımla.
4. main.dart: ProviderScope + tema bağlanmış boş bir ana ekran
   ("Kader" yazısı ortada).
5. analysis_options.yaml: flutter_lints strict ayarla.

Çıktı: flutter analyze temiz, uygulama emülatörde açılıyor.
```

### SESSION 1 — Şans Motoru (çekirdek, UI yok)
```
Sadece lib/core/luck_engine/ üzerinde çalış. Flutter import YASAK.

LuckEngine sınıfı yaz:
1. Girdi: UserSeed(dogumTarihi, isimHash) + DateTime gun.
2. Deterministik seed: SHA-256(isimHash + dogumTarihi.toIso8601 +
   gun yyyy-MM-dd) → int seed → Random(seed).
3. Skor üretimi: 5 kategori (ask, para, saglik, risk, sosyal)
   her biri 0-100. Genel skor = ağırlıklı ortalama.
4. Dağılım şekillendirme: ham uniform değeri 40-85 bandına
   sıkıştıran, uçlara (<15 ve >92) %3 ihtimal bırakan bir
   transform fonksiyonu yaz. Fonksiyonu ayrı ve test edilebilir tut.
5. Modifiyerler: ay evresi (basit astronomik hesap, paket yok),
   gün numerolojisi (rakam toplamı). Her modifiyer -8/+8 puan,
   etkisi açıklama metni için ayrıca raporlansın:
   LuckResult içinde List<LuckModifier>(ad, etki) döndür.
6. Streak dengesi: son 3 günün skorları parametre olarak verilirse
   ortalaması 45'in altındaysa bugüne +5..+10 bias uygula.

Testler (zorunlu, ayni session):
- Aynı girdi → aynı çıktı (determinizm).
- Farklı kullanıcı → farklı skor.
- 10.000 örnekte dağılım: %90+ değer 40-85 bandında.
- Bias testi: düşük geçmiş → yükselen skor.

Her public üyeye dartdoc, transform fonksiyonuna satır içi yorum.
```

### SESSION 2 — Veri Katmanı
```
Sadece core/storage ve ilgili modeller.

1. Hive kutuları: user_profile (isim, doğum tarihi, onboarding
   tamamlandı mı), daily_records (gün → LuckResult + kullanıcı
   feedback'i).
2. Repository sınıfları: UserRepository, LuckHistoryRepository.
   Riverpod provider'ları ile expose et.
3. "Bugünün skoru zaten üretildi mi?" kontrolü: aynı gün ikinci
   açılışta motoru tekrar çalıştırma, kayıttan oku.
4. Son 3 gün skorunu motor bias'ı için sağlayan yardımcı metot.

Test: repository'lerin mock Hive ile unit testleri.
```

### SESSION 3 — Ana Ekran (statik UI)
```
Sadece features/daily_luck. Animasyon YOK, bu sonraki session.

1. Ekran düzeni: üstte tarih + selamlama, ortada büyük dairesel
   skor göstergesi (CustomPainter ile: arka halka + skor oranında
   dolan altın gradient halka), altında 2-3 cümlelik yorum kartı,
   en altta 5 kategori mini kartı (yatay scroll).
2. Yorum metni: şimdilik modifiyer listesinden template ile üret
   ("Ay evresi skorunu X puan etkiledi" tarzı). Template'leri
   ayrı bir tr_strings.dart dosyasında tut.
3. Tüm ölçüler theme sabitlerinden gelsin, magic number yok.

Çıktı ekran görüntüsü tarifi ver, ben emülatörde karşılaştıracağım.
```

### SESSION 4 — SVG Asset Üretimi
```
assets/svg/ altına şu SVG'leri sen üret (elle yaz, harici görsel yok):

1. Kategori ikonları (5 adet): kalp, para kesesi, yaprak, zar,
   iki kişi silueti. Stil: 2px stroke, yuvarlak uçlar, tek renk
   (currentColor), 24x24 viewBox — tema rengiyle boyanabilir.
2. Ana ekran arka planı için: köşelerde soluk yıldız/parçacık
   deseni (opacity 0.06, tekrar edilebilir pattern).
3. Boş durum illüstrasyonu: kristal küre, minimal line-art.
4. Uygulama ikonu taslağı: lacivert zeminde altın dört yapraklı
   yonca, flat, 512x512.

Hepsini flutter_svg ile render eden bir AppIcons/AppIllustrations
sınıfı yaz. Her SVG'nin başına <!-- açıklama --> yorumu koy.
```

### SESSION 5 — Animasyonlar
```
Sadece animasyon katmanı. Mevcut widget'ların davranışını değiştirme,
sarmala.

1. Skor count-up: uygulama açılınca 0'dan günün skoruna 1.2 sn'de
   easeOutCubic ile sayan animasyon + halka dolumu senkron.
2. Kart reveal: yorum kartı 3D flip ile açılsın (Transform +
   AnimationController, perspective matrix). Kullanıcı karta
   dokunana kadar kapalı ("Bugünün kaderini gör" yazılı arka yüz).
   Flip fizigi: 500ms, easeInOutBack.
3. Kategori kartları: staggered entrance (her kart 80ms arayla
   fade+slide, Interval curve kullan).
4. Ekran geçişleri: PageRouteBuilder ile paylaşılan fade-through
   geçişi, shared/widgets/app_route.dart içinde tek yerden.
5. Performans kuralı: tüm animasyonlar RepaintBoundary ile izole,
   const constructor'lar korunacak. DevTools'ta jank yaratan
   rebuild olmayacak — build metotlarında animasyon değeri
   dinleyen geniş subtree bırakma, AnimatedBuilder child pattern'i
   kullan (yorum satırlarıyla açıkla).
```

### SESSION 6 — Onboarding
```
features/onboarding. 3 adımlı akış:

1. Karşılama: uygulama ikonu + slogan, "Başla" butonu.
2. İsim girişi + doğum tarihi seçici (CupertinoDatePicker).
3. "Kaderin hesaplanıyor..." sahte hesaplama ekranı: 2.5 sn süren
   parçacık animasyonu (CustomPainter, basit particle system —
   50 partikül, merkezden dağılıp toplanan). Bitince ana ekrana
   Hero geçişi ile skor halkası büyüyerek gelsin.

Onboarding tamamlanınca user_profile'a yaz, tekrar gösterme.
Geri tuşu davranışlarını düzgün ele al.
```

### SESSION 7 — Paylaşım Kartı
```
features/share.

1. "Paylaş" butonu ana ekranda skor halkasının altına.
2. RepaintBoundary + toImage ile 1080x1920 story formatında
   kart render et: skor, tarih, kategori mini barları, alt
   köşede uygulama adı. Ayrı bir off-screen widget olarak tasarla.
3. share_plus paketi ekle (pubspec değişikliği için onay notu düş).
4. Kart tasarımı ekrandakinden farklı: daha dramatik, tam ekran
   gradient, büyük tipografi.
```

### SESSION 8 — Akşam Geri Bildirimi + Bildirimler
```
features/feedback + flutter_local_notifications (onay notu düş).

1. Saat 21:00 lokal bildirim: "Bugün gerçekten şanslı mıydın?"
2. Bildirime dokununca tek ekranlık feedback: 👍/👎 + opsiyonel
   emoji seçimi. daily_records'a işle.
3. Sabah 08:30 bildirim: "Bugünün kaderi hazır ✨" — metin
   varyasyonları listesi tr_strings'e (en az 10 varyasyon,
   rastgele seçilsin).
4. Bildirim izin akışını onboarding sonuna ekle (reddedilirse
   nazik fallback).
```

### SESSION 9 — Kategori Detay + Premium İskeleti
```
features/categories.

1. Kategori kartına dokununca detay sayfası: kategori skoru,
   o kategoriye özel 2 cümle yorum, "şanslı saat aralığı"
   (seed'den türet, deterministik).
2. Premium gate widget'ı: 5 kategoriden 2'si (aşk, para) kilitli
   görünsün — blur + kilit ikonu. Dokununca paywall placeholder
   sayfası (satın alma entegrasyonu YOK, sadece UI).
3. Kilit durumu Riverpod'da tek bir entitlementProvider'dan
   okunsun ki ileride RevenueCat bağlamak tek nokta olsun.
```

### SESSION 10 — Cila + Release Hazırlığı
```
1. flutter analyze + tüm testler yeşil doğrula, ölü kod temizle.
2. Uygulama genelinde erişilebilirlik: semantics label'ları,
   min dokunma alanı 48dp kontrolü.
3. app icon ve splash screen bağla (flutter_launcher_icons,
   flutter_native_splash — onay notu düş).
4. "Bu uygulama yalnızca eğlence amaçlıdır" ibaresini onboarding
   ve ayarlar ekranına ekle (store reddi riskine karşı ZORUNLU).
5. README: kurulum, mimari özeti, session geçmişi.
```

---

## 3. SENİN GÖREVLERİN (Claude Code yapamaz)

- Her session sonrası: `flutter run` ile emülatör testi, görsel kontrol
- Git: session başına 1 branch → test → main'e merge
- Android Studio: emülatör kurulumu (Pixel 7, API 34 önerilir)
- Store hesapları, imzalama anahtarı, release build
- Paywall/RevenueCat entegrasyonu (Session 9 sonrası ayrı iş)

## 4. SIRA NEDEN BÖYLE

Motor (S1) her şeyden önce çünkü ürünün kalbi ve UI olmadan test
edilebilir. UI (S3) animasyondan (S5) önce statik doğrulanır —
animasyonlu bozuk UI debug etmek iki kat zaman alır. Paylaşım (S7)
bildirimden önce çünkü viral döngü retention'dan daha erken değer
kanıtlar. Premium (S9) en sonda çünkü satın alma entegrasyonu
emülatörde tam test edilemez, iskeletini kurmak yeterli.
