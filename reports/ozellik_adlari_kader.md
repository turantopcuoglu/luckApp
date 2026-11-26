# "Kader" geçen özellik adları → Solenia dili

Karar: Turan, 26 Kasım 2026, "Değişsin" (yönetici iletisi; `STUDIO/KARARLAR.md`, commit `aa58374`). Yalnız görünen metin değişti. Kod adlarına dokunulmadı: `KaderProfili`, `KaderProfiliScreen`, `KaderApp`, Dart paket adı `kader`, Play ürün kimlikleri `kader_*`, bildirim kanal kimliği `kader_gunluk`, simge kaynağı `ic_stat_kader`.

Referans: Co–Star, CHANI ve The Pattern profili "harita", "gök" ya da kişinin kendi adıyla anıyor. Hiçbiri "kader" ya da "destiny" demiyor; başlıklar kısa ve iyelik ekli. "Harita" kelimesi seçilmedi, çünkü Profil'in içinde zaten ayrı bir doğum haritası ekranı ("Haritanı oku") var. Profil için "Gök", günlük okuma için "gökyüzü / yıldızlar" kullanıldı.

## Envanter ve değişiklik

Tarama: `lib/` altındaki bütün Dart dizgeleri, iki ARB, yasal metinler, okuma içeriği (`lib/core/content`), Android/iOS kaynakları. Okuma içeriğinde ve yasal metinlerde "kader" geçmiyor. İngilizce dosyada "fate" geçmiyor.

| Anahtar | Yer | TR eski → yeni | EN eski → yeni |
|---|---|---|---|
| `profilBaslik` | Profil ekranı başlığı | Kader Profilin → **Gök Profilin** | Your Destiny Profile → **Your Sky Profile** |
| `premiumOzellik2` | Premium maddesi | Tam Kader Profili: … → **Tam Gök Profili: …** | Full Destiny Profile: … → **Full Sky Profile: …** |
| `premiumAltBaslik` | Premium alt başlığı | Kaderinin tamamını gör: … → **Gökyüzünün tamamını gör: …** | See your whole destiny: … → **See your whole sky: …** |
| `onboardingKaderimiHesapla` | Tanışma butonu | Kaderimi hesapla → **Yıldızlarıma bak** | Calculate my destiny → **Read my stars** |
| `gunlukYukleniyor` | Günlük okuma yükleniyor | Kaderin hesaplanıyor... → **Gökyüzün okunuyor...** | Calculating your destiny... → **Reading your sky...** |
| `paylasimMetni` | Paylaşım mesajı ve skor gizli kartın başlığı | Bugünkü kaderim ✨ → **Bugünkü yıldızlarım ✨** | My destiny today ✨ → **My stars today ✨** |
| `bildirimSabah1` | Sabah bildirimi | Bugünün kaderi hazır ✨ → **Bugünün gökyüzü hazır ✨** | Today's destiny is ready ✨ → **Today's sky is ready ✨** |
| `bildirimSabah4` | Sabah bildirimi | Kader kartın açılmayı bekliyor 🎴 → **Bugünkü kartın açılmayı bekliyor 🎴** | Your destiny card is waiting… → **Today's card is waiting to be opened 🎴** |
| `bildirimSabah6` | Sabah bildirimi | …: kaderin hesaplandı ☕ → **…: gökyüzün hazır ☕** | …: your destiny is calculated ☕ → **…: your sky is ready ☕** |
| `bildirimSabah11` | Sabah bildirimi | Kaderin kapıda, açmayan bilemez 🚪 → **Yıldızların kapıda, açmayan bilemez 🚪** | Your destiny is at the door… → **Your stars are at the door. Open it to find out 🚪** |
| `bildirimKanalAciklama` | Android bildirim ayarı | Sabah kader hazır ve … → **Sabah okuma hazır ve …** | Morning destiny-ready and … → **Morning reading-ready and …** |
| `ShareConfig.dosyaAdi` | Paylaşılan görselin dosya adı (alıcı görür) | kader_gunun_sansi.png → **solenia_gunun_sansi.png** | aynı |
| `ShareConfig.aracDosyaAdi` | Araç kartı dosya adı | kader_kesfet.png → **solenia_kesfet.png** | aynı |

ARB açıklamaları da güncellendi (`@sekmeBugun`, `@sekmeProfil`, `@profilBaslik`). Bunlar kullanıcıya görünmez.

## Bilerek bırakılanlar (kullanıcı görmez)

- Bildirim kanal kimliği `kader_gunluk`: değişirse kullanıcının kanal ayarı (sessize alma vb.) kaybolur ve eski kanal ayarlarda yetim kalır.
- `ic_stat_kader` simge kaynağı ve `assets/svg/bildirim_kapi.svg` içindeki "Kader" başlığı ile yorumu: yalnız kaynak dosyada geçiyor.
- Kod adları ve paket/ürün kimlikleri: bkz. `reports/magaza_metni_taslak.md`, yayın öncesi açıklar.

## Kanıt

`reports/ozellik_adi_kanit/`: önce/sonra çiftleri (Premium TR, Profil TR ve EN, tanışma TR, paylaşım kartı TR) ve hepsini tek şeritte gösteren `once_sonra.png`. Kareler test ortamında çizildi: font Roboto, emoji kutu (□) görünür.

## Görsel denetçi bulguları (kalan farklar, karar Turan'da)

1. **Paylaşım kartı (skor gizli):** "Bugünkü kaderim ✨" önce "Bugünkü kaderim" / "✨" diye kırılıyordu. "Bugünkü yıldızlarım ✨" şimdi "Bugünkü" / "yıldızlarım ✨" diye kırılıyor. "yıldızlarım" kelimesinin sol ucu açık renk bulut bandına düşüyor ve orada kontrast azalıyor. Satır sayısı aynı. Kare gerçek fontla çizilmedi; cihazda bakılmalı. Seçenekler: kısa metin ("Bugün yıldızlarım ✨") ya da daha güçlü yazı gölgesi.
2. **Premium madde 2:** "Tam Gök Profili: gölge yanın, aşk, iş, yaşam" / "dersin, iç sesin": "yaşam dersin" iki satıra bölünüyor. Kırılma cihaz genişliğine bağlı. Gerekirse iki kelime arasına bölünmeyen boşluk konur.
3. **Premium alt başlık:** ilk satır neredeyse tam genişlikte. Inter fontuyla dar ekranda üçüncü satıra taşabilir; denetlenmedi.
4. **Anlam:** "Gök Profilin" başlığının altında numeroloji sayıları ve Büyük Üçlü birlikte duruyor. Başlık gökyüzünü anıyor, ilk kart ise sayıları anlatıyor. Daha geniş bir ad isteniyorsa alternatifler: "Öz Profilin" / "Your Core Profile".
5. Metin dışında görsel fark yok (gözle). Kareler Roboto fontuyla çizildi, emoji kutu görünüyor. Inter/Playfair fontuyla ve gerçek cihazda **doğrulanmadı**.
