# Kader — Günlük Şans Uygulaması

> _Kader_, her güne kişiye özel, **deterministik** bir şans skoru ve sıcak
> bir yorum sunan bir Flutter uygulamasıdır. Aynı kullanıcı + aynı gün her
> zaman aynı sonucu üretir; amaç fal değil, güne umutla başlamak için küçük
> bir ritüeldir.
>
> _A Flutter app that gives each day a personal, deterministic "luck score"
> and a warm daily reading. Turkish UI._

**Bu uygulama yalnızca eğlence amaçlıdır.**

---

## Özellikler

- **Günlük kader skoru** — SHA-256 tohumlu deterministik motor; (kullanıcı,
  gün) çifti her zaman aynı skoru, rengi, şanslı sayıyı ve yorumu verir.
- **Kategori kırılımı** — Aşk, Para, Sağlık, Risk, Sosyal; premium kategoriler
  kilitliyken skor widget ağacına hiç girmez (gizlilik).
- **Kanıt Döngüsü + Geçmiş Heatmap** — GitHub-tarzı takvim ısı haritası;
  akşam geri bildirimiyle "yüksek dediğimiz günlerin %X'inde şanslı hissettin"
  güven döngüsü.
- **Kader Kartı Koleksiyonu** — geçmiş günlerin kart grid'i; nadir **Altın
  Gün** (skor ≥ 92) kartları öne çıkar; karta dokununca o günün yorumu
  deterministik yeniden üretilir.
- **Ay Şans Raporu** — Spotify-Wrapped tarzı paylaşılabilir aylık özet
  (en şanslı gün, ortalama, altın gün, en uzun seri, baskın kategori).
- **Şanslı Saat Bildirimi** — günün baskın kategorisinden türetilen
  deterministik "şanslı saat" hatırlatması.
- **Şefkatli Seri (streak)** — suçluluk yaratmayan kayıt serisi rozeti
  (tek-gün tolerans, sıfırda gizlenir).
- **Ayarlar + Yasal Uyum** — isim düzenleme, bildirim aç/kapa & saat, sürüm,
  eğlence-amaçlı feragati.
- **Erişilebilirlik** — skor/kategori/heatmap/koleksiyon öğeleri ekran okuyucu
  için tek anlamlı düğümlerdir; kilitli skor TalkBack/VoiceOver'a da sızmaz.

## Mimari

Feature-first, iki katman:

```
lib/
├── core/            # Saf Dart — Flutter import'u YASAK (deterministik, test edilir)
│   ├── luck_engine/ # Skor motoru + config (SHA-256 tohum, bant/ton)
│   ├── content/     # Yorum/renk/tavsiye besteci (deterministik seçim)
│   ├── history/     # Geçmiş & aylık özet analizleri (saf fonksiyonlar)
│   └── storage/     # Hive modelleri, repository'ler, provider'lar
├── features/        # UI katmanı (Riverpod + Flutter)
│   ├── daily_luck/  # Ana ekran, skor halkası, kategori kartları
│   ├── history/     # Heatmap + Kanıt Döngüsü
│   ├── collection/  # Kader Kartı Koleksiyonu
│   ├── share/       # Off-screen PNG üretimi + paylaşım
│   ├── feedback/    # Akşam geri bildirimi + bildirimler
│   ├── settings/    # Ayarlar + yasal
│   └── onboarding/  # Karşılama + profil kurulumu
├── shared/          # Ortak widget'lar (ikonlar, rotalar)
└── main.dart
```

- **State:** Riverpod (setState yalnız lokal animasyon için).
- **Kalıcılık:** Hive (profil + günlük kayıtlar).
- **Determinizm:** Aynı (kullanıcı, gün) her zaman aynı sonuç — bozulması
  bir hata sayılır (bkz. `CLAUDE.md` kural 8).

## Teknoloji Yığını

Flutter · Dart · Riverpod · Hive · crypto (SHA-256) · flutter_svg ·
share_plus · flutter_local_notifications · google_fonts

## Başlangıç

```bash
flutter pub get          # bağımlılıklar
flutter run              # cihaz/emülatörde çalıştır
flutter test             # tüm test paketi
flutter analyze          # statik analiz (sıfır uyarı beklenir)
```

## Test & Kalite

- `luck_engine` ve diğer saf fonksiyonlar widget harness'sız birim test edilir.
- Her session sonunda `flutter analyze` sıfır hata + testler yeşil olmalıdır.
- Proje anayasası ve çalışma kuralları için bkz. **`CLAUDE.md`**.

## Feragat

Bu uygulama yalnızca eğlence amaçlıdır; sonuçlar hiçbir şekilde gerçek bir
öngörü, tavsiye veya kehanet değildir.
