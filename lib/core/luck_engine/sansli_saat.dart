/// Bir kategorinin günlük "şanslı saat aralığı".
///
/// Motor tarafından seed'den deterministik üretilir (plan Session 9,
/// madde 1): aynı (kullanıcı, gün, kategori) üçlüsü her zaman aynı
/// aralığı verir.
class SansliSaat {
  /// [baslangicSaati] ve [bitisSaati] (24 saat, tam saat) ile aralık
  /// oluşturur.
  const SansliSaat({required this.baslangicSaati, required this.bitisSaati});

  /// Aralığın başladığı saat (0-23).
  final int baslangicSaati;

  /// Aralığın bittiği saat (0-23).
  final int bitisSaati;

  /// Kullanıcıya gösterilecek "14:00 - 16:00" biçimli etiket.
  String get etiket =>
      '${_saatMetni(baslangicSaati)} - ${_saatMetni(bitisSaati)}';

  static String _saatMetni(int saat) =>
      '${saat.toString().padLeft(2, '0')}:00';

  @override
  bool operator ==(Object other) =>
      other is SansliSaat &&
      other.baslangicSaati == baslangicSaati &&
      other.bitisSaati == bitisSaati;

  @override
  int get hashCode => Object.hash(baslangicSaati, bitisSaati);

  @override
  String toString() => 'SansliSaat($etiket)';
}
