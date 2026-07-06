/// Şans skorunun hesaplandığı beş kategori.
///
/// [agirlik] değerleri genel skorun ağırlıklı ortalamasında kullanılır
/// ve toplamları 1.0'dır (bkz. `luck_engine_test.dart`).
enum LuckCategory {
  /// Aşk ve ilişkiler.
  ask(agirlik: 0.25, etiket: 'Aşk'),

  /// Para ve kariyer.
  para(agirlik: 0.25, etiket: 'Para'),

  /// Sağlık ve enerji.
  saglik(agirlik: 0.20, etiket: 'Sağlık'),

  /// Risk alma ve kumar/karar şansı.
  risk(agirlik: 0.15, etiket: 'Risk'),

  /// Sosyal ilişkiler ve karşılaşmalar.
  sosyal(agirlik: 0.15, etiket: 'Sosyal');

  const LuckCategory({required this.agirlik, required this.etiket});

  /// Genel skor hesabındaki ağırlık (tüm kategorilerin toplamı 1.0).
  final double agirlik;

  /// Kullanıcıya gösterilecek Türkçe kategori adı.
  final String etiket;
}
