import 'package:kader/core/content/experience_dimension.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';

/// Motoru değiştirmeden kontrollü analiz girdisi oluşturur.
DailyRecord patternRecord(
  int day, {
  bool opened = true,
  FeedbackMood? mood,
  ExperienceDimension dimension = ExperienceDimension.akis,
  int score = 50,
  DateTime? date,
  DateTime? revealedAt,
}) {
  final DateTime target = date ?? DateTime(2026, 9, day);
  return DailyRecord(
    sonuc: LuckResult(
      gun: target,
      genelSkor: score,
      kategoriSkorlari: <LuckCategory, int>{
        for (final LuckCategory category in LuckCategory.values)
          category: category == dimension.kategori ? 80 : 40,
      },
      modifiyerler: const <LuckModifier>[],
    ),
    revealedAt: opened ? revealedAt ?? target : null,
    feedbackMood: mood,
  );
}
