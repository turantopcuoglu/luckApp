import '../content/daily_archetype.dart';
import '../content/experience_dimension.dart';
import '../content/rare_sign_id.dart';
import '../storage/daily_record.dart';
import 'patterns_config.dart';
import 'patterns_summary.dart';
import 'rare_sign_progress.dart';

// UTC yalnız takvim aritmetiğidir: girişleri toUtc ile başka güne çevirmeyiz.
int _ordinal(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

DateTime _date(int ordinal) {
  final DateTime utc = DateTime.fromMillisecondsSinceEpoch(
    ordinal * Duration.millisecondsPerDay,
    isUtc: true,
  );
  return DateTime(utc.year, utc.month, utc.day);
}

bool _opened(DailyRecord record, int end) =>
    record.revealedAt != null && _ordinal(record.revealedAt!) <= end;

DailyArchetype _archetype(DailyRecord record) =>
    DailyArchetype.forDimension(ExperienceDimension.baskinAlan(record.sonuc));

/// Saklanmış kayıtları sıralamadan/değiştirmeden Desenlerim verisine dönüştürür.
///
/// [today] açık ve zorunludur; saat okumaz. Gelecek günler dışlanır. Kart
/// üretimi tek başına katılım değildir: açılış veya feedback gerekir. Eski
/// feedback katılımı korur ama açılış/arketip kanıtı olarak uydurulmaz.
///
/// Repository sözleşmesi gibi her takvim günü tek kayıt olmalıdır. Aynı
/// güne birden fazla girdi [ArgumentError] üretir; sıra-bağımlı bir kazanan
/// seçilmez. [firstSharedAt] yalnız kalıcı, doğrulanmış paylaşım kanıtıdır;
/// null olduğunda Uçan Not kilitli ve kanıtı mevcut değil durumunda kalır.
PatternsSummary analyzePatterns(
  Iterable<DailyRecord> records, {
  required DateTime today,
  DateTime? firstSharedAt,
}) {
  final int end = _ordinal(today);
  final int start = end - PatternsConfig.rhythmDays + 1;
  final Map<int, DailyRecord> byDay = <int, DailyRecord>{};
  for (final DailyRecord record in records) {
    final int day = _ordinal(record.gun);
    if (day > end) continue;
    if (byDay.containsKey(day)) {
      throw ArgumentError('Her takvim günü için yalnız bir kayıt gerekir.');
    }
    byDay[day] = record;
  }
  final List<int> days = byDay.keys.toList()..sort();
  final List<int> participation = <int>[];
  final List<int> feedbackDays = <int>[];
  final List<DailyRecord> opened = <DailyRecord>[];
  final Map<DailyArchetype, int> counts = <DailyArchetype, int>{
    for (final DailyArchetype archetype in DailyArchetype.values) archetype: 0,
  };
  for (final int day in days) {
    final DailyRecord record = byDay[day]!;
    final bool isOpened = _opened(record, end);
    if (isOpened || record.feedbackMood != null) participation.add(day);
    if (record.feedbackMood != null) feedbackDays.add(day);
    if (isOpened) {
      opened.add(record);
      if (day >= start) {
        final DailyArchetype archetype = _archetype(record);
        counts[archetype] = counts[archetype]! + 1;
      }
    }
  }
  final List<RhythmDay> rhythm = <RhythmDay>[
    for (int day = start; day <= end; day++)
      RhythmDay(
        date: _date(day),
        participated:
            byDay[day] != null &&
            (_opened(byDay[day]!, end) || byDay[day]!.feedbackMood != null),
        cardOpened: byDay[day] != null && _opened(byDay[day]!, end),
        feedback: byDay[day]?.feedbackMood,
        archetype: byDay[day] != null && _opened(byDay[day]!, end)
            ? _archetype(byDay[day]!)
            : null,
      ),
  ];
  FeedbackDistribution distribution(int from, int to) => FeedbackDistribution(
    feedbackDays
        .where((int day) => day >= from && day <= to)
        .map((int day) => byDay[day]!.feedbackMood!),
  );
  final int recentStart = end - PatternsConfig.trendDays + 1;
  final int previousStart = recentStart - PatternsConfig.trendDays;
  final FeedbackDistribution recent = distribution(recentStart, end);
  final FeedbackDistribution previous = distribution(
    previousStart,
    recentStart - 1,
  );
  int streak = 0;
  int longest = 0;
  int? last;
  for (final int day in participation) {
    streak = last != null && day - last <= PatternsConfig.graceDays + 1
        ? streak + 1
        : 1;
    if (streak > longest) longest = streak;
    last = day;
  }
  final int maxCount = counts.values.fold(
    0,
    (int max, int count) => count > max ? count : max,
  );
  return PatternsSummary(
    rhythm: rhythm,
    feedback: distribution(start, end),
    trend: FeedbackTrend(
      previousStart: _date(previousStart),
      recentStart: _date(recentStart),
      end: _date(end),
      previous: previous,
      recent: recent,
      direction: _trend(previous, recent),
    ),
    participationDays: participation.length,
    currentStreak: last != null && end - last <= PatternsConfig.graceDays
        ? streak
        : 0,
    longestStreak: longest,
    archetypeCounts: counts,
    mostFrequentArchetypes: <DailyArchetype>[
      if (maxCount > 0)
        for (final DailyArchetype archetype in DailyArchetype.values)
          if (counts[archetype] == maxCount) archetype,
    ],
    rareSigns: _rareSigns(
      participation,
      feedbackDays,
      opened,
      firstSharedAt,
      end,
    ),
  );
}

FeedbackTrendDirection _trend(
  FeedbackDistribution previous,
  FeedbackDistribution recent,
) {
  if (previous.total < PatternsConfig.minimumTrendResponses ||
      recent.total < PatternsConfig.minimumTrendResponses) {
    return FeedbackTrendDirection.insufficient;
  }
  // Çapraz çarpım farklı yanıt sayılarını dengeler; float/eşik hatası yoktur.
  int change(FeedbackMood mood) =>
      recent.count(mood) * previous.total - previous.count(mood) * recent.total;
  final int positive = change(FeedbackMood.positive);
  final int difficult = change(FeedbackMood.difficult);
  if (positive == 0 && difficult == 0) {
    return FeedbackTrendDirection.unchanged;
  }
  if (positive >= 0 && difficult <= 0) {
    return FeedbackTrendDirection.morePositive;
  }
  if (positive <= 0 && difficult >= 0) {
    return FeedbackTrendDirection.moreDifficult;
  }
  return FeedbackTrendDirection.mixed;
}

List<RareSignProgress> _rareSigns(
  List<int> participation,
  List<int> feedbackDays,
  List<DailyRecord> opened,
  DateTime? firstSharedAt,
  int end,
) {
  // Gecikmiş bir açılış, kartın ait olduğu tarihte açılmış gibi gösterilmez.
  int revealDay(DailyRecord record) {
    final int day = _ordinal(record.gun);
    final int reveal = _ordinal(record.revealedAt!);
    return reveal > day ? reveal : day;
  }

  opened.sort((DailyRecord a, DailyRecord b) {
    final int order = revealDay(a).compareTo(revealDay(b));
    return order != 0 ? order : _ordinal(a.gun).compareTo(_ordinal(b.gun));
  });
  final List<int> reveals = opened.map(revealDay).toList();
  final List<int> returns = <int>[
    for (int i = 1; i < participation.length; i++)
      if (participation[i] - participation[i - 1] >=
          PatternsConfig.returnGapDays)
        participation[i],
  ];
  final Set<DailyArchetype> seen = <DailyArchetype>{};
  final List<int> newArchetypes = <int>[];
  for (final DailyRecord record in opened) {
    if (seen.add(_archetype(record))) newArchetypes.add(revealDay(record));
  }
  RareSignProgress milestone(
    RareSignId id,
    RareSignCondition condition,
    List<int> evidence,
    int target, {
    bool evidenceAvailable = true,
  }) => RareSignProgress(
    id: id,
    condition: condition,
    current: evidence.length < target ? evidence.length : target,
    target: target,
    eligibleOn: evidence.length >= target ? _date(evidence[target - 1]) : null,
    evidenceAvailable: evidenceAvailable,
  );
  final List<int> sharing = <int>[
    if (firstSharedAt != null && _ordinal(firstSharedAt) <= end)
      _ordinal(firstSharedAt),
  ];
  return <RareSignProgress>[
    milestone(RareSignId.acikKapi, RareSignCondition.firstReveal, reveals, 1),
    milestone(
      RareSignId.kesisenYollar,
      RareSignCondition.feedbackDays,
      feedbackDays,
      1,
    ),
    milestone(
      RareSignId.sessizTohum,
      RareSignCondition.participationDays,
      participation,
      PatternsConfig.participationMilestones[0],
    ),
    milestone(
      RareSignId.ucanNot,
      RareSignCondition.firstShare,
      sharing,
      1,
      evidenceAvailable: firstSharedAt != null,
    ),
    milestone(
      RareSignId.dengeliTas,
      RareSignCondition.feedbackDays,
      feedbackDays,
      PatternsConfig.feedbackMilestones[0],
    ),
    milestone(
      RareSignId.yeniPatika,
      RareSignCondition.participationDays,
      participation,
      PatternsConfig.participationMilestones[1],
    ),
    milestone(
      RareSignId.geriDonenSerit,
      RareSignCondition.returnAfterBreak,
      returns,
      1,
    ),
    milestone(
      RareSignId.kucukKopru,
      RareSignCondition.feedbackDays,
      feedbackDays,
      PatternsConfig.feedbackMilestones[1],
    ),
    milestone(
      RareSignId.acikPencere,
      RareSignCondition.participationDays,
      participation,
      PatternsConfig.participationMilestones[2],
    ),
    milestone(
      RareSignId.beklenmedikDurak,
      RareSignCondition.participationDays,
      participation,
      PatternsConfig.participationMilestones[3],
    ),
    milestone(
      RareSignId.yanYanaIzler,
      RareSignCondition.distinctArchetypes,
      newArchetypes,
      DailyArchetype.values.length,
    ),
    milestone(
      RareSignId.parlakYol,
      RareSignCondition.brightCard,
      opened
          .where(
            (DailyRecord record) =>
                record.sonuc.genelSkor >= PatternsConfig.brightPathScore,
          )
          .map(revealDay)
          .toList(),
      1,
    ),
  ];
}
