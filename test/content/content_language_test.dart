import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/category_pools.dart';
import 'package:kader/core/content/daily_archetype.dart';
import 'package:kader/core/content/experience_dimension.dart';
import 'package:kader/core/content/fortune_pools.dart';
import 'package:kader/core/content/mission_pools.dart';
import 'package:kader/core/localization/app_dil.dart';

void main() {
  test('Türkçe görevlerde yapay emir-virgül devrikliği geri gelmez', () {
    for (final List<MicroMission> missions in MissionPools.byDimension.values) {
      for (final MicroMission mission in missions) {
        expect(
          RegExp(r'^[^,]{2,16}, ').hasMatch(mission.instruction.tr),
          isFalse,
          reason: mission.instruction.tr,
        );
      }
    }
  });
  test('her alanda 20 benzersiz iki dilli görev ve kararlı kimlik vardır', () {
    final Set<String> ids = {};
    final Set<String> turkish = {};
    final Set<String> english = {};
    expect(
      MissionPools.byDimension.keys.toSet(),
      ExperienceDimension.values.toSet(),
    );
    for (final entry in MissionPools.byDimension.entries) {
      expect(
        entry.value.length,
        greaterThanOrEqualTo(MissionPools.minimumPerDimension),
      );
      expect(entry.value.length % MissionPools.dayGroupCount, 0);
      for (final MicroMission mission in entry.value) {
        expect(mission.dimension, entry.key);
        expect(ids.add(mission.id), isTrue);
        expect(
          mission.id,
          matches(
            RegExp(
              '^${entry.key.name}_[0-9]{2}'
              r'$',
            ),
          ),
        );
        expect(turkish.add(mission.instruction.tr), isTrue);
        expect(english.add(mission.instruction.en), isTrue);
        expect(mission.instruction.tr.trim(), isNotEmpty);
        expect(mission.instruction.en.trim(), isNotEmpty);
        expect(mission.instruction.text(AppDil.tr), mission.instruction.tr);
        expect(mission.instruction.text(AppDil.en), mission.instruction.en);
      }
    }
  });

  test(
    'yeni ve mevcut ekranlara verilen metinlerde kehanet ve garanti dili yok',
    () {
      // Bu kontrol editoryal incelemeye ek bir regresyon ağıdır; her olası
      // zararlı ifadeyi yakaladığı iddia edilmez. Sözcük sınırları yanlış
      // eşleşmeleri (ör. farklı içinde fal) önler.
      final RegExp banned = RegExp(
        r'(?<![\p{L}\p{N}_])(fal[ıi]?n?(da)?|falcı|burç\w*|kehanet\w*|tarot|astroloji\w*|'
        r'evren senden|yıldızlar|şans senden yana|uğur getirecek|'
        r'kesin kazan|garantili|bahis|kumar|yatırım yap|'
        r'horoscope\w*|zodiac|prophecy|fortune.telling|guaranteed|'
        r'you will win|the universe wants|bet money|buy stocks)(?![\p{L}\p{N}_])',
        caseSensitive: false,
        unicode: true,
      );
      for (final AppDil dil in AppDil.values) {
        final List<String> texts = [
          for (final pool in FortunePools.acilisCumleleri(dil).values) ...pool,
          ...FortunePools.kapanisCumleleri(dil),
          ...FortunePools.gununTavsiyeleri(dil),
          for (final tones in FortunePools.ortaCumleleri(dil).values)
            for (final pool in tones.values) ...pool,
          for (final tones in CategoryPools.kategoriAcilislari(dil).values)
            for (final pool in tones.values) ...pool,
          for (final pool in CategoryPools.kategoriTavsiyeleri(dil).values)
            ...pool,
          for (final archetype in DailyArchetype.values) ...[
            archetype.title(dil),
            archetype.reflection(dil),
          ],
        ];
        for (final String text in texts) {
          expect(banned.hasMatch(text), isFalse, reason: text);
        }
      }
      // Yasak örnekler regex'in yanlışlıkla etkisizleşmesini yakalar.
      for (final String text in [
        'Bugün falında para var.',
        'Yıldızlar sana yol gösteriyor.',
        'Your horoscope is ready.',
        'A guaranteed win.',
        'Şans senden yana.',
      ]) {
        expect(banned.hasMatch(text), isTrue, reason: text);
      }
    },
  );
}
