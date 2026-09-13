import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/theme/app_theme.dart';
import 'package:kader/core/theme/app_typography.dart';
import 'package:kader/core/theme/cosmic_config.dart';
import 'package:kader/features/categories/categories_strings.dart';
import 'package:kader/features/categories/paywall_screen.dart';
import 'package:kader/features/collection/collection_screen.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/feedback/feedback_screen.dart';
import 'package:kader/features/history/history_providers.dart';
import 'package:kader/features/history/history_screen.dart';
import 'package:kader/features/settings/settings_screen.dart';
import 'package:kader/features/share/share_service.dart';
import 'package:kader/features/share/share_strings.dart';
import 'package:kader/features/share/story_card.dart';
import 'package:kader/features/share/story_designer_screen.dart';
import 'package:kader/features/share/story_style.dart';
import 'package:kader/features/shell/patterns_entry_screen.dart';

LuckResult result(int score, {int day = 8}) => LuckResult(
  gun: DateTime(2026, 9, day),
  genelSkor: score,
  kategoriSkorlari: const <LuckCategory, int>{
    LuckCategory.ask: 13,
    LuckCategory.para: 17,
    LuckCategory.saglik: 65,
    LuckCategory.sosyal: 76,
    LuckCategory.risk: 58,
  },
  modifiyerler: const <LuckModifier>[],
);

