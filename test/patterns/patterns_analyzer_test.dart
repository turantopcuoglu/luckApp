import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/daily_archetype.dart';
import 'package:kader/core/content/experience_dimension.dart';
import 'package:kader/core/content/rare_sign_id.dart';
import 'package:kader/core/history/patterns_analyzer.dart';
import 'package:kader/core/history/patterns_summary.dart';
import 'package:kader/core/history/rare_sign_progress.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';

import 'patterns_fixture.dart';

RareSignProgress _sign(PatternsSummary summary, RareSignId id) =>
    summary.rareSigns.singleWhere((RareSignProgress sign) => sign.id == id);

// Kimlik değil bütün analitik çıktı karşılaştırılır; input sırası korunmalıdır.
List<Object?> _snapshot(PatternsSummary summary) => <Object?>[
  for (final RhythmDay day in summary.rhythm)
    <Object?>[
      day.date,
      day.participated,
      day.cardOpened,
      day.feedback,
      day.archetype,
    ],
  summary.feedback.values,
  summary.trend.previous.values,
  summary.trend.recent.values,
  summary.trend.direction,
  summary.trend.previousStart,
  summary.trend.recentStart,
  summary.trend.end,
  summary.participationDays,
  summary.currentStreak,
  summary.longestStreak,
  summary.archetypeCounts,
  summary.mostFrequentArchetypes,
  summary.mostFrequentDimensions,
  summary.latestRareSign?.id,
  for (final RareSignProgress sign in summary.rareSigns)
    <Object?>[
      sign.id,
      sign.condition,
      sign.current,
      sign.target,
      sign.eligibleOn,
      sign.evidenceAvailable,
    ],
];

