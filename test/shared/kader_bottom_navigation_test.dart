import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/theme/app_theme.dart';
import 'package:kader/core/theme/app_typography.dart';
import 'package:kader/features/shell/shell_strings.dart';
import 'package:kader/shared/widgets/kader_bottom_navigation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      AppTypography.bodyFamily,
    )..addFont(rootBundle.load(AppTypography.bodyAsset))).load();
  });

  for (final AppDil language in AppDil.values) {
    for (final double width in <double>[320, 390, 430]) {
      for (final double scale in <double>[1, 2]) {
        testWidgets(
          '${language.name} $width px ${scale}x metin: taşma yok ve erişilebilir seçim',
          (WidgetTester tester) async {
            tester.view.physicalSize = Size(width, 568);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final SemanticsHandle semantics = tester.ensureSemantics();
            int? selected;
            try {
              await tester.pumpWidget(
                MaterialApp(
                  theme: AppTheme.dark,
                  builder: (BuildContext context, Widget? child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(scale),
                      disableAnimations: true,
                    ),
                    child: child!,
                  ),
                  home: Scaffold(
                    bottomNavigationBar: KaderBottomNavigation(
                      items: <KaderNavigationItem>[
                        KaderNavigationItem(
                          label: ShellStrings.today(language),
                          icon: Icons.today_outlined,
                        ),
                        KaderNavigationItem(
                          label: ShellStrings.patterns(language),
                          icon: Icons.grid_view_rounded,
                        ),
                        KaderNavigationItem(
                          label: ShellStrings.profile(language),
                          icon: Icons.person_outline_rounded,
                        ),
                      ],
                      selectedIndex: 0,
                      onSelected: (int value) => selected = value,
                    ),
                  ),
                ),
              );
              expect(tester.takeException(), isNull);
              final Finder today = find.bySemanticsLabel(
                ShellStrings.today(language),
              );
              expect(
                tester
                    .getSemantics(today)
                    .getSemanticsData()
                    .flagsCollection
                    .isSelected,
                Tristate.isTrue,
              );
              final Finder patterns = find.bySemanticsLabel(
                ShellStrings.patterns(language),
              );
              expect(
                tester
                    .getSemantics(patterns)
                    .getSemanticsData()
                    .flagsCollection
                    .isSelected,
                Tristate.isFalse,
              );
              for (final Element element in find.byType(InkWell).evaluate()) {
                final Size size = tester.getSize(find.byWidget(element.widget));
                expect(size.width, greaterThanOrEqualTo(48));
                expect(size.height, greaterThanOrEqualTo(48));
              }
              await tester.tap(find.text(ShellStrings.patterns(language)));
              await tester.pumpAndSettle();
              expect(selected, 1);
              expect(tester.takeException(), isNull);
              expect(
                tester
                    .widget<AnimatedContainer>(
                      find.byType(AnimatedContainer).first,
                    )
                    .duration,
                Duration.zero,
              );
            } finally {
              semantics.dispose();
            }
          },
        );
      }
    }
  }
}
