import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/history/history_screen.dart';
import 'package:kader/features/history/history_strings.dart';
import 'package:kader/features/history/widgets/luck_heatmap.dart';

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;
  int testSayaci = 0;

  const LuckEngine motor = LuckEngine();
  final UserSeed turan = UserSeed.fromIsim(
    isim: 'Turan',
    dogumTarihi: DateTime(1990, 5, 15),
  );
  final DateTime bugun = DateTime(2026, 7, 6);

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('history_screen_test');
    Hive.init(geciciDizin.path);
    testSayaci++;
    profilKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'hist_profil_$testSayaci',
    );
    kayitKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'hist_kayit_$testSayaci',
    );
  });

  /// Belirli gün/skor/feedback ile kayıt kurar (kategori haritası gerçek
  /// motordan alınır ki mapper round-trip'i sorunsuz olsun).
  DailyRecord kayitKur(int gunNo, int skor, {bool? feedback}) {
    final DateTime gun = DateTime(2026, 7, gunNo);
    final LuckResult temel = motor.hesapla(kullanici: turan, gun: gun);
    return DailyRecord(
      sonuc: LuckResult(
        gun: gun,
        genelSkor: skor,
        kategoriSkorlari: temel.kategoriSkorlari,
        modifiyerler: temel.modifiyerler,
      ),
      feedbackPozitif: feedback,
    );
  }

  Future<void> ekraniAc(
    WidgetTester tester,
    List<DailyRecord> kayitlar,
  ) async {
    // Seed yazması gerçek I/O → runAsync (FakeAsync'te asılmasın).
    await tester.runAsync(() async {
      final LuckHistoryRepository repo = LuckHistoryRepository(kayitKutusu);
      for (final DailyRecord k in kayitlar) {
        await repo.kaydet(k);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          userProfileBoxProvider.overrideWithValue(profilKutusu),
          dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
          bugunProvider.overrideWithValue(bugun),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('kayıt yokken kristal küre + boş metin, heatmap yok',
      (WidgetTester tester) async {
    await ekraniAc(tester, <DailyRecord>[]);

    expect(find.text(HistoryStrings.bosMetin), findsOneWidget);
    expect(find.byType(LuckHeatmap), findsNothing);
  });

  testWidgets('kayıt varken heatmap + kanıt yüzdesi + özet görünür',
      (WidgetTester tester) async {
    // 4 yüksek skorlu günün 3'ü pozitif → %75.
    await ekraniAc(tester, <DailyRecord>[
      kayitKur(1, 80, feedback: true),
      kayitKur(2, 75, feedback: true),
      kayitKur(3, 90, feedback: true),
      kayitKur(4, 88, feedback: false),
    ]);

    expect(find.byType(LuckHeatmap), findsOneWidget);
    expect(find.text(HistoryStrings.kanitMetni(4, 75)), findsOneWidget);
    expect(find.text(HistoryStrings.toplamGunEtiketi), findsOneWidget);
    expect(find.text(HistoryStrings.ortalamaSkorEtiketi), findsOneWidget);
  });

  testWidgets('yetersiz örnekte kanıt davet metni gösterilir',
      (WidgetTester tester) async {
    // Tek yüksek+feedbackli gün (eşik 3'ün altında).
    await ekraniAc(tester, <DailyRecord>[
      kayitKur(1, 80, feedback: true),
      kayitKur(2, 30, feedback: false),
    ]);

    expect(find.byType(LuckHeatmap), findsOneWidget);
    expect(find.text(HistoryStrings.kanitYetersizMetni(3, 1)), findsOneWidget);
  });
}
