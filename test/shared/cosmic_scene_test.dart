import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:kader/shared/widgets/cosmic_scene.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final (String family, String asset) in <(String, String)>[
      (AppTypography.bodyFamily, AppTypography.bodyAsset),
      (AppTypography.headingFamily, AppTypography.headingAsset),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(asset))).load();
    }
  });
  test('görsel bant sınırları ve düşük/yüksek/nadir farklı ışık', () {
    expect(CosmicTone.fromScore(39), CosmicTone.calm);
    expect(CosmicTone.fromScore(40), CosmicTone.balanced);
    expect(CosmicTone.fromScore(69), CosmicTone.balanced);
    expect(CosmicTone.fromScore(70), CosmicTone.bright);
    expect(CosmicTone.fromScore(91), CosmicTone.bright);
    expect(CosmicTone.fromScore(92), CosmicTone.rare);
    expect(CosmicTone.calm.light, isNot(CosmicTone.bright.light));
    expect(CosmicTone.calm.mist, isNot(CosmicTone.bright.mist));
  });
  test('ana sahne ışığı korunur, yerel metin yüzeyleri AA kontrastlıdır', () {
    final Color gold = CosmicConfig.gold;
    final Color vivid = Color.alphaBlend(
      CosmicConfig.vividBackdrop.colors[1],
      gold,
    );
    final Color old = Color.alphaBlend(
      CosmicConfig.subduedBackdrop.colors[1],
      gold,
    );
    expect(vivid.computeLuminance(), greaterThan(old.computeLuminance() * 3));
    for (final Color panel in <Color>[
      CosmicConfig.textPlate,
      CosmicConfig.focusedTextPlate,
      CosmicConfig.categorySurface,
    ]) {
      final Color worst = Color.alphaBlend(panel, Colors.white);
      expect(1.05 / (worst.computeLuminance() + .05), greaterThan(4.5));
    }
  });
  test(
    'yüksek DPR sahneyi kaynak genişliğinde açar; küçük ekranı şişirmez',
    () {
      expect(CosmicConfig.sceneDecodeWidth(390, 1), 390);
      expect(CosmicConfig.sceneDecodeWidth(390, 2), 780);
      expect(CosmicConfig.sceneDecodeWidth(390, 3), 1024);
      expect(CosmicConfig.backdropDecodeWidth(const Size(390, 844), 1), 563);
      expect(CosmicConfig.backdropDecodeWidth(const Size(390, 844), 3), 1024);
    },
  );
  testWidgets(
    'atmosfer canlı ilerler; gizli, arka plan, reduced-motion durumunda durur',
    (WidgetTester tester) async {
      final ValueNotifier<bool> visible = ValueNotifier<bool>(true);
      final ValueNotifier<bool> reduced = ValueNotifier<bool>(false);
      addTearDown(visible.dispose);
      addTearDown(reduced.dispose);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (BuildContext context, bool show, Widget? _) =>
                ValueListenableBuilder<bool>(
                  valueListenable: reduced,
                  builder: (BuildContext context, bool reduce, Widget? _) =>
                      MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(disableAnimations: reduce),
                        child: TickerMode(
                          enabled: show,
                          child: const SizedBox(
                            width: 300,
                            height: 400,
                            child: CosmicAmbient(enabled: true),
                          ),
                        ),
                      ),
                ),
          ),
        ),
      );
      double value() => tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((CustomPaint widget) => widget.painter)
          .whereType<CosmicLightPainter>()
          .single
          .animation
          .value;
      await tester.pump(const Duration(milliseconds: 400));
      final double initial = value();
      expect(initial, greaterThan(0));
      visible.value = false;
      await tester.pump();
      final double paused = value();
      await tester.pump(const Duration(seconds: 1));
      expect(value(), paused);
      visible.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(value(), greaterThan(paused));
      reduced.value = true;
      await tester.pump();
      final double calm = value();
      await tester.pump(const Duration(seconds: 1));
      expect(value(), calm);
      reduced.value = false;
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      final double background = value();
      await tester.pump(const Duration(seconds: 1));
      expect(value(), background);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(value(), greaterThan(background));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
  for (final (int score, String name) in <(int, String)>[
    (34, 'low'),
    (55, 'balanced'),
    (86, 'high'),
    (95, 'rare'),
  ]) {
    testWidgets('$name gerçek Bugün ekranı ve renk varyantı', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final DateTime day = DateTime(2026, 9, 8);
      final LuckResult result = LuckResult(
        gun: day,
        genelSkor: score,
        kategoriSkorlari: <LuckCategory, int>{
          for (final LuckCategory c in LuckCategory.values) c: score,
        },
        modifiyerler: const <LuckModifier>[],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            cosmicMotionEnabledProvider.overrideWithValue(false),
            aktifProfilProvider.overrideWithValue(
              const UserProfile(
                isim: 'Ada',
                rituelKimligi: 'cosmic-qa',
                seedSurumu: 2,
              ),
            ),
            dilProvider.overrideWithValue(AppDil.tr),
            bugunProvider.overrideWithValue(day),
            tumKayitlarProvider.overrideWithValue(const []),
            todayRevealedProvider(day).overrideWithValue(true),
            gununSansiProvider.overrideWith(
              (Ref ref) => Future<LuckResult>.value(result),
            ),
            entitlementProvider.overrideWith((Ref ref) => true),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const RepaintBoundary(
              key: ValueKey<String>('cosmic-preview'),
              child: DailyLuckScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // İlk örneğin PNG çözümü gerçek async bölgede tamamlanmalı; aksi halde
      // bir önizleme yüklenmemiş resmi yanlışlıkla boş sahne olarak kaydeder.
      await tester.runAsync(() async {
        for (final Image image in tester.widgetList<Image>(
          find.byType(Image),
        )) {
          await precacheImage(
            image.image,
            tester.element(find.byType(DailyLuckScreen)),
          );
        }
      });
      await tester.pumpAndSettle();
      expect(
        find.text(TodayStrings.scoreTitle(AppDil.tr, score)),
        findsOneWidget,
      );
      expect(find.byType(CosmicScoreHero), findsOneWidget);
      expect(
        tester.widget<CosmicBackdrop>(find.byType(CosmicBackdrop)).vivid,
        isTrue,
      );
      expect(
        find.byKey(const ValueKey<String>('today-reflection-plate')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('score-contrast-scrim')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('score-label-plate')),
        findsOneWidget,
      );
      for (final LuckCategory category in LuckCategory.values) {
        expect(find.text(category.etiket(AppDil.tr)), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) {
        await expectLater(
          find.byKey(const ValueKey<String>('cosmic-preview')),
          matchesGoldenFile('../../design/previews/kader-cosmic-$name.png'),
        );
      }
    });
  }
  testWidgets(
    'aynı ışık girdisi aynı pikseli, ilerleyen girdi farklı kareyi çizer',
    (WidgetTester tester) async {
      Future<List<int>> frame(double progress) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: RepaintBoundary(
                key: const ValueKey<String>('light'),
                child: SizedBox(
                  width: 240,
                  height: 360,
                  child: CustomPaint(
                    painter: CosmicLightPainter(
                      animation: AlwaysStoppedAnimation<double>(progress),
                      tone: CosmicTone.bright,
                      ribbons: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final RenderRepaintBoundary box = tester.renderObject(
          find.byKey(const ValueKey<String>('light')),
        );
        final ui.Image image = await box.toImage();
        try {
          return (await image.toByteData())!.buffer.asUint8List();
        } finally {
          image.dispose();
        }
      }

      final List<int> first = await tester.runAsync(() => frame(.2)) ?? [];
      final List<int> same = await tester.runAsync(() => frame(.2)) ?? [];
      final List<int> changed = await tester.runAsync(() => frame(.7)) ?? [];
      final List<int> loopStart = await tester.runAsync(() => frame(0)) ?? [];
      final List<int> loopEnd = await tester.runAsync(() => frame(1)) ?? [];
      expect(first, isNotEmpty);
      expect(same, first);
      expect(changed, isNot(first));
      expect(loopStart, isNotEmpty);
      expect(loopEnd, loopStart);
    },
  );
}
