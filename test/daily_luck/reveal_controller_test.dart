import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/features/daily_luck/reveal_controller.dart';

void main() {
  late Directory directory;
  late Box<Map<dynamic, dynamic>> box;
  late ProviderContainer container;
  final DateTime day = DateTime(2026, 9, 7);
  final DateTime time = DateTime(2026, 9, 7, 9, 15);
  final LuckResult result = const LuckEngine().hesapla(
    kullanici: UserSeed.fromRituelKimligi('reveal-id'),
    gun: day,
  );
  ProviderContainer scope({Future<void> Function(DateTime, DateTime)? write}) =>
      ProviderContainer(
        overrides: <Override>[
          dailyRecordsBoxProvider.overrideWithValue(box),
          revealClockProvider.overrideWithValue(() => time),
          if (write != null) revealWriterProvider.overrideWithValue(write),
        ],
      );
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('kader_reveal_');
    Hive.init(directory.path);
    box = await Hive.openBox<Map<dynamic, dynamic>>('reveal_records');
    await LuckHistoryRepository(box).kaydet(
      DailyRecord(
        sonuc: result,
        feedbackMood: FeedbackMood.neutral,
        feedbackTags: const <String>['akis'],
      ),
    );
    container = scope();
  });
  tearDown(() async {
    container.dispose();
    await box.deleteFromDisk();
    await directory.delete(recursive: true);
  });
  RevealController watch(List<RevealPhase> phases) {
    container.listen(
      revealControllerProvider(day),
      (_, RevealState next) => phases.add(next.phase),
      fireImmediately: true,
    );
    return container.read(revealControllerProvider(day).notifier);
  }

  test(
    'durum sırası ve çift dokunma/callback: tek yazım, başarıdan önce sonuç yok',
    () async {
      final Completer<void> pending = Completer<void>();
      int writes = 0;
      container.dispose();
      container = scope(
        write: (DateTime target, DateTime timestamp) {
          writes++;
          expect(target, day);
          expect(timestamp, time);
          return pending.future;
        },
      );
      final List<RevealPhase> phases = <RevealPhase>[];
      final RevealController controller = watch(phases);
      expect(controller.start(), isTrue);
      expect(controller.start(), isFalse);
      final Future<void> first = controller.complete();
      await controller.complete();
      expect(phases, <RevealPhase>[
        RevealPhase.concealed,
        RevealPhase.revealing,
        RevealPhase.saving,
      ]);
      expect(writes, 1);
      pending.complete();
      await first;
      expect(phases.last, RevealPhase.revealed);
      expect(container.read(revealControllerProvider(day)).fresh, isTrue);
      expect(controller.start(), isFalse);
    },
  );
  test('disk hatası retry ile düzelir; animasyon yeniden başlamaz', () async {
    int writes = 0;
    container.dispose();
    container = scope(
      write: (DateTime target, DateTime timestamp) async {
        if (++writes == 1) throw StateError('disk');
      },
    );
    final List<RevealPhase> phases = <RevealPhase>[];
    final RevealController controller = watch(phases);
    controller.start();
    await controller.complete();
    expect(phases.last, RevealPhase.error);
    expect(controller.start(), isFalse);
    await controller.retry();
    expect(phases, <RevealPhase>[
      RevealPhase.concealed,
      RevealPhase.revealing,
      RevealPhase.saving,
      RevealPhase.error,
      RevealPhase.saving,
      RevealPhase.revealed,
    ]);
    expect(writes, 2);
  });
  test(
    'gerçek Hive kapat/aç: ilk zaman, sonuç ve feedback korunur; yeni gün kapalıdır',
    () async {
      final RevealController controller = watch(<RevealPhase>[]);
      controller.start();
      await controller.complete();
      final Map<String, dynamic> saved = LuckHistoryRepository(
        box,
      ).getir(day)!.toMap();
      expect(saved['revealedAt'], time.toIso8601String());
      await LuckHistoryRepository(
        box,
      ).revealKaydet(day, revealedAt: time.add(const Duration(hours: 1)));
      expect(LuckHistoryRepository(box).getir(day)!.toMap(), saved);
      container.dispose();
      await box.close();
      box = await Hive.openBox<Map<dynamic, dynamic>>('reveal_records');
      container = scope();
      final RevealController reopened = watch(<RevealPhase>[]);
      expect(
        container.read(revealControllerProvider(day)).phase,
        RevealPhase.revealed,
      );
      expect(container.read(revealControllerProvider(day)).fresh, isFalse);
      expect(reopened.start(), isFalse);
      expect(
        LuckHistoryRepository(box).getir(day)!.sonuc.kategoriSkorlari,
        result.kategoriSkorlari,
      );
      expect(
        LuckHistoryRepository(box).getir(day)!.feedbackMood,
        FeedbackMood.neutral,
      );
      expect(LuckHistoryRepository(box).getir(day)!.feedbackTags, <String>[
        'akis',
      ]);
      expect(
        container
            .read(revealControllerProvider(day.add(const Duration(days: 1))))
            .phase,
        RevealPhase.concealed,
      );
    },
  );
  test(
    'yazım sürerken dispose geç tamamlanan state güncellemesini engeller',
    () async {
      final Completer<void> pending = Completer<void>();
      container.dispose();
      container = scope(write: (_, _) => pending.future);
      final List<RevealPhase> phases = <RevealPhase>[];
      final RevealController controller = watch(phases);
      controller.start();
      final Future<void> completion = controller.complete();
      container.dispose();
      pending.complete();
      await completion;
      expect(phases.last, RevealPhase.saving);
      container = scope();
    },
  );
  test('eksik günlük kayıt başarı gibi gösterilmez', () async {
    final DateTime missing = day.add(const Duration(days: 1));
    container.listen(revealControllerProvider(missing), (_, _) {});
    final RevealController controller = container.read(
      revealControllerProvider(missing).notifier,
    );
    controller.start();
    await controller.complete();
    expect(
      container.read(revealControllerProvider(missing)).phase,
      RevealPhase.error,
    );
  });
}
