import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/rare_sign_id.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/theme/app_motion.dart';
import 'package:kader/core/theme/app_theme.dart';
import 'package:kader/core/theme/app_typography.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/reveal_config.dart';
import 'package:kader/features/daily_luck/widgets/card_reveal_motion.dart';
import 'package:kader/features/history/history_providers.dart';
import 'package:kader/features/patterns/patterns_providers.dart';
import 'package:kader/features/patterns/patterns_strings.dart';
import 'package:kader/features/share/story_card.dart';
import 'package:kader/features/shell/patterns_entry_screen.dart';
import 'package:kader/shared/widgets/app_illustrations.dart';

void main() {
  final LuckResult result = LuckResult(
    gun: DateTime(2026, 9, 8),
    genelSkor: 86,
    kategoriSkorlari: const <LuckCategory, int>{
      LuckCategory.ask: 17,
      LuckCategory.para: 21,
      LuckCategory.saglik: 56,
      LuckCategory.sosyal: 64,
      LuckCategory.risk: 73,
    },
    modifiyerler: const <LuckModifier>[],
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
  test(
    'referans zamanları: 250 mühür, 650 ışık, 1300 kanat, 2000 yerleşme',
    () {
      expect(
        RevealConfig.opening + AppMotion.resultEntry,
        const Duration(milliseconds: 2000),
      );
      expect(RevealFrame.at(0).press, 0);
      expect(RevealFrame.at(125 / 1300).press, closeTo(1, .00001));
      expect(RevealFrame.at(250 / 1300).seam, 0);
      expect(RevealFrame.at(650 / 1300).seam, 1);
      expect(RevealFrame.at(650 / 1300).unfold, 0);
      expect(RevealFrame.at(1).unfold, 1);
      for (int i = 0; i <= 1300; i++) {
        final RevealFrame f = RevealFrame.at(i / 1300);
        expect(<double>[
          f.press,
          f.seam,
          f.unfold,
        ], everyElement(inInclusiveRange(0, 1)));
        if (i < 1300) {
          final RevealFrame next = RevealFrame.at((i + 1) / 1300);
          expect((next.unfold - f.unfold).abs(), lessThan(.01));
        }
      }
    },
  );
  testWidgets(
    'skor gizlendiğinde hiçbir genel/kategori değeri metin veya semantics taşımaz',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: StoryCard(sonuc: result, dil: AppDil.tr, hideScore: true),
          ),
        );
        await tester.pumpAndSettle();
        for (final int score in <int>[
          result.genelSkor,
          ...result.kategoriSkorlari.values,
        ]) {
          expect(find.text('$score'), findsNothing);
          expect(find.bySemanticsLabel('$score'), findsNothing);
        }
        expect(find.text('Bugünün kartı'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );
  testWidgets(
    'koleksiyon sayısı gerçek kanıtı izler; kilit detayı gerçeği açıklar',
    (tester) async {
      final List<DailyRecord> records = <DailyRecord>[
        DailyRecord(sonuc: result, revealedAt: DateTime(2026, 9, 8, 9)),
      ];
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            dilProvider.overrideWithValue(AppDil.tr),
            bugunProvider.overrideWithValue(DateTime(2026, 9, 8)),
            tumKayitlarProvider.overrideWithValue(records),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const PatternsEntryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(PatternsEntryScreen)),
      );
      final signs = container.read(patternsSummaryProvider).rareSigns;
      final int count = signs.where((s) => s.isUnlocked).length;
      expect(find.text('$count / 12'), findsOneWidget);
      expect(signs.first.isUnlocked, isTrue);
      await tester.tap(find.text('Sessiz Tohum'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          PatternsStrings.rareCondition(
            signs.firstWhere((s) => s.id == RareSignId.sessizTohum),
            AppDil.tr,
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('on iki yeni resim üretim boyutunda toplu görsel kontrol', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: RepaintBoundary(
          key: const ValueKey<String>('v4-contact'),
          child: Scaffold(
            body: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 250 / 400,
              children: <Widget>[
                for (final RareSignId id in RareSignId.values)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Image.asset(
                            AppIllustrations.rareSignAssets[id]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(PatternsStrings.rareTitle(id, AppDil.tr)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      for (final Image image in tester.widgetList<Image>(find.byType(Image))) {
        await precacheImage(image.image, tester.element(find.byType(Scaffold)));
      }
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) {
      await expectLater(
        find.byKey(const ValueKey<String>('v4-contact')),
        matchesGoldenFile('../../design/previews/v4/rare-art-contact.png'),
      );
    }
  });
}