void main() {
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
    'dört kart ailesi farklı dosya kullanır; etiket beyazı en parlak resimde bile AA kontrastlı',
    () {
      expect(
        <int>[
          34,
          55,
          86,
          95,
        ].map((int s) => CosmicTone.fromScore(s).sceneAsset).toSet(),
        hasLength(4),
      );
      final Color worst = Color.alphaBlend(
        CosmicConfig.textPlate,
        Colors.white,
      );
      expect(
        (Colors.white.computeLuminance() + .05) /
            (worst.computeLuminance() + .05),
        greaterThan(4.5),
      );
    },
  );
  for (final int score in <int>[34, 55, 86, 95]) {
    for (final StoryStyle style in StoryStyle.values) {
      testWidgets(
        'Story $score-${style.name}: gerçek PNG, tekil sahne ve gizli skor maskesi',
        (WidgetTester tester) async {
          final StoryCard card = StoryCard(
            sonuc: result(score),
            dil: AppDil.tr,
            style: style,
            kilitliKategoriler: const <LuckCategory>{
              LuckCategory.ask,
              LuckCategory.para,
            },
          );
          tester.view.physicalSize = const Size(1080, 1920);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            Directionality(textDirection: TextDirection.ltr, child: card),
          );
          await tester.pumpAndSettle();
          expect(find.text('13'), findsNothing);
          expect(find.text('17'), findsNothing);
          expect(find.byIcon(Icons.lock_rounded), findsNWidgets(2));
          final List<int>? pixels = await tester.runAsync(() async {
            final bytes = await ShareService().kartPngUret(card);
            final ui.Codec codec = await ui.instantiateImageCodec(bytes);
            try {
              final ui.FrameInfo frame = await codec.getNextFrame();
              try {
                expect(frame.image.width, 1080);
                expect(frame.image.height, 1920);
                if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) {
                  final File output = File(
                    'design/previews/v4/story-$score-${style.name}.png',
                  );
                  await output.parent.create(recursive: true);
                  await output.writeAsBytes(bytes);
                }
                return (await frame.image.toByteData())!.buffer
                    .asUint8List()
                    .toList();
              } finally {
                frame.image.dispose();
              }
            } finally {
              codec.dispose();
            }
          });
          expect(pixels, isNotEmpty);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  final Map<String, Widget> screens = <String, Widget>{
    'premium': const PaywallScreen(),
    'profile': const SettingsScreen(),
    'collection': const PatternsEntryScreen(),
    'daily-records': const CollectionScreen(),
    'history': const HistoryScreen(),
    'feedback': const FeedbackScreen(),
    'story-designer': StoryDesignerScreen(
      result: result(86),
      language: AppDil.tr,
    ),
  };
  for (final MapEntry<String, Widget> screen in screens.entries) {
    for (final (AppDil language, double scale) in <(AppDil, double)>[
      (AppDil.tr, 1),
      (AppDil.tr, 2),
      (AppDil.en, 1),
      (AppDil.en, 2),
    ]) {
      testWidgets(
        '${screen.key} yeni yüzey ${scale}x ${language.name}: okunaklı, kaydırılabilir, taşmasız',
        (WidgetTester tester) async {
          tester.view.physicalSize = Size(scale == 1 ? 390 : 320, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final List<DailyRecord> records = <DailyRecord>[
            for (final int score in <int>[34, 55, 86, 95])
              DailyRecord(
                sonuc: result(
                  score,
                  day: <int>[34, 55, 86, 95].indexOf(score) + 5,
                ),
              ),
          ];
          await tester.pumpWidget(
            ProviderScope(
              overrides: <Override>[
                cosmicMotionEnabledProvider.overrideWithValue(false),
                aktifProfilProvider.overrideWithValue(
                  const UserProfile(
                    isim: 'Ada',
                    rituelKimligi: 'design-v2',
                    seedSurumu: 2,
                  ),
                ),
                dilProvider.overrideWithValue(language),
                bugunProvider.overrideWithValue(DateTime(2026, 9, 8)),
                tumKayitlarProvider.overrideWithValue(records),
                gununSansiProvider.overrideWith((Ref ref) async => result(86)),
              ],
              child: MaterialApp(
                theme: AppTheme.dark,
                builder: (BuildContext context, Widget? child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: RepaintBoundary(
                  key: const ValueKey<String>('v2-screen'),
                  child: screen.key == 'story-designer'
                      ? StoryDesignerScreen(
                          result: result(86),
                          language: language,
                        )
                      : screen.value,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            // Gerçek widget provider'larını bekle: küçük kart 384, sahne
            // 768, Story 1080 px çözer; tek genişliği ısıtmak yeterli değil.
            for (final Image image in tester.widgetList<Image>(
              find.byType(Image),
            )) {
              await precacheImage(
                image.image,
                tester.element(find.byKey(const ValueKey<String>('v2-screen'))),
              );
            }
          });
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (screen.key == 'premium') {
            expect(
              find.text(CategoriesStrings.unavailable(language)),
              findsOneWidget,
            );
            expect(
              find.text(CategoriesStrings.paywallButon(language)),
              findsNothing,
            );
          }
          if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS') &&
              scale == 1 &&
              language == AppDil.tr) {
            await expectLater(
              find.byKey(const ValueKey<String>('v2-screen')),
              matchesGoldenFile('../../design/previews/v4/${screen.key}.png'),
            );
          }
        },
      );
    }
  }
  testWidgets('Story seçimi kaydı değiştirmez ve kendiliğinden paylaşmaz', (
    WidgetTester tester,
  ) async {
    final _ShareSpy spy = _ShareSpy();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[shareServiceProvider.overrideWithValue(spy)],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: StoryDesignerScreen(result: result(86), language: AppDil.tr),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(StoryStyle.orbit.label(AppDil.tr)));
    await tester.tap(find.text(StoryStyle.orbit.label(AppDil.tr)));
    await tester.pumpAndSettle();
    expect(spy.calls, 0);
    final StoryCard card = tester.widget(find.byType(StoryCard));
    expect(card.style, StoryStyle.orbit);
    expect(card.sonuc.gun, DateTime(2026, 9, 8));
    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(tester.widget<StoryCard>(find.byType(StoryCard)).hideScore, isTrue);
    await tester.ensureVisible(find.text(ShareStrings.export(AppDil.tr)));
    await tester.tap(find.text(ShareStrings.export(AppDil.tr)));
    await tester.pumpAndSettle();
    expect(spy.calls, 1);
    expect(spy.style, StoryStyle.orbit);
    expect(spy.hideScore, isTrue);
    expect(
      spy.locked,
      containsAll(<LuckCategory>[LuckCategory.ask, LuckCategory.para]),
    );
  });
}

class _ShareSpy extends ShareService {
  int calls = 0;
  bool hideScore = false;
  StoryStyle? style;
  Set<LuckCategory>? locked;
  @override
  Future<void> paylas({
    required LuckResult sonuc,
    required AppDil dil,
    Set<LuckCategory> kilitliKategoriler = const <LuckCategory>{},
    StoryStyle style = StoryStyle.portal,
    bool hideScore = false,
  }) async {
    calls++;
    this.style = style;
    this.hideScore = hideScore;
    locked = kilitliKategoriler;
  }
}
