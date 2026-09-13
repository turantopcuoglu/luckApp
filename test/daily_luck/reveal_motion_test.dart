import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// QA-only GIF encoder already present via the native icon tooling; no app dependency added.
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as raster;
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/theme/app_motion.dart';
import 'package:kader/core/theme/app_theme.dart';
import 'package:kader/core/theme/app_typography.dart';
import 'package:kader/core/theme/cosmic_config.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/daily_luck/reveal_controller.dart';
import 'package:kader/features/daily_luck/today_providers.dart';
import 'package:kader/features/daily_luck/today_strings.dart';
import 'package:kader/features/daily_luck/widgets/card_reveal_motion.dart';
import 'package:kader/features/daily_luck/widgets/result_entry_motion.dart';
import 'package:kader/features/daily_luck/widgets/today_content.dart';
import 'package:kader/features/history/history_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final DateTime day = DateTime(2026, 9, 7);
  final LuckResult result = const LuckEngine().hesapla(
    kullanici: UserSeed.fromRituelKimligi('motion-id'),
    gun: day,
  );
  late Completer<void> pending;
  late _Haptics haptics;
  late ValueNotifier<bool> visible;
  late ValueNotifier<bool> reduced;
  late int writes;
  setUpAll(() async {
    for (final (String family, String asset) in <(String, String)>[
      (AppTypography.bodyFamily, AppTypography.bodyAsset),
      (AppTypography.headingFamily, AppTypography.headingAsset),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(asset))).load();
    }
  });
  setUp(() {
    pending = Completer<void>();
    haptics = _Haptics();
    visible = ValueNotifier<bool>(true);
    reduced = ValueNotifier<bool>(false);
    writes = 0;
    TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
  });
  tearDown(() {
    visible.dispose();
    reduced.dispose();
  });
  Widget app({bool opened = false}) => ProviderScope(
    overrides: <Override>[
      cosmicMotionEnabledProvider.overrideWithValue(false),
      aktifProfilProvider.overrideWithValue(
        const UserProfile(
          isim: 'Ada',
          rituelKimligi: 'motion-id',
          seedSurumu: 2,
        ),
      ),
      dilProvider.overrideWithValue(AppDil.tr),
      bugunProvider.overrideWithValue(day),
      tumKayitlarProvider.overrideWithValue(const []),
      todayRevealedProvider(day).overrideWith((Ref ref) => opened),
      gununSansiProvider.overrideWith(
        (Ref ref) => Future<LuckResult>.value(result),
      ),
      revealWriterProvider.overrideWithValue((
        DateTime target,
        DateTime timestamp,
      ) {
        writes++;
        expect(target, day);
        return pending.future;
      }),
      revealHapticsProvider.overrideWithValue(haptics),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      builder: (BuildContext context, Widget? child) => ListenableBuilder(
        listenable: Listenable.merge(<Listenable>[visible, reduced]),
        builder: (BuildContext context, Widget? _) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduced.value),
          child: TickerMode(enabled: visible.value, child: child!),
        ),
      ),
      home: const RepaintBoundary(
        key: ValueKey<String>('reveal-preview'),
        child: DailyLuckScreen(),
      ),
    ),
  );
  Future<void> start(
    WidgetTester tester, {
    bool opened = false,
    bool doubleTap = false,
  }) async {
    // Kontrollü Future widget testinin FakeAsync bölgesinde oluşturulur.
    pending = Completer<void>();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(opened: opened));
    await tester.pumpAndSettle();
    if (!opened) {
      await tester.ensureVisible(find.text(TodayStrings.open(AppDil.tr)));
      await tester.tap(find.text(TodayStrings.open(AppDil.tr)));
      if (doubleTap) await tester.tap(find.text(TodayStrings.open(AppDil.tr)));
      await tester.pump();
    }
  }

  testWidgets('yazım bitmeden skor yok; mühür ve sonuç haptic birer kez', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    try {
      await start(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(haptics.seals, 1);
      expect(writes, 0);
      expect(
        find.byType(TodayRevealedContent, skipOffstage: false),
        findsNothing,
      );
      expect(find.byType(CosmicScoreHero, skipOffstage: false), findsNothing);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump();
      expect(writes, 1);
      expect(find.text(TodayStrings.saving(AppDil.tr)), findsOneWidget);
      expect(find.byType(TodayRevealedContent), findsNothing);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byType(TodayRevealedContent), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          RegExp(
            RegExp.escape(TodayStrings.scoreValue(AppDil.tr, result.genelSkor)),
          ),
        ),
        findsOneWidget,
      );
      expect(haptics.results, 1);
      expect(haptics.seals, 1);
    } finally {
      semantics.dispose();
    }
  });
  testWidgets('reduced motion: statik kart, sıfır haptic ve kısa sonuç fade', (
    WidgetTester tester,
  ) async {
    reduced.value = true;
    await start(tester);
    expect(
      tester
          .widget<CardRevealMotion>(find.byType(CardRevealMotion))
          .reducedMotion,
      isTrue,
    );
    expect(writes, 1);
    expect(haptics.seals, 0);
    pending.complete();
    await tester.pump();
    await tester.pump();
    await tester.pump(AppMotion.reduced);
    final Finder opacity = find
        .descendant(
          of: find.byType(ResultContentFade).first,
          matching: find.byType(Opacity),
        )
        .first;
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    expect(haptics.results, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('önceden açılan kart animasyon yazım veya haptic tekrarlamaz', (
    WidgetTester tester,
  ) async {
    await start(tester, opened: true);
    expect(find.byType(CardRevealMotion), findsOneWidget);
    expect(
      tester
          .widget<CardRevealMotion>(find.byType(CardRevealMotion))
          .animation
          .value,
      1,
    );
    expect(
      tester
          .widget<TodayResultEntrance>(find.byType(TodayResultEntrance))
          .animate,
      isFalse,
    );
    expect(writes, 0);
    expect(haptics.seals + haptics.results, 0);
  });

  testWidgets(
    'aynı frame içinde çift dokunma tek koreografi ve yazım oluşturur',
    (WidgetTester tester) async {
      await start(tester, doubleTap: true);
      await tester.pumpAndSettle();
      expect(writes, 1);
      expect(haptics.seals, 1);
      pending.complete();
      await tester.pumpAndSettle();
      expect(haptics.results, 1);
      expect(find.byType(TodayRevealedContent), findsOneWidget);
    },
  );
  testWidgets('gizli sekmede durur; geri gelince kaldığı yerden devam eder', (
    WidgetTester tester,
  ) async {
    await start(tester);
    await tester.pump(const Duration(milliseconds: 250));
    visible.value = false;
    await tester.pump();
    final Animation<double> progress = tester
        .widget<CardRevealMotion>(find.byType(CardRevealMotion))
        .animation;
    final double paused = progress.value;
    await tester.pump(const Duration(seconds: 5));
    expect(progress.value, paused);
    expect(writes, 0);
    visible.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    expect(writes, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(TodayRevealedContent), findsOneWidget);
  });
  testWidgets(
    'açılış sırasında hareket azaltılırsa kalan tilt/haptic atlanır',
    (WidgetTester tester) async {
      await start(tester);
      await tester.pump(const Duration(milliseconds: 50));
      reduced.value = true;
      await tester.pumpAndSettle();
      expect(writes, 1);
      expect(haptics.seals, 0);
      pending.complete();
      await tester.pumpAndSettle();
      expect(haptics.results, 0);
    },
  );
  testWidgets('uygulama arka planda açılışı durdurur ve sessizce bekler', (
    WidgetTester tester,
  ) async {
    await start(tester);
    await tester.pump(const Duration(milliseconds: 400));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    final Animation<double> progress = tester
        .widget<CardRevealMotion>(find.byType(CardRevealMotion))
        .animation;
    final double paused = progress.value;
    await tester.pump(const Duration(seconds: 4));
    expect(progress.value, paused);
    expect(writes, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1300));
    expect(writes, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    pending.complete();
    await tester.pump();
    expect(haptics.results, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(TodayRevealedContent), findsOneWidget);
  });
  testWidgets(
    'disk hatası retry ikinci animasyon veya mühür haptic başlatmaz',
    (WidgetTester tester) async {
      await start(tester);
      await tester.pumpAndSettle();
      pending.completeError(StateError('disk'));
      await tester.pumpAndSettle();
      expect(find.text(TodayStrings.revealError(AppDil.tr)), findsOneWidget);
      expect(find.byType(TodayRevealedContent), findsNothing);
      pending = Completer<void>();
      await tester.ensureVisible(find.text(TodayStrings.retry(AppDil.tr)));
      await tester.tap(find.text(TodayStrings.retry(AppDil.tr)));
      await tester.pump();
      expect(writes, 2);
      pending.complete();
      await tester.pumpAndSettle();
      expect(haptics.seals, 1);
      expect(find.byType(TodayRevealedContent), findsOneWidget);
    },
  );
  for (final bool saving in <bool>[false, true]) {
    testWidgets(
      'dispose saving=$saving: geç callback state/rota hatası üretmez',
      (WidgetTester tester) async {
        await start(tester);
        if (saving) {
          await tester.pumpAndSettle();
        } else {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pumpWidget(const SizedBox());
        if (saving) pending.complete();
        await tester.pump(const Duration(seconds: 3));
        expect(writes, saving ? 1 : 0);
        expect(haptics.results, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('mühür ışık katman sahnelerinin gerçek Flutter önizlemeleri', (
    WidgetTester tester,
  ) async {
    await start(tester);
    for (final (int delta, String name) in <(int, String)>[
      (300, 'seal'),
      (280, 'seam'),
      (540, 'unfold'),
    ]) {
      await tester.pump(Duration(milliseconds: delta));
      if (const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) {
        await expectLater(
          find.byKey(const ValueKey<String>('reveal-preview')),
          matchesGoldenFile('../../design/previews/kader-reveal-$name.png'),
        );
      }
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('V6 gerçek uygulama açılışının 20 fps inceleme animasyonu', (
    tester,
  ) async {
    if (!const bool.fromEnvironment('KADER_WRITE_PREVIEWS')) return;
    await start(tester);
    await tester.runAsync(() async {
      for (final Image image in tester.widgetList<Image>(find.byType(Image))) {
        await precacheImage(
          image.image,
          tester.element(find.byType(DailyLuckScreen)),
        );
      }
    });
    await tester.pump();
    final raster.GifEncoder gif = raster.GifEncoder(samplingFactor: 20);
    for (int frame = 0; frame <= 52; frame++) {
      if (frame > 0) await tester.pump(const Duration(milliseconds: 50));
      if (frame == 26) {
        pending.complete();
        await tester.pump();
      }
      await tester.runAsync(() async {
        final RenderRepaintBoundary boundary = tester.renderObject(
          find.byKey(const ValueKey<String>('reveal-preview')),
        );
        final ui.Image image = await boundary.toImage();
        try {
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List();
          gif.addFrame(
            raster.decodePng(bytes)!,
            duration: frame == 52 ? 100 : 5,
          );
          if (<int>[0, 5, 13, 20, 26, 40].contains(frame)) {
            final File file = File(
              'design/previews/v6/reveal-${frame * 50}ms.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes);
          }
        } finally {
          image.dispose();
        }
      });
    }
    await tester.runAsync(() async {
      await File(
        'design/previews/v6/reveal-motion.gif',
      ).writeAsBytes(gif.finish()!);
    });
    expect(find.byType(TodayRevealedContent), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Haptics extends RevealHaptics {
  int seals = 0;
  int results = 0;
  @override
  Future<void> seal() async {
    seals++;
  }

  @override
  Future<void> result() async {
    results++;
  }
}
