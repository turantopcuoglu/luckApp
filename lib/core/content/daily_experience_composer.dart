import '../localization/app_dil.dart';
import '../luck_engine/luck_engine.dart';
import 'daily_archetype.dart';
import 'daily_experience.dart';
import 'experience_dimension.dart';
import 'mission_pools.dart';

/// Saklanmış sonucu arketip ve mikro görevle birleştirir; motor skoru üretmez.
DailyExperience composeDailyExperience({
  required LuckEngine motor,
  required UserSeed kullanici,
  required LuckResult sonuc,
  required AppDil dil,
}) {
  final DateTime date = DateTime(
    sonuc.gun.year,
    sonuc.gun.month,
    sonuc.gun.day,
  );
  final ExperienceDimension dimension = ExperienceDimension.baskinAlan(sonuc);
  final DailyArchetype archetype = DailyArchetype.forDimension(dimension);
  final List<MicroMission> pool = MissionPools.byDimension[dimension]!;

  // UTC yalnız takvim sıra numarası içindir; yerel günü UTC'ye çevirmeyiz.
  // Böylece saat dilimi/DST gün sınırını ve dönüşümlü grubu değiştirmez.
  final int dayNumber = DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(1970)).inDays;
  final int group = dayNumber % MissionPools.dayGroupCount;
  final List<MicroMission> candidates = [
    for (int i = group; i < pool.length; i += MissionPools.dayGroupCount)
      pool[i],
  ];
  // Eski seçim yöntemi önceki ham indeksi kontrol eder; gruplar ise önceki
  // nihai seçimle çakışmayı da önler. Havuz sırası ve kimlikler sürümlüdür.
  final MicroMission mission =
      candidates[motor.tekrarsizSecimIndeksi(
        kullanici: kullanici,
        gun: date,
        amac: '${MissionPools.selectionVersion}:${dimension.name}',
        havuzBoyutu: candidates.length,
      )];

  return DailyExperience(
    date: date,
    score: sonuc.genelSkor,
    archetype: archetype,
    orderedDimensions: [
      for (final ExperienceDimension alan in ExperienceDimension.gosterimSirasi)
        (dimension: alan, score: alan.skor(sonuc)),
    ],
    microMissionId: mission.id,
    microMission: mission.instruction.text(dil),
    shortReflection: archetype.reflection(dil),
  );
}
