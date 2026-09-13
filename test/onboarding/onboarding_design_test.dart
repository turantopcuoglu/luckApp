import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
// QA-only: encoder is already installed by native icon tools.
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as raster;
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_repository.dart';
import 'package:kader/core/theme/app_theme.dart';
import 'package:kader/core/theme/app_typography.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/onboarding/calculating_screen.dart';
import 'package:kader/features/onboarding/card_preparation_motion.dart';
import 'package:kader/features/onboarding/onboarding_strings.dart';
import 'package:kader/features/onboarding/profile_form_screen.dart';
import 'package:kader/features/onboarding/welcome_screen.dart';
import 'package:kader/shared/widgets/cosmic_scene.dart';
import 'package:kader/shared/widgets/kader_button.dart';

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

  Widget app(
    Widget child, {
    AppDil language = AppDil.tr,
    double scale = 1,
    bool reduced = false,
    _ControlledRepository? repo,
  }) => ProviderScope(
    overrides: <Override>[
      dilProvider.overrideWithValue(language),
      if (repo != null) userRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: reduced,
        ),
        child: child!,
      ),
      home: child,
    ),
  );

  void viewport(WidgetTester tester, double width, double height) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, height);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  }

  for (final double width in <double>[320, 390, 430]) {
    for (final double scale in <double>[1, 2]) {
      for (final AppDil language in AppDil.values) {
        testWidgets(
          'Ad/rumuz ${width}px ${scale}x ${language.name}: klavye ile taşmaz ve eyleme ulaşılır',
          (WidgetTester tester) async {
            viewport(tester, width, 568);
            await tester.pumpWidget(
              app(
                const ProfileFormScreen(),
                language: language,
                scale: scale,
                repo: _ControlledRepository(),
              ),
            );
            await tester.pumpAndSettle();
            expect(find.byType(TextField), findsOneWidget);
            await tester.ensureVisible(find.byType(TextField));
            await tester.enterText(find.byType(TextField), 'Ada');
            tester.view.viewInsets = const FakeViewPadding(bottom: 260);
            addTearDown(tester.view.resetViewInsets);
            await tester.pumpAndSettle();
            await tester.ensureVisible(find.byType(KaderButton));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(
              tester.getRect(find.byType(KaderButton)).bottom,
              lessThanOrEqualTo(308),
            );
          },
        );

        testWidgets(
          'Başla ${width}px ${scale}x ${language.name}: merkezli, tam genişlikte ve taşmasız',
          (WidgetTester tester) async {
            viewport(tester, width, 568);
            await tester.pumpWidget(
              app(const WelcomeScreen(), language: language, scale: scale),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final Rect button = tester.getRect(find.byType(KaderButton));
            final Rect title = tester.getRect(find.text('Kader'));
            expect(button.center.dx, closeTo(width / 2, 0.01));
            expect(title.center.dx, closeTo(width / 2, 0.01));
            expect(button.width, closeTo(width - 48, 0.01));
            await tester.ensureVisible(find.byType(KaderButton));
            await tester.pumpAndSettle();
            expect(find.byType(KaderButton).hitTestable(), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  for (final bool reduced in <bool>[false, true]) {
    testWidgets(
      'hazırlama reduced=$reduced: tamamlanır, kaydı bekler ve gizli sonucu yüklemez',
      (WidgetTester tester) async {
        viewport(tester, 320, 568);
        final _ControlledRepository repo = _ControlledRepository();
        await tester.pumpWidget(
          app(
            const CalculatingScreen(),
            scale: 2,
            reduced: reduced,
            repo: repo,
          ),
        );
        await tester.pump();
        expect(
          tester
              .widget<CardPreparationMotion>(find.byType(CardPreparationMotion))
              .reducedMotion,
          reduced,
        );
        // V4: tek sabit maske yalnız cam bitmap'in dışını yumuşatır;
        // hareket azaltmada dalga zamanı sabittir, dönen shader yoktur.
        if (reduced) expect(find.byType(ShaderMask), findsOneWidget);
        await tester.pump(Duration(milliseconds: reduced ? 200 : 1700));
        await tester.pump();
        expect(repo.calls, 1);
        expect(find.byType(CalculatingScreen), findsOneWidget);
        expect(find.byType(CosmicPortal), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pump(const Duration(seconds: 3));
        expect(repo.calls, 1);
        await tester.pumpWidget(const SizedBox());
        repo.pending.complete();
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'animasyon sürerken dispose controller veya geçiş hatası üretmez',
    (WidgetTester tester) async {
      final _ControlledRepository repo = _ControlledRepository();
      await tester.pumpWidget(app(const CalculatingScreen(), repo: repo));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
      expect(repo.calls, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'kayıt hatasında tekrar denenebilir ve çift dokunma ikinci yazım başlatmaz',
    (WidgetTester tester) async {
      final _ControlledRepository repo = _ControlledRepository();
      await tester.pumpWidget(
        app(const CalculatingScreen(), reduced: true, repo: repo),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      repo.pending.completeError(StateError('disk'));
      await tester.pumpAndSettle();
      expect(
        find.text(OnboardingStrings.hazirlamaHatasi(AppDil.tr)),
        findsOneWidget,
      );
      expect(
        find.text(OnboardingStrings.tekrarDene(AppDil.tr)),
        findsOneWidget,
      );
      repo.pending = Completer<void>();
      await tester.tap(find.text(OnboardingStrings.tekrarDene(AppDil.tr)));
      await tester.tap(find.text(OnboardingStrings.tekrarDene(AppDil.tr)));
      expect(repo.calls, 2);
      await tester.pumpWidget(const SizedBox());
      repo.pending.complete();
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ad rumuz formu gerçek Flutter önizlemesi', (
    WidgetTester tester,
  ) async {
    viewport(tester, 390, 844);
    await tester.pumpWidget(
      app(
        const RepaintBoundary(
          key: ValueKey<String>('profile-preview'),
          child: ProfileFormScreen(),
        ),
        repo: _ControlledRepository(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) {
      await expectLater(
        find.byKey(const ValueKey<String>('profile-preview')),
        matchesGoldenFile('../../design/previews/kader-onboarding-profile.png'),
      );
    }
  });

  testWidgets('karşılama ve hazırlama gerçek Flutter önizlemeleri', (
    WidgetTester tester,
  ) async {
    viewport(tester, 390, 844);
    for (final bool preparing in <bool>[false, true]) {
      await tester.pumpWidget(
        app(
          RepaintBoundary(
            key: const ValueKey<String>('onboarding-preview'),
            child: preparing
                ? const CalculatingScreen()
                : const WelcomeScreen(),
          ),
          repo: _ControlledRepository(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) {
        await expectLater(
          find.byKey(const ValueKey<String>('onboarding-preview')),
          matchesGoldenFile(
            '../../design/previews/kader-${preparing ? 'preparing' : 'welcome'}.png',
          ),
        );
      }
    }
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('V4 gerçek dolum animasyonunun inceleme GIF çıktısı', (
    tester,
  ) async {
    if (!const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) return;
    viewport(tester, 390, 844);
    await tester.pumpWidget(
      app(
        const RepaintBoundary(
          key: ValueKey<String>('orb-export'),
          child: CalculatingScreen(),
        ),
        repo: _ControlledRepository(),
      ),
    );
    await tester.runAsync(() async {
      for (final Image image in tester.widgetList<Image>(find.byType(Image))) {
        await precacheImage(
          image.image,
          tester.element(find.byType(CalculatingScreen)),
        );
      }
    });
    await tester.pump();
    final raster.GifEncoder gif = raster.GifEncoder(samplingFactor: 20);
    for (int frame = 0; frame <= 40; frame++) {
      if (frame > 0) await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(() async {
        final RenderRepaintBoundary boundary = tester.renderObject(
          find.byKey(const ValueKey<String>('orb-export')),
        );
        final ui.Image image = await boundary.toImage();
        try {
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List();
          gif.addFrame(
            raster.decodePng(bytes)!,
            duration: frame == 40 ? 100 : 5,
          );
        } finally {
          image.dispose();
        }
      });
    }
    await tester.runAsync(() async {
      final File file = File('design/previews/v4/preparation-motion.gif');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(gif.finish()!);
    });
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}

class _ControlledRepository extends UserRepository {
  _ControlledRepository() : super(_UnusedBox());
  @override
  UserProfile? profil() => null;
  int calls = 0;
  Completer<void> pending = Completer<void>();

  @override
  Future<void> onboardingTamamla() {
    calls++;
    return pending.future;
  }
}

class _UnusedBox implements Box<Map<dynamic, dynamic>> {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
