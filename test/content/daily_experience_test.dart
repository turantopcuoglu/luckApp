import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/daily_archetype.dart';
import 'package:kader/core/content/daily_experience.dart';
import 'package:kader/core/content/daily_experience_composer.dart';
import 'package:kader/core/content/experience_dimension.dart';
import 'package:kader/core/content/mission_pools.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

class _ScoreForbiddenEngine extends LuckEngine {
  @override
  LuckResult hesapla({
    required UserSeed kullanici,
    required DateTime gun,
    List<int> sonUcGunSkorlari = const <int>[],
  }) => throw StateError('Saklanmış skor yeniden hesaplanmamalı.');
}

void main() {
  const LuckEngine motor = LuckEngine();
  final UserSeed user = UserSeed.fromIsim(
    isim: 'İpek',
    dogumTarihi: DateTime(1996, 2, 29),
  );
  final DateTime start = DateTime(2026, 9, 5);

  LuckResult stored(ExperienceDimension dominant, DateTime day) => LuckResult(
    gun: day,
    genelSkor: 17,
    kategoriSkorlari: {
      for (final kategori in LuckCategory.values.reversed)
        kategori: kategori == dominant.kategori ? 93 : 42,
    },
    modifiyerler: const [],
  );

  DailyExperience compose(LuckResult result, [AppDil language = AppDil.tr]) =>
      composeDailyExperience(
        motor: motor,
        kullanici: user,
        sonuc: result,
        dil: language,
      );

  test(
    '30 günde aynı girdi eşit içerik ve hash üretir; dil kimlikleri korur',
    () {
      for (int i = 0; i < 30; i++) {
        final DateTime day = DateTime(start.year, start.month, start.day + i);
        final LuckResult result = motor.hesapla(kullanici: user, gun: day);
        final DailyExperience tr = compose(result);
        final DailyExperience repeated = compose(result);
        final DailyExperience en = compose(result, AppDil.en);
        expect(tr, repeated);
        expect(tr.hashCode, repeated.hashCode);
        expect(tr.score, result.genelSkor);
        expect(tr.date, day);
        expect(en.archetype, tr.archetype);
        expect(en.orderedDimensions, tr.orderedDimensions);
        expect(en.microMissionId, tr.microMissionId);
        expect(en.illustrationId, tr.illustrationId);
        expect(en.cardVariantId, tr.cardVariantId);
        expect(en.microMission, isNot(tr.microMission));
        expect(tr.shortReflection, isNotEmpty);
        expect(en.shortReflection, isNotEmpty);
        final MicroMission mission = MissionPools
            .byDimension[tr.dominantDimension]!
            .singleWhere((MicroMission m) => m.id == tr.microMissionId);
        expect(tr.microMission, mission.instruction.tr);
        expect(en.microMission, mission.instruction.en);
        expect(
          File(
            'assets/images/archetypes/${tr.illustrationId}.webp',
          ).existsSync(),
          isTrue,
        );
      }
    },
  );

  test(
    'saklanmış skor, kategori sırası ve arketip yeniden hesaplanmadan kullanılır',
    () {
      for (final dimension in ExperienceDimension.values) {
        final LuckResult result = stored(dimension, start);
        final DailyExperience experience = composeDailyExperience(
          motor: _ScoreForbiddenEngine(),
          kullanici: user,
          sonuc: result,
          dil: AppDil.tr,
        );
        expect(experience.score, 17);
        expect(experience.dominantDimension, dimension);
        expect(experience.archetype, DailyArchetype.forDimension(dimension));
        expect(
          experience.orderedDimensions.map((d) => d.dimension),
          ExperienceDimension.gosterimSirasi,
        );
        for (final item in experience.orderedDimensions) {
          expect(item.score, result.kategoriSkorlari[item.dimension.kategori]);
        }
      }
    },
  );

  test('beş arketip doğru TR/EN başlık ve gerçek illüstrasyon taşır', () {
    expect(DailyArchetype.values.map((a) => a.title(AppDil.tr)), [
      'Akış Günü',
      'Bağ Günü',
      'Üretim Günü',
      'Cesaret Günü',
      'Denge Günü',
    ]);
    expect(DailyArchetype.values.map((a) => a.title(AppDil.en)), [
      'Flow Day',
      'Connection Day',
      'Creation Day',
      'Courage Day',
      'Balance Day',
    ]);
    expect(
      DailyArchetype.values.map((a) => a.dimension).toSet(),
      ExperienceDimension.values.toSet(),
    );
  });

  test(
    'her alanda bir yıl ardışık görev tekrarı yok ve 20 görevin tümü ulaşılabilir',
    () {
      // Artık gün, yıl ve ay sınırları takvim gününe göre seçimi de kapsar.
      for (final dimension in ExperienceDimension.values) {
        String? previous;
        final Set<String> seen = {};
        for (int i = 0; i < 366; i++) {
          final DailyExperience experience = compose(
            stored(dimension, DateTime(2024, 1, 1 + i)),
          );
          expect(experience.microMissionId, isNot(previous));
          previous = experience.microMissionId;
          seen.add(experience.microMissionId);
        }
        expect(
          seen,
          MissionPools.byDimension[dimension]!.map((m) => m.id).toSet(),
        );
      }
    },
  );

  test('saat ve UTC işareti aynı takvim günü için seçimi değiştirmez', () {
    final DailyExperience morning = compose(
      stored(ExperienceDimension.akis, DateTime(2024, 3, 31, 1)),
    );
    final DailyExperience evening = compose(
      stored(ExperienceDimension.akis, DateTime(2024, 3, 31, 23, 59)),
    );
    final DailyExperience utc = compose(
      stored(ExperienceDimension.akis, DateTime.utc(2024, 3, 31, 23, 59)),
    );
    expect(evening, morning);
    expect(utc, morning);
  });

  test(
    'gösterim listesi değiştirilemez ve map ekleme sırası içeriği etkilemez',
    () {
      final LuckResult reversed = stored(ExperienceDimension.bag, start);
      final LuckResult forward = LuckResult(
        gun: start,
        genelSkor: reversed.genelSkor,
        kategoriSkorlari: {
          for (final k in LuckCategory.values) k: reversed.kategoriSkorlari[k]!,
        },
        modifiyerler: const [],
      );
      final DailyExperience experience = compose(reversed);
      expect(experience, compose(forward));
      expect(experience.orderedDimensions.clear, throwsUnsupportedError);
      final List<DimensionScore> source = [...experience.orderedDimensions];
      final DailyExperience copy = DailyExperience(
        date: experience.date,
        score: experience.score,
        archetype: experience.archetype,
        orderedDimensions: source,
        microMissionId: experience.microMissionId,
        microMission: experience.microMission,
        shortReflection: experience.shortReflection,
      );
      source.clear();
      expect(copy, experience);
      expect(copy.hashCode, experience.hashCode);
    },
  );

  test('eksik skorla sessizce içerik üretilmez', () {
    expect(
      () => compose(
        LuckResult(
          gun: start,
          genelSkor: 50,
          kategoriSkorlari: const {},
          modifiyerler: const [],
        ),
      ),
      throwsStateError,
    );
  });
}
