/// Uygulama genelinde paylaşılan Hero etiketi sabitleri.
///
/// Aynı etiket iki ekranda da kullanılmak zorunda olduğu için
/// feature'lardan bağımsız, tek noktada tanımlanır.
abstract final class HeroTags {
  /// Onboarding hesaplama ekranındaki küçük halkadan ana ekrandaki
  /// skor halkasına uçan Hero'nun etiketi (plan Session 6, madde 3).
  static const String skorHalkasi = 'skor-halkasi';
}
