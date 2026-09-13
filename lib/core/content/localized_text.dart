import '../localization/app_dil.dart';

/// Aynı içerik kimliğinin iki dilini birlikte tutar; indeks kaymasını önler.
class LocalizedText {
  /// Eş anlamlı Türkçe ve İngilizce metni oluşturur.
  const LocalizedText(this.tr, this.en);

  /// Türkçe metin.
  final String tr;

  /// İngilizce metin.
  final String en;

  /// Seçilen dildeki metin.
  String text(AppDil dil) => dil.sec(tr, en);
}
