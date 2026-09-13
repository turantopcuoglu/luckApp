import '../../core/localization/app_dil.dart';

/// Paylaşım özelliğinin metinleri (TR + EN).
abstract final class ShareStrings {
  /// Tasarım düzenleyicisinin başlığı.
  static String designer(AppDil dil) =>
      dil.sec('Story tasarımın', 'Your Story design');

  /// Kullanıcıya yalnız sistem paylaşımı vaat edilir.
  static String export(AppDil dil) =>
      dil.sec('Story görselini paylaş', 'Share Story image');

  /// Paylaşımın platforma otomatik gönderilmediğini açıklar.
  static String exportNote(AppDil dil) => dil.sec(
    'Görsel 9:16 hazırlanır. Açılan menüden Instagram, WhatsApp veya başka bir uygulama seçebilirsin.',
    'A 9:16 image is prepared. Choose Instagram, WhatsApp or another app in the share sheet.',
  );

  /// Kilitli kategori için erişilebilir ad.
  static String locked(AppDil dil) => dil.sec('Kilitli', 'Locked');

  /// Ana ekrandaki paylaş butonunun etiketi.
  static String paylas(AppDil dil) => dil.sec('Paylaş', 'Share');

  /// Story kartının alt köşesindeki uygulama imzası (marka).
  static const String marka = 'Kader';

  /// Story kartındaki skor etiketi.
  static String genelSkor(AppDil dil) =>
      dil.sec('Günün şans puanı', 'Today’s luck score');

  /// Paylaşım menüsüne eklenen kısa metin.
  static String paylasimMetni(AppDil dil) =>
      dil.sec('Bugünkü kaderim ✨', 'My fortune today ✨');
}
