import '../localization/app_dil.dart';

/// Şans skorunun hesaplandığı beş kategori.
///
/// [agirlik] değerleri genel skorun ağırlıklı ortalamasında kullanılır
/// ve toplamları 1.0'dır (bkz. `luck_engine_test.dart`).
enum LuckCategory {
  /// Aşk ve ilişkiler.
  ask(agirlik: 0.25, etiketTr: 'Aşk', etiketEn: 'Love'),

  /// Para ve kariyer.
  para(agirlik: 0.25, etiketTr: 'Para', etiketEn: 'Money'),

  /// Sağlık ve enerji.
  saglik(agirlik: 0.20, etiketTr: 'Sağlık', etiketEn: 'Health'),

  /// Risk alma ve kumar/karar şansı.
  risk(agirlik: 0.15, etiketTr: 'Risk', etiketEn: 'Risk'),

  /// Sosyal ilişkiler ve karşılaşmalar.
  sosyal(agirlik: 0.15, etiketTr: 'Sosyal', etiketEn: 'Social');

  const LuckCategory({
    required this.agirlik,
    required this.etiketTr,
    required this.etiketEn,
  });

  /// Genel skor hesabındaki ağırlık (tüm kategorilerin toplamı 1.0).
  final double agirlik;

  /// Türkçe kategori adı.
  final String etiketTr;

  /// İngilizce kategori adı.
  final String etiketEn;

  /// [dil]'e göre kullanıcıya gösterilecek kategori adı.
  String etiket(AppDil dil) => dil.sec(etiketTr, etiketEn);
}
