import 'luck_category.dart';
import 'luck_modifier.dart';

/// Motorun bir gün için ürettiği tam sonuç.
class LuckResult {
  /// Tüm alanlarıyla bir sonuç oluşturur.
  ///
  /// [kategoriSkorlari] ve [modifiyerler] değiştirilemez kopyalar
  /// olarak saklanır.
  LuckResult({
    required this.gun,
    required this.genelSkor,
    required Map<LuckCategory, int> kategoriSkorlari,
    required List<LuckModifier> modifiyerler,
  }) : kategoriSkorlari = Map.unmodifiable(kategoriSkorlari),
       modifiyerler = List.unmodifiable(modifiyerler);

  /// Sonucun ait olduğu gün (yalnızca tarih kısmı anlamlıdır).
  final DateTime gun;

  /// 0-100 arası genel skor: kategori skorlarının ağırlıklı ortalaması.
  final int genelSkor;

  /// Her kategorinin 0-100 arası skoru.
  final Map<LuckCategory, int> kategoriSkorlari;

  /// Bugünün skoruna etki eden modifiyerler (açıklama metni için).
  final List<LuckModifier> modifiyerler;

  @override
  String toString() =>
      'LuckResult(gun: $gun, genel: $genelSkor, '
      'kategoriler: $kategoriSkorlari, modifiyerler: $modifiyerler)';
}
