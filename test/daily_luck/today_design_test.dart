import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/experience_dimension.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/theme/app_theme.dart';
import 'package:kader/core/theme/app_typography.dart';
import 'package:kader/core/theme/cosmic_config.dart';
import 'package:kader/features/categories/entitlement.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/daily_luck/today_providers.dart';
import 'package:kader/features/daily_luck/today_strings.dart';
import 'package:kader/features/daily_luck/widgets/today_content.dart';
import 'package:kader/features/history/history_providers.dart';

import '../fixtures/reveal_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final DateTime day = DateTime(2026, 9, 7);
  final LuckResult result = LuckResult(
    modifiyerler: const <LuckModifier>[],
    gun: day,
    genelSkor: 83,
    kategoriSkorlari: <LuckCategory, int>{
      LuckCategory.ask: 97,
      LuckCategory.para: 91,
      LuckCategory.sosyal: 73,
      LuckCategory.risk: 62,
      LuckCategory.saglik: 54,
    },
  );
  setUpAll(() async {
    for (final (String family, String asset) in <(String, String)>[
      (AppTypography.bodyFamily, AppTypography.bodyAsset),
      (AppTypography.headingFamily, AppTypography.headingAsset),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(asset))).load();
    }
  });
  void viewport(WidgetTester tester, double width, {double height = 568}) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app({
    AppDil language = AppDil.tr,
    double scale = 1,
    bool opened = false,
    Future<LuckResult> Function()? load,
  }) => ProviderScope(
    overrides: <Override>[
      cosmicMotionEnabledProvider.overrideWithValue(false),
      layoutOnlyRevealWriter,
      aktifProfilProvider.overrideWithValue(
        const UserProfile(isim: 'Ada', rituelKimligi: 'test-id', seedSurumu: 2),
      ),
      dilProvider.overrideWithValue(language),
      bugunProvider.overrideWithValue(day),
      tumKayitlarProvider.overrideWithValue(const []),
      todayRevealedProvider(day).overrideWith((Ref ref) => opened),
      gununSansiProvider.overrideWith(
        (Ref ref) => load?.call() ?? Future<LuckResult>.value(result),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: const RepaintBoundary(
        key: ValueKey<String>('today-preview'),
        child: DailyLuckScreen(),
      ),
    ),
  );

  testWidgets(
    'kapalı kart: skorlar, arketip, bitmap ve paylaşım hiçbir ağaçta yok',
    (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        expect(find.byType(TodayConcealedCard), findsOneWidget);
        expect(
          find.byType(TodayRevealedContent, skipOffstage: false),
          findsNothing,
        );
        expect(
          find.byType(TodayDimensionTile, skipOffstage: false),
          findsNothing,
        );
        expect(find.byType(CosmicScoreHero, skipOffstage: false), findsNothing);
        expect(
          find.bySemanticsLabel(RegExp('83|97|91|Bağ Günü')),
          findsNothing,
        );
        expect(find.text(TodayStrings.share(AppDil.tr)), findsNothing);
        await tester.ensureVisible(find.text(TodayStrings.open(AppDil.tr)));
        await tester.tap(find.text(TodayStrings.open(AppDil.tr)));
        await tester.pumpAndSettle();
        expect(find.byType(TodayRevealedContent), findsOneWidget);
        expect(
          find.byType(CosmicScoreHero, skipOffstage: false),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'kilitli sayılar widget verisi, metin, semantics ve bar oranında yok',
    (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(app(opened: true));
        await tester.pumpAndSettle();
        final TodayRevealedContent content = tester.widget(
          find.byType(TodayRevealedContent),
        );
        expect(
          content.dimensions
              .where((TodayDimensionData d) => d.score == null)
              .map((TodayDimensionData d) => d.dimension),
          <ExperienceDimension>[
            ExperienceDimension.bag,
            ExperienceDimension.uretim,
          ],
        );
        expect(find.text('97', skipOffstage: false), findsNothing);
        expect(find.text('91', skipOffstage: false), findsNothing);
        expect(find.bySemanticsLabel(RegExp('97|91')), findsNothing);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(2));
        expect(find.byType(TodayDimensionTile), findsNWidgets(5));
        for (final TodayDimensionTile tile
            in tester.widgetList<TodayDimensionTile>(
              find.byType(TodayDimensionTile),
            )) {
          if (tile.data.dimension == ExperienceDimension.bag ||
              tile.data.dimension == ExperienceDimension.uretim) {
            expect(tile.data.score, isNull);
          }
        }
        final ProviderContainer container = ProviderScope.containerOf(
          tester.element(find.byType(DailyLuckScreen)),
        );
        container.read(entitlementProvider.notifier).state = true;
        await tester.pumpAndSettle();
        expect(find.text('97'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('yükleme sırasında skor veya arketip kurulmaz', (
    WidgetTester tester,
  ) async {
    final Completer<LuckResult> pending = Completer<LuckResult>();
    await tester.pumpWidget(app(load: () => pending.future));
    await tester.pump();
    expect(find.text(TodayStrings.loading(AppDil.tr)), findsOneWidget);
    expect(find.byType(TodayConcealedCard), findsNothing);
    expect(find.byType(TodayRevealedContent), findsNothing);
    expect(find.byType(CosmicScoreHero, skipOffstage: false), findsNothing);
    await tester.pumpWidget(const SizedBox());
    pending.complete(result);
    await tester.pump();
  });

  testWidgets('hata tekrar denemesi gerçek sonuç providerını yeniler', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(
      app(
        load: () async {
          if (++calls == 1) throw StateError('disk');
          return result;
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(TodayStrings.error(AppDil.tr)), findsOneWidget);
    expect(find.byType(TodayRevealedContent), findsNothing);
    await tester.tap(find.text(TodayStrings.retry(AppDil.tr)));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byType(TodayConcealedCard), findsOneWidget);
  });

  for (final double width in <double>[320, 390, 430]) {
    for (final double scale in <double>[1, 2]) {
      for (final AppDil language in AppDil.values) {
        testWidgets(
          'Bugün $width px ${scale}x ${language.name}: kapalı ve açık gövde taşmaz',
          (WidgetTester tester) async {
            viewport(tester, width);
            await tester.pumpWidget(app(language: language, scale: scale));
            await tester.pumpAndSettle();
            await tester.ensureVisible(find.text(TodayStrings.open(language)));
            await tester.tap(find.text(TodayStrings.open(language)));
            await tester.pumpAndSettle();
            expect(
              tester
                  .state<ScrollableState>(find.byType(Scrollable).first)
                  .position
                  .pixels,
              0,
            );
            await tester.ensureVisible(
              find.text(TodayStrings.reflect(language)),
            );
            await tester.pumpAndSettle();
            expect(
              find.text(TodayStrings.reflect(language)).hitTestable(),
              findsOneWidget,
            );
            expect(find.byType(TodayDimensionTile), findsNWidgets(5));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('gerçek Flutter kapalı ve açık Bugün önizlemeleri', (
    WidgetTester tester,
  ) async {
    viewport(tester, 390, height: 844);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) {
      await expectLater(
        find.byKey(const ValueKey<String>('today-preview')),
        matchesGoldenFile('../../design/previews/kader-today-concealed.png'),
      );
    }
    await tester.ensureVisible(find.text(TodayStrings.open(AppDil.tr)));
    await tester.tap(find.text(TodayStrings.open(AppDil.tr)));
    await tester.pumpAndSettle();
    final ScrollableState scroll = tester.state(find.byType(Scrollable).first);
    scroll.position.jumpTo(0);
    await tester.pumpAndSettle();
    if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) {
      await expectLater(
        find.byKey(const ValueKey<String>('today-preview')),
        matchesGoldenFile('../../design/previews/kader-today-revealed.png'),
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('today-category-grid')),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(const ValueKey<String>('today-preview')),
        matchesGoldenFile('../../design/previews/kader-today-dimensions.png'),
      );
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(const ValueKey<String>('today-preview')),
        matchesGoldenFile('../../design/previews/kader-today-mission.png'),
      );
    }
    expect(tester.takeException(), isNull);
  });
}
