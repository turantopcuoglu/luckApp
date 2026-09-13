import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_category.dart';
import 'package:kader/core/theme/app_theme.dart';
import 'package:kader/features/daily_luck/widgets/category_jewel_surface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'beş doygun malzeme ayrıdır; parlak tabanda metin kontrastı korunur',
    () {
      final Set<Color> bases = <Color>{};
      final Set<Color> accents = <Color>{};
      for (final LuckCategory category in LuckCategory.values) {
        final CategoryJewelPalette palette = CategoryJewelPalette.of(category);
        bases.add(palette.body);
        accents.add(palette.accent);
        expect(HSLColor.fromColor(palette.glow).saturation, greaterThan(.50));
        final Color lit = Color.lerp(
          palette.body,
          palette.glow,
          CategoryJewelConfig.coreTint,
        )!;
        final double background = lit.computeLuminance() + .05;
        expect(
          (palette.accent.computeLuminance() + .05) / background,
          greaterThan(4.5),
          reason: category.name,
        );
        expect(1.05 / background, greaterThan(4.5), reason: category.name);
      }
      expect(bases.length, 5);
      expect(accents.length, 5);
    },
  );

  testWidgets(
    'gren ve damar deterministiktir; kategoriye göre farklı çizilir',
    (WidgetTester tester) async {
      Future<List<int>> render(LuckCategory category, bool revealed) async {
        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final Canvas canvas = Canvas(recorder);
        const Size size = Size(80, 120);
        CategoryJewelTexture(
          category: category,
          revealed: revealed,
        ).paint(canvas, size);
        final ui.Picture picture = recorder.endRecording();
        final ui.Image image = await picture.toImage(80, 120);
        try {
          return (await image.toByteData())!.buffer.asUint8List();
        } finally {
          image.dispose();
          picture.dispose();
        }
      }

      final List<int> a = (await tester.runAsync(
        () => render(LuckCategory.ask, true),
      ))!;
      final List<int> b = (await tester.runAsync(
        () => render(LuckCategory.ask, true),
      ))!;
      final List<int> c = (await tester.runAsync(
        () => render(LuckCategory.saglik, true),
      ))!;
      final List<int> closed = (await tester.runAsync(
        () => render(LuckCategory.ask, false),
      ))!;
      expect(a.any((int value) => value != 0), isTrue);
      expect(b, a);
      expect(c, isNot(a));
      expect(closed, isNot(a));
      expect(
        const CategoryJewelTexture(
          category: LuckCategory.ask,
          revealed: true,
        ).shouldRepaint(
          const CategoryJewelTexture(
            category: LuckCategory.ask,
            revealed: true,
          ),
        ),
        isFalse,
      );
    },
  );

  testWidgets('doku dokunmayı engellemez; etiket tek kez okunur', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    final SemanticsHandle semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 80,
                child: CategoryJewelSurface(
                  category: LuckCategory.sosyal,
                  revealed: true,
                  onTap: () => taps++,
                  child: const SizedBox(
                    height: 96,
                    child: Center(child: Text('Sosyal')),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Sosyal'), findsOneWidget);
      await tester.tap(find.text('Sosyal'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