void main() {
  final DateTime today = DateTime(2026, 9, 30);
  PatternsSummary analyze(List<DailyRecord> records, {DateTime? share}) =>
      analyzePatterns(records, today: today, firstSharedAt: share);

  test('boş veri: 30 boş gün, üç sıfır yanıt, 12 kilit; tema/seri yok', () {
    final PatternsSummary result = analyze(<DailyRecord>[]);
    expect(result.rhythm.length, 30);
    expect(result.rhythm.first.date, DateTime(2026, 9, 1));
    expect(result.rhythm.last.date, today);
    expect(result.rhythm.every((RhythmDay day) => !day.participated), isTrue);
    expect(
      result.rhythm.every((RhythmDay day) => day.feedback == null),
      isTrue,
    );
    expect(result.feedback.values.values, everyElement(0));
    expect(result.trend.direction, FeedbackTrendDirection.insufficient);
    expect(result.participationDays, 0);
    expect(result.currentStreak, 0);
    expect(result.longestStreak, 0);
    expect(result.mostFrequentArchetypes, isEmpty);
    expect(result.mostFrequentDimensions, isEmpty);
    expect(
      result.rareSigns.map((RareSignProgress sign) => sign.id),
      RareSignId.values,
    );
    expect(
      result.rareSigns.every((RareSignProgress sign) => !sign.isUnlocked),
      isTrue,
    );
    expect(result.latestRareSign, isNull);
  });

  for (final int count in <int>[1, 7, 30]) {
    test('$count günlük veride boş günler negatif feedback sayılmaz', () {
      final PatternsSummary result = analyze(<DailyRecord>[
        for (int i = 0; i < count; i++) patternRecord(30 - i),
      ]);
      expect(
        result.rhythm.where((RhythmDay day) => day.participated).length,
        count,
      );
      expect(result.participationDays, count);
      expect(result.feedback.total, 0);
      expect(result.currentStreak, count);
      expect(result.longestStreak, count);
      expect(result.archetypeCounts[DailyArchetype.akis], count);
    });
  }

  test(
    'pencere uçları dahil; eski katılım koleksiyonda, gelecek tamamen dışarıda',
    () {
      final PatternsSummary result = analyze(<DailyRecord>[
        patternRecord(0, mood: FeedbackMood.difficult),
        patternRecord(1, mood: FeedbackMood.positive),
        patternRecord(30, mood: FeedbackMood.neutral),
        patternRecord(31, mood: FeedbackMood.difficult, score: 100),
      ]);
      expect(result.participationDays, 3);
      expect(result.feedback.total, 2);
      expect(result.feedback.count(FeedbackMood.difficult), 0);
      expect(result.archetypeCounts[DailyArchetype.akis], 2);
      expect(_sign(result, RareSignId.sessizTohum).eligibleOn, today);
      expect(_sign(result, RareSignId.parlakYol).isUnlocked, isFalse);
    },
  );

  test('kapalı yüksek skor katılım, arketip veya ödül sızdırmaz', () {
    final PatternsSummary result = analyze(<DailyRecord>[
      patternRecord(30, opened: false, score: 100),
    ]);
    expect(result.participationDays, 0);
    expect(result.rhythm.last.archetype, isNull);
    expect(result.mostFrequentArchetypes, isEmpty);
    expect(
      result.rareSigns.every((RareSignProgress sign) => !sign.isUnlocked),
      isTrue,
    );
  });

  test('eski bool feedback katılımı korur ama açılış uydurmaz', () {
    final DailyRecord old = DailyRecord(
      sonuc: patternRecord(30, score: 100).sonuc,
      feedbackPozitif: true,
    );
    final PatternsSummary result = analyze(<DailyRecord>[old]);
    expect(result.participationDays, 1);
    expect(result.feedback.count(FeedbackMood.positive), 1);
    expect(result.rhythm.last.cardOpened, isFalse);
    expect(result.rhythm.last.archetype, isNull);
    expect(_sign(result, RareSignId.kesisenYollar).isUnlocked, isTrue);
    expect(_sign(result, RareSignId.acikKapi).isUnlocked, isFalse);
    expect(_sign(result, RareSignId.parlakYol).isUnlocked, isFalse);
    expect(old.revealedAt, isNull);
  });

  test(
    'gelecekteki açılış kanıtı sayılmaz; bugünkü feedback bağımsız kalır',
    () {
      final PatternsSummary result = analyze(<DailyRecord>[
        patternRecord(
          30,
          revealedAt: DateTime(2026, 10, 1),
          mood: FeedbackMood.neutral,
        ),
      ]);
      expect(result.participationDays, 1);
      expect(result.feedback.count(FeedbackMood.neutral), 1);
      expect(result.rhythm.last.cardOpened, isFalse);
      expect(_sign(result, RareSignId.acikKapi).isUnlocked, isFalse);
    },
  );

  for (final DateTime end in <DateTime>[
    DateTime(2028, 3, 1),
    DateTime(2027, 1, 1),
    DateTime(2026, 3, 31),
    DateTime(2026, 11, 1),
  ]) {
    test('$end takvim/ay/yıl/yaz saati sınırında kesintisiz 30 gün', () {
      final PatternsSummary result = analyzePatterns(
        <DailyRecord>[],
        today: end,
      );
      final DateTime utcEnd = DateTime.utc(end.year, end.month, end.day);
      for (int i = 0; i < 30; i++) {
        final DateTime expected = utcEnd.subtract(Duration(days: 29 - i));
        expect(
          result.rhythm[i].date,
          DateTime(expected.year, expected.month, expected.day),
        );
      }
    });
  }

  test('UTC/saat alanları takvim gününü değiştirmez', () {
    final PatternsSummary result = analyzePatterns(<DailyRecord>[
      patternRecord(30, date: DateTime.utc(2026, 9, 30, 23, 59)),
    ], today: DateTime(2026, 9, 30, 1));
    expect(result.rhythm.last.date, today);
    expect(result.participationDays, 1);
  });

  test(
    'aynı güne iki kayıt sıra-bağımsız reddedilir, çift katılım üretilmez',
    () {
      final DailyRecord a = patternRecord(30);
      final DailyRecord b = patternRecord(30, mood: FeedbackMood.neutral);
      for (final List<DailyRecord> records in <List<DailyRecord>>[
        [a, b],
        [b, a],
        [a, a],
      ]) {
        expect(() => analyze(records), throwsArgumentError);
      }
    },
  );

  test('tek boş gün seriyi korur, boş gün sayıya eklenmez', () {
    final PatternsSummary result = analyze(<DailyRecord>[
      patternRecord(25),
      patternRecord(27),
      patternRecord(28),
      patternRecord(30),
    ]);
    expect(result.currentStreak, 4);
    expect(result.longestStreak, 4);
    expect(_sign(result, RareSignId.geriDonenSerit).isUnlocked, isFalse);
  });

  test(
    'dün katılım mevcut seridir, iki gün önce artık mevcut seri değildir',
    () {
      expect(analyze(<DailyRecord>[patternRecord(29)]).currentStreak, 1);
      expect(analyze(<DailyRecord>[patternRecord(28)]).currentStreak, 0);
      expect(analyze(<DailyRecord>[patternRecord(28)]).longestStreak, 1);
    },
  );

  test(
    'iki boş gün seri ayırır ve ilk geri dönüş gününde kart koşulu sağlanır',
    () {
      final PatternsSummary result = analyze(<DailyRecord>[
        patternRecord(20),
        patternRecord(21),
        patternRecord(24),
        patternRecord(30),
      ]);
      expect(result.currentStreak, 1);
      expect(result.longestStreak, 2);
      expect(
        _sign(result, RareSignId.geriDonenSerit).eligibleOn,
        DateTime(2026, 9, 24),
      );
    },
  );

  test('arketip sıklığı eşitlerini korur; sıfır temalar eşitliğe girmez', () {
    final PatternsSummary result = analyze(<DailyRecord>[
      patternRecord(29, dimension: ExperienceDimension.bag),
      patternRecord(30, dimension: ExperienceDimension.denge),
    ]);
    expect(result.mostFrequentArchetypes, <DailyArchetype>[
      DailyArchetype.bag,
      DailyArchetype.denge,
    ]);
    expect(result.mostFrequentDimensions, <ExperienceDimension>[
      ExperienceDimension.bag,
      ExperienceDimension.denge,
    ]);
  });

  test('kart içindeki skor eşitliği mevcut motor enum kuralını kullanır', () {
    final DailyRecord record = DailyRecord(
      sonuc: LuckResult(
        gun: today,
        genelSkor: 50,
        kategoriSkorlari: <LuckCategory, int>{
          for (final LuckCategory c in LuckCategory.values.reversed) c: 50,
        },
        modifiyerler: const <LuckModifier>[],
      ),
      revealedAt: today,
    );
    expect(
      analyze(<DailyRecord>[record]).mostFrequentDimensions,
      <ExperienceDimension>[
        ExperienceDimension.kategoriden(LuckCategory.values.first),
      ],
    );
  });

  test('eksik kategori açılmış kartta sessizce yeni tema üretmez', () {
    final DailyRecord record = DailyRecord(
      sonuc: LuckResult(
        gun: today,
        genelSkor: 50,
        kategoriSkorlari: const <LuckCategory, int>{},
        modifiyerler: const <LuckModifier>[],
      ),
      revealedAt: today,
    );
    expect(() => analyze(<DailyRecord>[record]), throwsStateError);
  });

  test(
    '20 karışık permütasyon aynı tüm çıktıyı üretir, girdileri değiştirmez',
    () {
      final List<DailyRecord> records = <DailyRecord>[
        for (int i = -10; i <= 32; i++)
          patternRecord(
            i,
            opened: i % 3 != 0,
            mood: i % 2 == 0 ? FeedbackMood.values[i.abs() % 3] : null,
            dimension: ExperienceDimension.values[i.abs() % 5],
            score: i == 1 ? 92 : 50,
          ),
      ];
      final List<Object?> expected = _snapshot(analyze(records));
      final List<Map<String, dynamic>> before = records
          .map((DailyRecord r) => r.toMap())
          .toList();
      for (int i = 0; i < 20; i++) {
        final List<DailyRecord> shuffled = List<DailyRecord>.of(records)
          ..shuffle(Random(i));
        final List<DailyRecord> order = List<DailyRecord>.of(shuffled);
        expect(_snapshot(analyze(shuffled)), expected);
        expect(shuffled, order);
      }
      expect(records.map((DailyRecord r) => r.toMap()).toList(), before);
    },
  );

  test('çıktı koleksiyonları değiştirilemez', () {
    final PatternsSummary result = analyze(<DailyRecord>[patternRecord(30)]);
    expect(result.rhythm.clear, throwsUnsupportedError);
    expect(result.feedback.values.clear, throwsUnsupportedError);
    expect(result.archetypeCounts.clear, throwsUnsupportedError);
    expect(result.mostFrequentArchetypes.clear, throwsUnsupportedError);
    expect(result.mostFrequentDimensions.clear, throwsUnsupportedError);
    expect(result.rareSigns.clear, throwsUnsupportedError);
  });

  for (final (RareSignId id, int threshold, bool feedback)
      in <(RareSignId, int, bool)>[
        (RareSignId.sessizTohum, 3, false),
        (RareSignId.yeniPatika, 7, false),
        (RareSignId.acikPencere, 14, false),
        (RareSignId.beklenmedikDurak, 21, false),
        (RareSignId.kesisenYollar, 1, true),
        (RareSignId.dengeliTas, 5, true),
        (RareSignId.kucukKopru, 10, true),
      ]) {
    test('$id eşik altı, tam eşik ve üstü ilk koşul gününü korur', () {
      List<DailyRecord> records(int count) => <DailyRecord>[
        for (int i = 1; i <= count; i++)
          patternRecord(
            i,
            opened: !feedback,
            mood: feedback ? FeedbackMood.neutral : null,
          ),
      ];
      expect(_sign(analyze(records(threshold - 1)), id).isUnlocked, isFalse);
      final RareSignProgress exact = _sign(analyze(records(threshold)), id);
      final RareSignProgress above = _sign(analyze(records(threshold + 1)), id);
      expect(exact.eligibleOn, DateTime(2026, 9, threshold));
      expect(above.eligibleOn, exact.eligibleOn);
      expect(above.current, threshold);
      expect(exact.target, threshold);
    });
  }

  test('Parlak Yol 91 kilitli, 92 açık; gerçek açılış tarihi kullanılır', () {
    expect(
      _sign(
        analyze(<DailyRecord>[patternRecord(1, score: 91)]),
        RareSignId.parlakYol,
      ).isUnlocked,
      isFalse,
    );
    final PatternsSummary result = analyze(<DailyRecord>[
      patternRecord(1, score: 92, revealedAt: DateTime(2026, 9, 5)),
      patternRecord(3, score: 92),
    ]);
    expect(
      _sign(result, RareSignId.parlakYol).eligibleOn,
      DateTime(2026, 9, 3),
    );
    expect(_sign(result, RareSignId.acikKapi).eligibleOn, DateTime(2026, 9, 3));
  });

  test('beş arketip tüm geçmişte açılmış olmalı; tekrarlar sayılmaz', () {
    final List<DailyRecord> records = <DailyRecord>[
      for (int i = 0; i < 4; i++)
        patternRecord(i - 10, dimension: ExperienceDimension.values[i]),
      patternRecord(29, dimension: ExperienceDimension.akis),
    ];
    expect(_sign(analyze(records), RareSignId.yanYanaIzler).current, 4);
    records.add(patternRecord(30, dimension: ExperienceDimension.denge));
    expect(_sign(analyze(records), RareSignId.yanYanaIzler).eligibleOn, today);
  });

  test('ilk paylaşım yalnız açık kanıtla açılır; gelecek kanıt açmaz', () {
    final RareSignProgress empty = _sign(
      analyze(<DailyRecord>[]),
      RareSignId.ucanNot,
    );
    expect(empty.isUnlocked, isFalse);
    expect(empty.evidenceAvailable, isFalse);
    expect(
      _sign(
        analyze(<DailyRecord>[], share: today),
        RareSignId.ucanNot,
      ).eligibleOn,
      today,
    );
    expect(
      _sign(
        analyze(<DailyRecord>[], share: DateTime(2026, 10, 1)),
        RareSignId.ucanNot,
      ).isUnlocked,
      isFalse,
    );
  });

  test('son kart tarih eşitliğinde katalog sırası kararlıdır', () {
    final PatternsSummary result = analyze(<DailyRecord>[
      patternRecord(30, score: 100, mood: FeedbackMood.positive),
    ]);
    expect(result.latestRareSign?.id, RareSignId.acikKapi);
  });
}
