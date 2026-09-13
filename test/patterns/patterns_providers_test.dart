import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/content/rare_sign_id.dart';
import 'package:kader/core/history/patterns_summary.dart';
import 'package:kader/core/history/rare_sign_progress.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/patterns/patterns_providers.dart';

import 'patterns_fixture.dart';

void main() {
  late Directory directory;
  late Box<Map<dynamic, dynamic>> box;
  late ProviderContainer container;
  late LuckHistoryRepository repository;
  DateTime today = DateTime(2026, 9, 30);
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('kader_patterns_');
    Hive.init(directory.path);
    box = await Hive.openBox<Map<dynamic, dynamic>>('patterns');
    repository = LuckHistoryRepository(box);
    today = DateTime(2026, 9, 30);
    container = ProviderContainer(
      overrides: <Override>[
        dailyRecordsBoxProvider.overrideWithValue(box),
        bugunProvider.overrideWith((Ref ref) => today),
      ],
    );
    container.listen(patternsSummaryProvider, (_, _) {}, fireImmediately: true);
    await container.pump();
  });
  tearDown(() async {
    container.dispose();
    await box.deleteFromDisk();
    await directory.delete(recursive: true);
  });
  Future<PatternsSummary> updated() async {
    await container.pump();
    return container.read(patternsSummaryProvider);
  }

  test(
    'gerçek Hive: kart üretimi sayılmaz, reveal ve üç durumlu feedback yeniler',
    () async {
      await repository.kaydet(patternRecord(30, opened: false));
      expect((await updated()).participationDays, 0);
      await repository.revealKaydet(today, revealedAt: today);
      expect((await updated()).participationDays, 1);
      expect((await updated()).rhythm.last.cardOpened, isTrue);
      await repository.feedbackDurumuKaydet(today, mood: FeedbackMood.neutral);
      expect((await updated()).feedback.count(FeedbackMood.neutral), 1);
      await repository.feedbackDurumuKaydet(
        today,
        mood: FeedbackMood.difficult,
      );
      final PatternsSummary result = await updated();
      expect(result.feedback.count(FeedbackMood.neutral), 0);
      expect(result.feedback.count(FeedbackMood.difficult), 1);
      expect(result.feedback.total, 1);
      expect(result.participationDays, 1);
      expect(repository.tumKayitlar().length, 1);
    },
  );

  test(
    'gün sağlayıcısı yenilendiğinde pencere kayar ve mevcut seri güncellenir',
    () async {
      await repository.kaydet(patternRecord(30));
      expect((await updated()).currentStreak, 1);
      today = DateTime(2026, 10, 2);
      container.invalidate(bugunProvider);
      final PatternsSummary result = await updated();
      expect(result.currentStreak, 0);
      expect(result.participationDays, 1);
      expect(result.rhythm.last.date, today);
    },
  );

  test(
    'yeniden açılan Hive eski feedback ve reveal bilgisini aynı hesaplar',
    () async {
      await repository.kaydet(patternRecord(29, mood: FeedbackMood.positive));
      await repository.kaydet(
        patternRecord(30, opened: false, mood: FeedbackMood.neutral),
      );
      final PatternsSummary before = await updated();
      container.dispose();
      await box.close();
      box = await Hive.openBox<Map<dynamic, dynamic>>('patterns');
      container = ProviderContainer(
        overrides: <Override>[
          dailyRecordsBoxProvider.overrideWithValue(box),
          bugunProvider.overrideWithValue(today),
        ],
      );
      final PatternsSummary after = container.read(patternsSummaryProvider);
      expect(after.participationDays, before.participationDays);
      expect(after.feedback.values, before.feedback.values);
      expect(after.currentStreak, before.currentStreak);
      expect(after.archetypeCounts, before.archetypeCounts);
      expect(after.rhythm.last.cardOpened, isFalse);
    },
  );

  test(
    'paylaşım provider varsayılanı kanıt uydurmaz; açık kanıt bağlanabilir',
    () {
      RareSignProgress sign(PatternsSummary summary) =>
          summary.rareSigns.singleWhere(
            (RareSignProgress value) => value.id == RareSignId.ucanNot,
          );
      expect(
        sign(container.read(patternsSummaryProvider)).evidenceAvailable,
        isFalse,
      );
      final ProviderContainer linked = ProviderContainer(
        overrides: <Override>[
          dailyRecordsBoxProvider.overrideWithValue(box),
          bugunProvider.overrideWithValue(today),
          firstShareEvidenceProvider.overrideWithValue(today),
        ],
      );
      addTearDown(linked.dispose);
      expect(sign(linked.read(patternsSummaryProvider)).isUnlocked, isTrue);
    },
  );
}
