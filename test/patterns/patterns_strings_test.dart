import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/rare_sign_id.dart';
import 'package:kader/core/history/patterns_analyzer.dart';
import 'package:kader/core/history/patterns_summary.dart';
import 'package:kader/core/history/rare_sign_progress.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/features/patterns/patterns_strings.dart';

import 'patterns_fixture.dart';

void main() {
  final DateTime today = DateTime(2026, 9, 30);
  final PatternsSummary empty = analyzePatterns(<DailyRecord>[], today: today);
  for (final AppDil language in AppDil.values) {
    test(
      '$language boş ve eski geçmişin metinleri yargılamaz; kapsamı ayırır',
      () {
        final PatternsSummary old = analyzePatterns(<DailyRecord>[
          patternRecord(0),
        ], today: today);
        expect(PatternsStrings.participation(empty, language), isNotEmpty);
        expect(PatternsStrings.participation(old, language), contains('30'));
        expect(PatternsStrings.participation(old, language), contains('0'));
        expect(PatternsStrings.participation(old, language), contains('1'));
        expect(
          PatternsStrings.streak(empty, language),
          PatternsStrings.streak(old, language),
        );
        expect(PatternsStrings.streak(empty, language), isNot(contains('0')));
        expect(PatternsStrings.frequentThemes(empty, language), contains('30'));
        final PatternsSummary active = analyzePatterns(<DailyRecord>[
          patternRecord(30),
        ], today: today);
        expect(
          PatternsStrings.frequentThemes(active, language),
          contains(active.mostFrequentArchetypes.first.title(language)),
        );
        expect(PatternsStrings.streak(active, language), contains('1'));
      },
    );

    test(
      '$language tüm nadir başlıklar ve açıklamalar var, adlar benzersiz',
      () {
        final Set<String> titles = <String>{};
        for (final RareSignProgress sign in empty.rareSigns) {
          titles.add(PatternsStrings.rareTitle(sign.id, language));
          expect(PatternsStrings.rareCondition(sign, language), isNotEmpty);
        }
        expect(titles.length, RareSignId.values.length);
        expect(titles, everyElement(isNotEmpty));
      },
    );

    test(
      '$language her trend yönü örnek sayılarını ve skor ayrımını anlatır',
      () {
        final Set<String> descriptions = <String>{};
        for (final FeedbackTrendDirection direction
            in FeedbackTrendDirection.values) {
          final FeedbackTrend trend = FeedbackTrend(
            previousStart: today,
            recentStart: today,
            end: today,
            previous: FeedbackDistribution(<FeedbackMood>[
              FeedbackMood.neutral,
            ]),
            recent: FeedbackDistribution(<FeedbackMood>[
              FeedbackMood.neutral,
              FeedbackMood.positive,
            ]),
            direction: direction,
          );
          final String text = PatternsStrings.feedbackTrend(trend, language);
          descriptions.add(text);
          expect(text, contains('1'));
          expect(text, contains('2'));
          expect(
            text,
            contains(language.sec('doğruluğunu ölçmez', 'not a measure')),
          );
          expect(text, isNot(contains('%')));
        }
        expect(descriptions.length, FeedbackTrendDirection.values.length);
      },
    );
  }
  test('TR ve EN ayrı metin üretir', () {
    expect(
      PatternsStrings.participation(empty, AppDil.tr),
      isNot(PatternsStrings.participation(empty, AppDil.en)),
    );
    for (final RareSignProgress sign in empty.rareSigns) {
      expect(
        PatternsStrings.rareTitle(sign.id, AppDil.tr),
        isNot(PatternsStrings.rareTitle(sign.id, AppDil.en)),
      );
      expect(
        PatternsStrings.rareCondition(sign, AppDil.tr),
        isNot(PatternsStrings.rareCondition(sign, AppDil.en)),
      );
    }
  });
}
