import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/theme/app_theme.dart';
import 'package:kader/core/theme/app_typography.dart';
import 'package:kader/core/theme/cosmic_config.dart';
import 'package:kader/features/collection/collection_screen.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/daily_luck/today_strings.dart';
import 'package:kader/features/daily_luck/widgets/today_content.dart';
import 'package:kader/features/feedback/feedback_screen.dart';
import 'package:kader/features/feedback/notification_service.dart';
import 'package:kader/features/history/history_screen.dart';
import 'package:kader/features/settings/settings_screen.dart';
import 'package:kader/features/settings/settings_strings.dart';
import 'package:kader/features/shell/app_shell.dart';
import 'package:kader/features/shell/patterns_entry_screen.dart';
import 'package:kader/shared/widgets/kader_bottom_navigation.dart';

import '../fixtures/reveal_test_overrides.dart';

/// Bildirim planlamasını yutan sahte servis (gerçek plugin yok).
class _SahteBildirim extends NotificationService {
  @override
  Future<void> gunlukBildirimleriPlanla({
    required DateTime simdi,
    required AppDil dil,
    int? aksamDakika,
    int? sabahDakika,
    int? sansliSaatBaslangiciSaati,
  }) async {}

  @override
  Future<void> iptalEt() async {}
}

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;
  late GlobalKey<NavigatorState> navigatorKey;

  final DateTime sabitGun = DateTime(2026, 7, 6);

  setUpAll(() async {
    for (final (String family, String asset) in <(String, String)>[
      (AppTypography.bodyFamily, AppTypography.bodyAsset),
      (AppTypography.headingFamily, AppTypography.headingAsset),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(asset))).load();
    }
  });

  setUp(() async {
    navigatorKey = GlobalKey<NavigatorState>();
    geciciDizin = await Directory.systemTemp.createTemp('settings_nav_test');
    Hive.init(geciciDizin.path);
    profilKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      StorageKeys.userProfileBox,
    );
    kayitKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      StorageKeys.dailyRecordsBox,
    );
  });

  tearDown(() async {
    await profilKutusu.deleteFromDisk();
    await kayitKutusu.deleteFromDisk();
    await geciciDizin.delete(recursive: true);
  });

  /// Ana ekranı gerçek (üretimdeki gibi) MaterialApp + push rotasıyla kurar.
  Future<void> anaEkraniAc(WidgetTester tester) async {
    await tester.runAsync(() async {
      // Profil + bugünün kaydı önceden yazılır ki ekran senkron kurulsun.
      final UserProfile profil = UserProfile(
        isim: 'Turan',
        dogumTarihi: DateTime(1990, 5, 15),
        onboardingTamam: true,
      );
      await profilKutusu.put(StorageKeys.profilKaydi, profil.toMap());
      final LuckResult sonuc = const LuckEngine().hesapla(
        kullanici: profil.seed,
        gun: sabitGun,
      );
      await LuckHistoryRepository(
        kayitKutusu,
      ).kaydet(DailyRecord(sonuc: sonuc));

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            cosmicMotionEnabledProvider.overrideWithValue(false),
            layoutOnlyRevealWriter,
            userProfileBoxProvider.overrideWithValue(profilKutusu),
            dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
            bugunProvider.overrideWithValue(sabitGun),
            notificationServiceProvider.overrideWithValue(_SahteBildirim()),
          ],
          // Üretimdeki gibi: MaterialApp içinde ana ekran (push rotası buradan).
          child: MaterialApp(
            navigatorKey: navigatorKey,
            theme: AppTheme.dark,
            home: const RepaintBoundary(
              key: ValueKey<String>('shell-preview'),
              child: AppShell(),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
  }

  testWidgets('üç sekmenin gerçek Flutter telefon önizlemeleri', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await anaEkraniAc(tester);
    for (final (String label, String file) in <(String, String)>[
      ('Bugün', 'today'),
      ('Koleksiyon', 'patterns'),
      ('Profil', 'profile'),
    ]) {
      await tester.tap(
        find.descendant(
          of: find.byType(KaderBottomNavigation),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) {
        await expectLater(
          find.byKey(const ValueKey<String>('shell-preview')),
          matchesGoldenFile('../../design/previews/kader-shell-$file.png'),
        );
      }
    }
  });

  testWidgets('Profil sekmesinde Ayarlar gövdesi açılır', (
    WidgetTester tester,
  ) async {
    await anaEkraniAc(tester);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Gövde build'inde bir istisna oluşmamalı (release'de boş ekran nedeni).
    expect(tester.takeException(), isNull);
    expect(find.byType(SettingsScreen), findsOneWidget);
    // Gövde gerçekten render oldu mu? (isim bölümü + disclaimer + saatler)
    expect(find.text(SettingsStrings.isimBolumu(AppDil.tr)), findsOneWidget);
    expect(find.text(SettingsStrings.eglenceAmacli(AppDil.tr)), findsOneWidget);
    expect(
      find.text(SettingsStrings.aksamHatirlatma(AppDil.tr)),
      findsOneWidget,
    );
  });

  testWidgets('Desenlerim üzerinden Geçmiş açılır', (
    WidgetTester tester,
  ) async {
    await anaEkraniAc(tester);

    await tester.tap(find.text('Koleksiyon'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Günlük geçmişin'),
      400,
      scrollable: find
          .descendant(
            of: find.byType(PatternsEntryScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Günlük geçmişin'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(HistoryScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(PatternsEntryScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(DailyLuckScreen), findsOneWidget);
    expect(navigatorKey.currentState!.canPop(), isFalse);
  });

  testWidgets('sekme ilk ziyarette kurulur ve Profil taslağı korunur', (
    WidgetTester tester,
  ) async {
    await anaEkraniAc(tester);
    expect(find.byType(SettingsScreen, skipOffstage: false), findsNothing);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Kaydedilmemiş isim');
    await tester.tap(
      find.descendant(
        of: find.byType(KaderBottomNavigation),
        matching: find.text('Bugün'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Kaydedilmemiş isim',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bugün kart state ve kaydırma konumu sekme geçişinde korunur', (
    WidgetTester tester,
  ) async {
    await anaEkraniAc(tester);
    await tester.ensureVisible(find.text(TodayStrings.open(AppDil.tr)));
    await tester.tap(find.text(TodayStrings.open(AppDil.tr)));
    await tester.pumpAndSettle();
    final Finder scroll = find
        .descendant(
          of: find.byType(DailyLuckScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.drag(scroll, const Offset(0, -180));
    await tester.pumpAndSettle();
    final double offset = tester.state<ScrollableState>(scroll).position.pixels;
    expect(offset, greaterThan(0));
    await tester.tap(find.text('Koleksiyon'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bugün'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayRevealedContent), findsOneWidget);
    expect(find.byType(TodayConcealedCard), findsNothing);
    expect(tester.state<ScrollableState>(scroll).position.pixels, offset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('koleksiyondan geri gelince Desenlerim açık kalır', (
    WidgetTester tester,
  ) async {
    await anaEkraniAc(tester);
    await tester.tap(find.text('Koleksiyon'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Günlük kartların'),
      400,
      scrollable: find
          .descendant(
            of: find.byType(PatternsEntryScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Günlük kartların'));
    await tester.pumpAndSettle();
    expect(find.byType(CollectionScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(PatternsEntryScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kök Navigator feedback rotasını Profil üstüne açıp geri döner', (
    WidgetTester tester,
  ) async {
    await anaEkraniAc(tester);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    // Bildirim callback'i aynı kök Navigator'a push yapar; plugin gerektirmez.
    navigatorKey.currentState!.push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const FeedbackScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FeedbackScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(DailyLuckScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
