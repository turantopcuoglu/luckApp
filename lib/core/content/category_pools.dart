import '../localization/app_dil.dart';
import '../luck_engine/luck_category.dart';
import 'content_config.dart';
import 'experience_dimension.dart';
import 'mission_pools.dart';
import 'reflection_pools.dart';

/// Eski kategori detaylarını yeni deneyim diline bağlayan uyumluluk havuzları.
abstract final class CategoryPools {
  /// Alan ve tona bağlı cümleler; TR/EN kayıt sırası ortak kaynaktan gelir.
  static Map<LuckCategory, Map<KategoriTonu, List<String>>> kategoriAcilislari(
    AppDil dil,
  ) => Map.unmodifiable({
    for (final alan in ExperienceDimension.gosterimSirasi)
      alan.kategori: Map<KategoriTonu, List<String>>.unmodifiable({
        for (final ton in KategoriTonu.values)
          ton: ReflectionPools.forTone(alan, ton, dil),
      }),
  });

  /// Kategorinin yeni alanına ait kısa ve isteğe bağlı eylemler.
  static Map<LuckCategory, List<String>> kategoriTavsiyeleri(AppDil dil) =>
      Map.unmodifiable({
        for (final alan in ExperienceDimension.gosterimSirasi)
          alan.kategori: List<String>.unmodifiable(
            MissionPools.byDimension[alan]!.map(
              (MicroMission mission) => mission.instruction.text(dil),
            ),
          ),
      });
}
