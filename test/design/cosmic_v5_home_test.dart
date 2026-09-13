import 'package:flutter/material.dart';
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
import 'package:kader/features/daily_luck/widgets/card_reveal_motion.dart';
import 'package:kader/features/daily_luck/widgets/category_jewel_surface.dart';
import 'package:kader/features/daily_luck/widgets/today_content.dart';
import 'package:kader/features/daily_luck/widgets/today_scene_stage.dart';
import 'package:kader/features/history/history_providers.dart';
import 'package:kader/features/shell/app_shell.dart';
import 'package:kader/shared/widgets/cosmic_scene.dart';
import 'package:kader/shared/widgets/kader_bottom_navigation.dart';

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
  test(
    'V5 kanatlar sonunda görünmez; ışıklı sahne tam görünür ve süreklidir',
    () {
      expect(RevealFrame.at(0).panelOpacity, 1);
      expect(RevealFrame.at(0).sceneOpacity, 0);
      expect(RevealFrame.at(1).panelOpacity, 0);
      expect(RevealFrame.at(1).sceneOpacity, 1);
      for (int ms = 1; ms <= 1300; ms++) {
        final RevealFrame previous = RevealFrame.at((ms - 1) / 1300);
        final RevealFrame next = RevealFrame.at(ms / 1300);
        expect(
          (previous.panelOpacity - next.panelOpacity).abs(),
          lessThan(.02),
        );
        expect(
          (previous.sceneOpacity - next.sceneOpacity).abs(),
          lessThan(.02),
        );
      }
      expect(CosmicTone.bright.homeSceneAsset, CosmicConfig.radiantPortal);
      expect(CosmicTone.calm.homeSceneAsset, CosmicConfig.twilightPortal);
      expect(CosmicConfig.sanctuaryDecodeWidth(390, 1), 390);
      expect(CosmicConfig.sanctuaryDecodeWidth(390, 3), 948);
      // Önceki %70 koyu halo yerine en fazla %15; sanatı gölgelemez.
      expect(CosmicConfig.scoreHalo.colors.first.a, lessThanOrEqualTo(.15));
    },
  );
  for (final (int score, bool opened, String name) in <(int, bool, String)>[
    (86, false, 'closed'),
    (86, true, 'high'),
    (34, true, 'low'),
  ]) {
    testWidgets('V6 bütünleşik sahne, dokulu kategoriler ve menü: $name', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final DateTime day = DateTime(2026, 9, 8);
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            cosmicMotionEnabledProvider.overrideWithValue(false),
            aktifProfilProvider.overrideWithValue(
              const UserProfile(
                isim: 'Ada',
                rituelKimligi: 'v5-preview',
                seedSurumu: 2,
              ),
            ),
            dilProvider.overrideWithValue(AppDil.tr),
            bugunProvider.overrideWithValue(day),
            tumKayitlarProvider.overrideWithValue(const []),
            todayRevealedProvider(day).overrideWithValue(opened),
            gununSansiProvider.overrideWith(
              (Ref ref) async => LuckResult(
                gun: day,
                genelSkor: score,
                kategoriSkorlari: <LuckCategory, int>{
                  LuckCategory.ask: opened && score < 40 ? 42 : 88,
                  LuckCategory.para: opened && score < 40 ? 31 : 81,
                  LuckCategory.saglik: opened && score < 40 ? 48 : 76,
                  LuckCategory.sosyal: opened && score < 40 ? 37 : 92,
                  LuckCategory.risk: opened && score < 40 ? 26 : 68,
                },
                modifiyerler: const <LuckModifier>[],
              ),
            ),
            entitlementProvider.overrideWith((Ref ref) => true),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const RepaintBoundary(
              key: ValueKey<String>('v5-screen'),
              child: AppShell(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
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
      expect(find.byType(KaderBottomNavigation), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(TodaySceneStage), findsOneWidget);
      expect(find.byType(CosmicPortal), findsNothing);
      expect(find.byType(CategoryJewelSurface), findsNWidgets(5));
      final Rect headerRect = tester.getRect(
        find.byKey(const ValueKey<String>('today-heading-halo')),
      );
      final Rect sceneRect = tester.getRect(
        find.byKey(const ValueKey<String>('sanctuary-bottom-only')),
      );
      final Rect stageRect = tester.getRect(find.byType(CardRevealMotion));
      // Resim başlıktan önce başlar; hero sınırının 240 px ötesine devam eder.
      expect(sceneRect.left, 0);
      expect(sceneRect.right, 390);
      expect(sceneRect.top, lessThan(headerRect.top));
      expect(
        sceneRect.bottom - stageRect.bottom,
        CosmicConfig.sceneUnderlayReach,
      );
      if (opened) {
        expect(find.byType(TodayDimensionTile), findsNWidgets(5));
        final CardRevealMotion gate = tester.widget(
          find.byType(CardRevealMotion),
        );
        expect(gate.tone, CosmicTone.fromScore(score));
        expect(gate.showScene, isFalse);
        expect(RevealFrame.at(gate.animation.value).panelOpacity, 0);
        expect(CosmicConfig.sanctuaryEdgeBlend.stops, <double>[0, .84, 1]);
      } else {
        expect(find.byType(CosmicScoreHero), findsNothing);
        expect(find.byType(TodayDimensionTile), findsNothing);
      }
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) {
        await expectLater(
          find.byKey(const ValueKey<String>('v5-screen')),
          matchesGoldenFile('../../design/previews/v6/home-$name.png'),
        );
      }
    });
  }
}
