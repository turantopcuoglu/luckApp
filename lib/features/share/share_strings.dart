import '../../core/localization/app_dil.dart';

/// Paylaşım özelliğinin metinleri (TR + EN).
abstract final class ShareStrings {
  /// Ana ekrandaki paylaş butonunun etiketi.
  static String paylas(AppDil dil) => dil.sec('Paylaş', 'Share');

  /// Story kartının alt köşesindeki uygulama imzası (marka).
  static const String marka = 'Kader ✨';

  /// Story kartındaki skor etiketi.
  static String genelSkor(AppDil dil) => dil.sec('GENEL SKOR', 'OVERALL SCORE');

  /// Paylaşım menüsüne eklenen kısa metin.
  static String paylasimMetni(AppDil dil) =>
      dil.sec('Bugünkü kaderim ✨', 'My fortune today ✨');
}
