import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/history/aylik_ozet.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/history/history_screen.dart';
import 'package:kader/features/history/history_strings.dart';
import 'package:kader/features/history/widgets/luck_heatmap.dart';
import 'package:kader/features/share/recap_strings.dart';
import 'package:kader/features/share/share_service.dart';

/// Ay raporu paylaşımını yutan sahte servis (gerçek PNG/paylaşım yok).
class _SahtePaylasim extends ShareService {
  AylikOzet? sonOzet;

  @override
  Future<void> aylikOzetPaylas(AylikOzet ozet, AppDil dil) async {
    sonOzet = ozet;
  }
}

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
    List<DailyRecord> kayitlar, {
    List<Override> ekstra = const <Override>[],
  }) async {
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
          ...ekstra,
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('kayıt yokken kristal küre + boş metin, heatmap yok', (
    WidgetTester tester,
  ) async {
    await ekraniAc(tester, <DailyRecord>[]);

    expect(find.text(HistoryStrings.bosMetin(AppDil.tr)), findsOneWidget);
    expect(find.byType(LuckHeatmap), findsNothing);
  });

  testWidgets('kayıt varken heatmap + kanıt yüzdesi + özet görünür', (
    WidgetTester tester,
  ) async {
    // 4 yüksek skorlu günün 3'ü pozitif → %75.
    await ekraniAc(tester, <DailyRecord>[
      kayitKur(1, 80, feedback: true),
      kayitKur(2, 75, feedback: true),
      kayitKur(3, 90, feedback: true),
      kayitKur(4, 88, feedback: false),
    ]);

    expect(find.byType(LuckHeatmap), findsOneWidget);
    expect(
      find.text(HistoryStrings.kanitMetni(AppDil.tr, 4, 75)),
      findsOneWidget,
    );
    expect(
      find.text(HistoryStrings.toplamGunEtiketi(AppDil.tr)),
      findsOneWidget,
    );
    expect(
      find.text(HistoryStrings.ortalamaSkorEtiketi(AppDil.tr)),
      findsOneWidget,
    );
  });

  testWidgets('yetersiz örnekte kanıt davet metni gösterilir', (
    WidgetTester tester,
  ) async {
    // Tek yüksek+feedbackli gün (eşik 3'ün altında).
    await ekraniAc(tester, <DailyRecord>[
      kayitKur(1, 80, feedback: true),
      kayitKur(2, 30, feedback: false),
    ]);

    expect(find.byType(LuckHeatmap), findsOneWidget);
    expect(
      find.text(HistoryStrings.kanitYetersizMetni(AppDil.tr, 3, 1)),
      findsOneWidget,
    );
  });

  testWidgets('bu ayda kayıt varken ay raporu kartı + paylaş çalışır', (
    WidgetTester tester,
  ) async {
    final _SahtePaylasim sahte = _SahtePaylasim();
    // Kayıtlar Temmuz 2026 (bugun ile aynı ay).
    await ekraniAc(
      tester,
      <DailyRecord>[kayitKur(1, 80), kayitKur(2, 95), kayitKur(3, 70)],
      ekstra: <Override>[shareServiceProvider.overrideWithValue(sahte)],
    );

    expect(find.text(RecapStrings.bolumBasligi(AppDil.tr)), findsOneWidget);

    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();

    expect(sahte.sonOzet, isNotNull);
    expect(sahte.sonOzet!.ay, 7);
    expect(sahte.sonOzet!.altinGunSayisi, 1); // 95 ≥ 92
  });

  testWidgets('bu ay boşken (kayıtlar başka ayda) ay raporu kartı gizli', (
    WidgetTester tester,
  ) async {
    // Haziran 2026 kaydı → Temmuz (bugun) boş.
    final LuckResult temel = motor.hesapla(
      kullanici: turan,
      gun: DateTime(2026, 6, 10),
    );
    final DailyRecord haziran = DailyRecord(
      sonuc: LuckResult(
        gun: DateTime(2026, 6, 10),
        genelSkor: 80,
        kategoriSkorlari: temel.kategoriSkorlari,
        modifiyerler: temel.modifiyerler,
      ),
    );

    await ekraniAc(tester, <DailyRecord>[haziran]);

    // Geçmiş boş değil (heatmap var) ama bu ayın raporu yok.
    expect(find.byType(LuckHeatmap), findsOneWidget);
    expect(find.text(RecapStrings.bolumBasligi(AppDil.tr)), findsNothing);
  });
}
