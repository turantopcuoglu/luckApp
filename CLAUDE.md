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
