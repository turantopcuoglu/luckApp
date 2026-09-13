import '../../core/localization/app_dil.dart';
import '../../core/theme/cosmic_config.dart';

/// Bugün ekranının kehanet içermeyen, TR/EN ürün metinleri.
abstract final class TodayStrings {
  /// Onaylı mevcut uygulama adı.
  static const String brand = 'Kader';

  /// Açılış animasyonu aşaması; sahte hesaplama yüzdesi yoktur.
  static String opening(AppDil d) =>
      d.sec('Kartın açılıyor', 'Opening your card');

  /// Kalıcı yazma tamamlanmadan sonuç gösterilmez.
  static String saving(AppDil d) =>
      d.sec('Kartın kaydediliyor', 'Saving your card');

  /// Kayıt hatasında aynı gün için tekrar denenir.
  static String revealError(AppDil d) => d.sec(
    'Açılış kaydedilemedi. Tekrar deneyebilirsin.',
    'Couldn’t save your opening. Please try again.',
  );

  /// Kapalı kart başlığı.
  static String ready(AppDil d) =>
      d.sec('Bugünün kartı hazır', 'Today’s card is ready');

  /// Kapalı kart açıklaması.
  static String invitation(AppDil d) =>
      d.sec('Kendine bir dakika ayır.', 'Take a minute for yourself.');

  /// Tek açma eylemi.
  static String open(AppDil d) => d.sec('Kartımı aç', 'Open my card');

  /// Skorun etiketi.
  static String score(AppDil d) =>
      d.sec('Günün şans puanı', 'Daily luck score');

  /// Ekran okuyucu için tam skor.
  static String scoreValue(AppDil d, int value) => d.sec(
    'Günün şans puanı: 100 üzerinden $value',
    'Daily luck score: $value out of 100',
  );

  /// Alan bölüm başlığı.
  static String dimensions(AppDil d) =>
      d.sec('Günün kategorileri', 'Your daily categories');

  /// Kilidin sayı içermeyen açıklaması.
  static String locked(AppDil d) => d.sec('Kilitli', 'Locked');

  /// İsteğe bağlı görev başlığı.
  static String mission(AppDil d) =>
      d.sec('Bugünün küçük adımı', 'Today’s small step');

  /// Görev zorunluluk veya sonuç vaadi değildir.
  static String optional(AppDil d) => d.sec(
    'İstersen dene; günün sana ait.',
    'Try it if you like. The day is yours.',
  );

  /// Paylaşma eylemi.
  static String share(AppDil d) => d.sec('Paylaş', 'Share');

  /// Paylaşım işlemi bekleme metni.
  static String sharing(AppDil d) => d.sec('Hazırlanıyor', 'Preparing');

  /// Paylaşım başarısızlığı.
  static String shareError(AppDil d) => d.sec(
    'Paylaşım hazırlanamadı. Tekrar deneyebilirsin.',
    'Couldn’t prepare your share. Please try again.',
  );

  /// Gün sonu bölüm başlığı.
  static String evening(AppDil d) =>
      d.sec('Akşam kendine dön', 'Check in with yourself');

  /// Sakin gün sonu daveti.
  static String eveningBody(AppDil d) => d.sec(
    'Günün nasıl geçti? Hazır olduğunda kısa bir not bırak.',
    'How did your day go? Leave a short reflection when you’re ready.',
  );

  /// Mevcut feedback rotasına eylem.
  static String reflect(AppDil d) =>
      d.sec('Günümü değerlendir', 'Reflect on my day');

  /// Yükleme durumu.
  static String loading(AppDil d) =>
      d.sec('Günün kartı hazırlanıyor', 'Preparing today’s card');

  /// Hata durumu.
  static String error(AppDil d) =>
      d.sec('Kartına şu an ulaşamadık.', 'We couldn’t load your card.');

  /// Hata tekrar deneme.
  static String retry(AppDil d) => d.sec('Tekrar dene', 'Try again');

  /// Genel skor geleceğe ilişkin olay vaadi değil, kısa düşünme davetidir.
  static String scoreTitle(AppDil d, int score) =>
      switch (CosmicTone.fromScore(score)) {
        CosmicTone.calm => d.sec(
          'Yavaşlamak da ilerlemektir.',
          'Slowing down is progress, too.',
        ),
        CosmicTone.bright ||
        CosmicTone.rare => d.sec('Küçük bir adım at.', 'Take one small step.'),
        _ => d.sec('Kendi ritmini bul.', 'Find your own pace.'),
      };

  /// Skoru kişinin değeri veya günün garantisi olarak sunmaz.
  static String scoreReflection(AppDil d, int score) =>
      switch (CosmicTone.fromScore(score)) {
        CosmicTone.calm => d.sec(
          'Her şeyi bugün çözmek zorunda değilsin.',
          'You don’t have to solve everything today.',
        ),
        CosmicTone.bright || CosmicTone.rare => d.sec(
          'Aklındaki bir işi seç. İlk adımı bugün at.',
          'Choose one thing on your mind. Take the first step today.',
        ),
        _ => d.sec(
          'Hepsini değil, senin için önemli olanı seç.',
          'Choose what matters to you, not everything.',
        ),
      };

  /// Sakin skorda daha küçük bir görev önerir; puanı değiştirmez.
  static String gentleStep(AppDil d) => d.sec(
    'Bir işi küçült. On dakika ayır.',
    'Make a task smaller. Give it ten minutes.',
  );

  /// Eğlence skorunun hayatı belirlemediğine ilişkin kısa hatırlatma.
  static String scoreNote(AppDil d) => d.sec(
    'Bu puan gününü belirlemez.',
    'This score does not define your day.',
  );
}
