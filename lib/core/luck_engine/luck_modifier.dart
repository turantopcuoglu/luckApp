/// Günün skorunu etkileyen tek bir modifiyer (ör. ay evresi).
///
/// Motor, her modifiyerin adını ve puan etkisini ayrıca raporlar ki
/// UI katmanı "Ay evresi skorunu +3 puan etkiledi" gibi açıklamalar
/// üretebilsin (plan Session 1, madde 5).
class LuckModifier {
  /// [ad] ve [etki] ile modifiyer oluşturur.
  const LuckModifier({required this.ad, required this.etki});

  /// Modifiyerin tanımlayıcı adı (ör. "Ay evresi").
  final String ad;

  /// Skora eklenen puan. Ay evresi ve numeroloji için -8..+8,
  /// seri dengesi için +5..+10 aralığındadır.
  final int etki;

  @override
  bool operator ==(Object other) =>
      other is LuckModifier && other.ad == ad && other.etki == etki;

  @override
  int get hashCode => Object.hash(ad, etki);

  @override
  String toString() => 'LuckModifier($ad: $etki)';
}
