import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/experience_dimension.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/theme/app_colors.dart';
import 'package:kader/core/theme/app_dimens.dart';
import 'package:kader/core/theme/app_motion.dart';
import 'package:kader/core/theme/app_theme.dart';
import 'package:kader/core/theme/app_typography.dart';
import 'package:kader/shared/widgets/kader_button.dart';
import 'package:kader/shared/widgets/kader_card.dart';
import 'package:kader/shared/widgets/kader_chip.dart';
import 'package:kader/shared/widgets/kader_scaffold.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Ağ veya makinede yüklü font yerine üretimdeki aynı bundle'ı yükle.
    for (final (String family, String asset) in <(String, String)>[
      (AppTypography.bodyFamily, AppTypography.bodyAsset),
      (AppTypography.headingFamily, AppTypography.headingAsset),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(asset))).load();
    }
  });

  for (final Brightness brightness in Brightness.values) {
    final ThemeData theme = brightness == Brightness.light
        ? AppTheme.light
        : AppTheme.dark;
    test(
      '${brightness.name} metin/eylem renk çiftleri AA kontrastını geçer',
      () {
        final ColorScheme colors = theme.colorScheme;
        for (final (Color foreground, Color background) in <(Color, Color)>[
          (colors.onSurface, colors.surface),
          (colors.onSurfaceVariant, colors.surface),
          (colors.onSurface, theme.scaffoldBackgroundColor),
          (colors.onSurfaceVariant, theme.scaffoldBackgroundColor),
          (colors.onPrimary, colors.primary),
          (colors.onSecondary, colors.secondary),
          (colors.onTertiary, colors.tertiary),
          (colors.onTertiaryContainer, colors.tertiaryContainer),
          (colors.onInverseSurface, colors.inverseSurface),
          (colors.inversePrimary, colors.inverseSurface),
          (colors.error, colors.surface),
          (colors.onError, colors.error),
        ]) {
          expect(
            _contrast(foreground, background),
            greaterThanOrEqualTo(4.5),
            reason: '$foreground / $background',
          );
        }
        expect(
          _contrast(colors.outline, colors.surface),
          greaterThanOrEqualTo(3),
        );
        expect(
          _contrast(colors.outline, theme.scaffoldBackgroundColor),
          greaterThanOrEqualTo(3),
        );
        expect(
          theme.filledButtonTheme.style!.backgroundColor!.resolve(
            <WidgetState>{},
          ),
          AppColors.electricLime,
        );
        expect(theme.textTheme.bodyLarge!.fontFamily, AppTypography.bodyFamily);
        expect(
          theme.textTheme.headlineMedium!.fontFamily,
          AppTypography.headingFamily,
        );
        expect(
          theme.textTheme.displayLarge!.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      },
    );

    for (final double width in <double>[320, 390, 430]) {
      for (final double scale in <double>[1, 2]) {
        for (final AppDil language in AppDil.values) {
          testWidgets(
            '${brightness.name} ${width.toInt()}px ${scale}x ${language.name} taşmaz ve son eyleme ulaşılır',
            (WidgetTester tester) async {
              tester.view.devicePixelRatio = 1;
              tester.view.physicalSize = Size(width, 568);
              addTearDown(tester.view.resetDevicePixelRatio);
              addTearDown(tester.view.resetPhysicalSize);
              await tester.pumpWidget(
                MaterialApp(
                  theme: theme,
                  builder: (BuildContext context, Widget? child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(scale)),
                    child: child!,
                  ),
                  home: _gallery(language),
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              await tester.ensureVisible(
                find.byKey(const ValueKey<String>('last-action')),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              expect(
                find.byKey(const ValueKey<String>('last-action')).hitTestable(),
                findsOneWidget,
              );
              for (final Element element
                  in find.byType(KaderButton).evaluate()) {
                final Size size = tester.getSize(find.byWidget(element.widget));
                expect(
                  size.height,
                  greaterThanOrEqualTo(AppLayout.buttonMinHeight),
                );
                expect(size.width, lessThanOrEqualTo(width));
              }
              for (final Element element in find.byType(KaderChip).evaluate()) {
                final Size size = tester.getSize(find.byWidget(element.widget));
                expect(
                  size.height,
                  greaterThanOrEqualTo(AppLayout.minTouchTarget),
                );
                expect(
                  size.width,
                  greaterThanOrEqualTo(AppLayout.minTouchTarget),
                );
              }
            },
          );
        }
      }
    }

    testWidgets('${brightness.name} bileşen önizlemesi', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 1000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: RepaintBoundary(
            key: const ValueKey<String>('preview'),
            child: _gallery(AppDil.tr),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Yalnız istenince gerçek Flutter çizimini tasarım incelemesi için üretir.
      // Platform/font raster farkını normal CI testine golden bağımlılığı yapmaz.
      if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) {
        await expectLater(
          find.byKey(const ValueKey<String>('preview')),
          matchesGoldenFile(
            '../../design/previews/kader-foundation-${brightness.name}.png',
          ),
        );
      }
    });
  }

  testWidgets('buton ve chip klavye, seçim ve disabled semantics taşır', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    try {
      int calls = 0;
      bool? nextSelection;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: KaderScaffold(
            body: Column(
              children: <Widget>[
                KaderButton(label: 'Kartı aç', onPressed: () => calls++),
                const KaderButton(label: 'Kapalı eylem', onPressed: null),
                KaderChip(
                  label: 'Bağ',
                  selected: true,
                  onSelected: (bool next) => nextSelection = next,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Kartı aç')),
        matchesSemantics(
          label: 'Kartı aç',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester
            .getSemantics(find.text('Kapalı eylem'))
            .getSemanticsData()
            .flagsCollection
            .isEnabled,
        Tristate.isFalse,
      );
      expect(
        tester
            .getSemantics(find.byType(KaderChip))
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(calls, 1);
      await tester.tap(find.text('Bağ'));
      expect(nextSelection, isFalse);
      await tester.tap(find.text('Kapalı eylem'));
      expect(calls, 1);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('yükleme çift dokunmayı engeller, azaltılmış harekette dönmez', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: KaderScaffold(
            body: KaderButton(
              label: 'Kaydet',
              loadingLabel: 'Kaydediliyor',
              isLoading: true,
              onPressed: () => calls++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydediliyor'));
    await tester.tap(find.text('Kaydediliyor'));
    expect(calls, 0);
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      1,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'sistem veya kullanıcı hareket azaltabilir; sistem tercihi bastırılmaz',
    (WidgetTester tester) async {
      for (final bool system in <bool>[false, true]) {
        for (final bool? user in <bool?>[null, false, true]) {
          late bool reduced;
          late Duration duration;
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: system),
                child: Builder(
                  builder: (BuildContext context) {
                    reduced = AppMotion.reduceMotion(
                      context,
                      userPreference: user,
                    );
                    duration = AppMotion.duration(
                      context,
                      AppMotion.reveal,
                      userPreference: user,
                    );
                    return const SizedBox();
                  },
                ),
              ),
            ),
          );
          expect(reduced, system || user == true);
          expect(duration, reduced ? AppMotion.reduced : AppMotion.reveal);
        }
      }
    },
  );

  testWidgets(
    'scaffold tablet genişliğini sınırlar ve klavye/safe area içeriği kapatmaz',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 700);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(1000, 700),
              padding: EdgeInsets.only(top: 24, bottom: 16),
              viewInsets: EdgeInsets.only(bottom: 260),
            ),
            child: KaderScaffold(
              scrollable: true,
              body: Column(
                children: <Widget>[
                  const SizedBox(height: 700),
                  KaderButton(label: 'Görünür eylem', onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.ensureVisible(find.byType(KaderButton));
      await tester.pumpAndSettle();
      final Rect bounds = tester.getRect(find.byType(KaderButton));
      expect(
        bounds.width,
        lessThanOrEqualTo(AppLayout.maxContentWidth - AppSpacing.lg * 2),
      );
      expect(bounds.top, greaterThanOrEqualTo(24));
      expect(bounds.bottom, lessThanOrEqualTo(700 - 260));
      expect(tester.takeException(), isNull);
    },
  );

  test('font lisansları uygulama içinden okunabilir', () async {
    AppTypography.registerLicenses();
    for (final String font in <String>['Inter', 'PlayfairDisplay']) {
      final String license = await rootBundle.loadString(
        'assets/fonts/$font-OFL.txt',
      );
      expect(license, contains('SIL OPEN FONT LICENSE'));
    }
  });

  test('paketlenmiş skor fontunda farklı rakamlar aynı genişliktedir', () {
    double width(String value) {
      final TextPainter painter = TextPainter(
        text: TextSpan(text: value, style: AppTypography.score),
        textDirection: TextDirection.ltr,
      )..layout();
      final double result = painter.width;
      painter.dispose();
      return result;
    }

    expect(width('111'), closeTo(width('888'), 0.01));
    expect(width('10'), closeTo(width('99'), 0.01));
  });

  testWidgets('disabled chip seçimi korur fakat yeni eylem sunmaz', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const KaderScaffold(
          body: KaderChip(
            label: 'Bağ',
            selected: true,
            onSelected: null,
            reduceMotion: true,
          ),
        ),
      ),
    );
    final OutlinedButton button = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton),
    );
    expect(button.onPressed, isNull);
    expect(button.style!.animationDuration, Duration.zero);
    expect(
      button.style!.foregroundColor!.resolve(<WidgetState>{
        WidgetState.disabled,
      }),
      AppColors.mutedOnCream,
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}

double _contrast(Color a, Color b) {
  final double first = a.computeLuminance();
  final double second = b.computeLuminance();
  return first > second
      ? (first + 0.05) / (second + 0.05)
      : (second + 0.05) / (first + 0.05);
}

Widget _gallery(AppDil language) => KaderScaffold(
  scrollable: true,
  body: Builder(
    builder: (BuildContext context) {
      final TextTheme text = Theme.of(context).textTheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Kader', style: text.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            language.sec(
              'Gününe küçük bir alan aç.',
              'Make a little room for your day.',
            ),
            style: text.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          KaderCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  language.sec('BUGÜNÜN RİTMİ', 'TODAY’S RHYTHM'),
                  style: text.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  language.sec('Küçük bir başlangıç', 'A small beginning'),
                  style: text.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  language.sec(
                    'Bugün kendine iki dakika ayır. Masanda yalnızca bir şeyi yerine koy.',
                    'Take two minutes for yourself today. Put just one thing on your desk back in its place.',
                  ),
                  style: text.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final ExperienceDimension dimension
                  in ExperienceDimension.gosterimSirasi)
                KaderChip(
                  label: dimension.etiket(language),
                  selected: dimension == ExperienceDimension.akis,
                  onSelected: (_) {},
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          KaderButton(
            label: language.sec('Bugünün işaretini aç', 'Open today’s sign'),
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          KaderButton(
            label: language.sec(
              'Kendi ritmini keşfet',
              'Explore your own rhythm',
            ),
            variant: KaderButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          KaderButton(
            key: const ValueKey<String>('last-action'),
            label: language.sec(
              'Bugününü sevdiklerinle paylaş',
              'Share a little of your day with the people you love',
            ),
            icon: Icons.ios_share,
            variant: KaderButtonVariant.secondary,
            onPressed: () {},
          ),
        ],
      );
    },
  ),
);
