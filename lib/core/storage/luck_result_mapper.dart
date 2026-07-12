import '../luck_engine/luck_engine.dart';

/// [LuckResult] ile Hive'a yazılabilir map arasındaki dönüşümler.
///
/// Serileştirme depolama katmanında tutulur ki luck_engine saf kalsın
/// ve Hive'ın map temsili motora sızmasın (CLAUDE.md kural 3).
abstract final class LuckResultMapper {
  static const String _gunAnahtari = 'gun';
  static const String _genelSkorAnahtari = 'genelSkor';
  static const String _kategorilerAnahtari = 'kategoriler';
  static const String _modifiyerlerAnahtari = 'modifiyerler';
  static const String _adAnahtari = 'ad';
  static const String _etkiAnahtari = 'etki';

  /// [sonuc]u Hive'a yazılacak map'e çevirir.
  static Map<String, dynamic> toMap(LuckResult sonuc) => <String, dynamic>{
    _gunAnahtari: sonuc.gun.toIso8601String(),
    _genelSkorAnahtari: sonuc.genelSkor,
    _kategorilerAnahtari: <String, int>{
      for (final MapEntry<LuckCategory, int> e
          in sonuc.kategoriSkorlari.entries)
        e.key.name: e.value,
    },
    _modifiyerlerAnahtari: <Map<String, dynamic>>[
      for (final LuckModifier m in sonuc.modifiyerler)
        <String, dynamic>{_adAnahtari: m.ad, _etkiAnahtari: m.etki},
    ],
  };

  /// Hive'dan okunan [map]'ten [LuckResult] kurar.
  static LuckResult fromMap(Map<dynamic, dynamic> map) {
    final Map<dynamic, dynamic> kategoriler =
        map[_kategorilerAnahtari] as Map<dynamic, dynamic>;
    final List<dynamic> modifiyerler =
        map[_modifiyerlerAnahtari] as List<dynamic>;

    return LuckResult(
      gun: DateTime.parse(map[_gunAnahtari] as String),
      genelSkor: map[_genelSkorAnahtari] as int,
      kategoriSkorlari: <LuckCategory, int>{
        for (final MapEntry<dynamic, dynamic> e in kategoriler.entries)
          LuckCategory.values.byName(e.key as String): e.value as int,
      },
      modifiyerler: <LuckModifier>[
        for (final dynamic ham in modifiyerler)
          LuckModifier(
            ad: (ham as Map<dynamic, dynamic>)[_adAnahtari] as String,
            etki: ham[_etkiAnahtari] as int,
          ),
      ],
    );
  }
}
