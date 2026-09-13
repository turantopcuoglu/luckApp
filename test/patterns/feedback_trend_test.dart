import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/history/patterns_analyzer.dart';
import 'package:kader/core/history/patterns_summary.dart';
import 'package:kader/core/storage/daily_record.dart';

import 'patterns_fixture.dart';

void main() {
  const FeedbackMood p = FeedbackMood.positive;
  const FeedbackMood n = FeedbackMood.neutral;
  const FeedbackMood d = FeedbackMood.difficult;
  FeedbackTrend trend(List<FeedbackMood> previous, List<FeedbackMood> recent) =>
      analyzePatterns(<DailyRecord>[
        for (int i = 0; i < previous.length; i++)
          patternRecord(17 + i, mood: previous[i]),
        for (int i = 0; i < recent.length; i++)
          patternRecord(24 + i, mood: recent[i]),
      ], today: DateTime(2026, 9, 30)).trend;

  for (final (
        String name,
        List<FeedbackMood> before,
        List<FeedbackMood> after,
        FeedbackTrendDirection direction,
      )
      in <
        (String, List<FeedbackMood>, List<FeedbackMood>, FeedbackTrendDirection)
      >[
        (
          'önceki yetersiz',
          [p, p],
          [p, p, p],
          FeedbackTrendDirection.insufficient,
        ),
        (
          'sonraki yetersiz',
          [d, d, d],
          [p, p],
          FeedbackTrendDirection.insufficient,
        ),
        ('her ikisi boş', [], [], FeedbackTrendDirection.insufficient),
        (
          'pozitif artış',
          [d, n, p],
          [p, p, p],
          FeedbackTrendDirection.morePositive,
        ),
        (
          'zorlayıcı artış',
          [p, p, p],
          [d, n, p],
          FeedbackTrendDirection.moreDifficult,
        ),
        (
          'nötrde sabit',
          [n, n, n],
          [n, n, n, n],
          FeedbackTrendDirection.unchanged,
        ),
        (
          'farklı toplam aynı oran',
          [p, n, d],
          [p, p, n, n, d, d],
          FeedbackTrendDirection.unchanged,
        ),
        (
          'iki uç birlikte artar',
          [n, n, n],
          [p, d, n],
          FeedbackTrendDirection.mixed,
        ),
        (
          'iki uç birlikte azalır',
          [p, d, n],
          [n, n, n],
          FeedbackTrendDirection.mixed,
        ),
        (
          'yalnız zorlayıcı azalır',
          [d, d, n],
          [d, n, n],
          FeedbackTrendDirection.morePositive,
        ),
        (
          'yalnız pozitif azalır',
          [p, p, n],
          [p, n, n],
          FeedbackTrendDirection.moreDifficult,
        ),
        (
          'ham sayılar değil oran karşılaştırılır',
          [p, p, n],
          [p, p, p, n, n, n, n],
          FeedbackTrendDirection.moreDifficult,
        ),
      ]) {
    test(name, () => expect(trend(before, after).direction, direction));
  }

  test('ardışık pencereler uçları dahil doğru günleri sayar', () {
    final PatternsSummary result = analyzePatterns(<DailyRecord>[
      patternRecord(16, mood: d),
      patternRecord(17, mood: p),
      patternRecord(23, mood: n),
      patternRecord(24, mood: d),
      patternRecord(30, mood: p),
      patternRecord(31, mood: d),
    ], today: DateTime(2026, 9, 30));
    expect(result.trend.previousStart, DateTime(2026, 9, 17));
    expect(result.trend.recentStart, DateTime(2026, 9, 24));
    expect(result.trend.end, DateTime(2026, 9, 30));
    expect(result.trend.previous.total, 2);
    expect(result.trend.previous.count(d), 0);
    expect(result.trend.recent.total, 2);
    expect(result.trend.recent.count(d), 1);
    expect(result.feedback.total, 5);
  });

  test('skor değişimi feedback sayıları ve yönünü etkilemez', () {
    PatternsSummary summary(int score) => analyzePatterns(<DailyRecord>[
      for (int i = 17; i <= 30; i++)
        patternRecord(i, score: score, mood: i < 24 ? d : p),
    ], today: DateTime(2026, 9, 30));
    final PatternsSummary low = summary(1);
    final PatternsSummary high = summary(100);
    expect(low.feedback.values, high.feedback.values);
    expect(low.trend.direction, high.trend.direction);
    expect(low.trend.direction, FeedbackTrendDirection.morePositive);
  });
}
