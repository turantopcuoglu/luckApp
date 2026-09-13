import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/experience_dimension.dart';
import 'package:kader/core/content/rare_sign_id.dart';
import 'package:kader/core/theme/app_theme.dart';
import 'package:kader/shared/widgets/app_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'üretim eşlemeleri tam ve tüm üretim dosyaları bundle üzerinden açılır',
    () async {
      expect(
        AppIcons.dimensionAssets.keys.toSet(),
        ExperienceDimension.values.toSet(),
      );
      expect(
        AppIllustrations.archetypeAssets.keys.toSet(),
        ExperienceDimension.values.toSet(),
      );
      expect(
        AppIllustrations.rareSignAssets.keys.toSet(),
        RareSignId.values.toSet(),
      );
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
        rootBundle,
      );
      for (final (Map<Object, String> map, int width, int height)
          in <(Map<Object, String>, int, int)>[
            (AppIllustrations.archetypeAssets, 1024, 768),
            (AppIllustrations.rareSignAssets, 1024, 1536),
          ]) {
        expect(map.values.toSet().length, map.length);
        for (final String path in map.values) {
          expect(manifest.listAssets(), contains(path));
          final ByteData bytes = await rootBundle.load(path);
          final ui.Codec codec = await ui.instantiateImageCodec(
            bytes.buffer.asUint8List(),
          );
          final ui.FrameInfo frame = await codec.getNextFrame();
          expect(frame.image.width, width);
          expect(frame.image.height, height);
          frame.image.dispose();
          codec.dispose();
        }
      }
    },
  );

  test('decode ekran/DPR ölçüsüne uyar ve masterı aşmaz', () {
    expect(AppIllustrations.decodeWidth(120, 3, 800), 360);
    expect(AppIllustrations.decodeWidth(390, 3, 1024), 1024);
    expect(AppIllustrations.decodeWidth(1080, 3, 800), 800);
    expect(AppIllustrations.decodeWidth(100.2, 2, 800), 201);
    expect(
      () => AppIllustrations.decodeWidth(double.infinity, 1, 800),
      throwsArgumentError,
    );
    expect(
      () => AppIllustrations.decodeWidth(100, 0, 800),
      throwsArgumentError,
    );
  });

  testWidgets(
    'lazy koleksiyon gridinde yalnız görünür kartlar thumbnail oluşturur',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(240, 280);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          home: GridView.builder(
            scrollCacheExtent: const ScrollCacheExtent.pixels(0),
            itemCount: RareSignId.values.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 5 / 7,
            ),
            itemBuilder: (BuildContext context, int index) =>
                AppIllustrations.rareSign(RareSignId.values[index]),
          ),
        ),
      );
      final List<Image> visible = tester
          .widgetList<Image>(find.byType(Image))
          .toList();
      expect(visible, isNotEmpty);
      expect(visible.length, lessThan(RareSignId.values.length));
      for (final Image image in visible) {
        expect((image.image as ResizeImage).width, 120);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dekoratif SVGler açılır, kapalı kart resim veya skor yüklemez', (
    WidgetTester tester,
  ) async {
    for (final Widget child in <Widget>[
      AppIllustrations.kaderCardBack(width: 160),
      AppIllustrations.pathPattern(),
      AppIllustrations.emptyPath(),
    ]) {
      await tester.pumpWidget(MaterialApp(home: Center(child: child)));
      await tester.pumpAndSettle();
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('üretim logosu DPR ölçüsünde, boyasız ve erişilebilir açılır', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AppIllustrations.kaderMark(
            size: 88,
            semanticLabel: 'Uygulama logosu',
          ),
        ),
      ),
    );
    final Image image = tester.widget<Image>(find.byType(Image));
    expect((image.image as ResizeImage).width, 264);
    expect(
      ((image.image as ResizeImage).imageProvider as AssetImage).assetName,
      AppIllustrations.markAsset,
    );
    expect(image.color, isNull);
    expect(image.semanticLabel, 'Uygulama logosu');
    expect(image.excludeFromSemantics, isFalse);
    expect(find.byType(SvgPicture), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'alan ikonları iki temada tema rengini ve semantics etiketini kullanır',
    (WidgetTester tester) async {
      for (final ThemeData theme in <ThemeData>[
        AppTheme.light,
        AppTheme.dark,
      ]) {
        for (final ExperienceDimension dimension
            in ExperienceDimension.values) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: AppIcons.dimension(
                dimension,
                semanticLabel: dimension.name,
              ),
            ),
          );
          await tester.pumpAndSettle();
          final SvgPicture svg = tester.widget<SvgPicture>(
            find.byType(SvgPicture),
          );
          expect(
            svg.colorFilter,
            ColorFilter.mode(theme.iconTheme.color!, BlendMode.srcIn),
          );
          expect(svg.semanticsLabel, dimension.name);
          expect(svg.excludeFromSemantics, isFalse);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'yalnız seçilen görseller yüklenir; thumbnail ve story çözünürlüğü ayrıdır',
    (WidgetTester tester) async {
      final _TrackingBundle bundle = _TrackingBundle();
      late BuildContext imageContext;
      Widget app(Widget child) => MaterialApp(
        home: DefaultAssetBundle(
          bundle: bundle,
          child: MediaQuery(
            data: const MediaQueryData(devicePixelRatio: 2),
            child: Builder(
              builder: (BuildContext context) {
                imageContext = context;
                return Center(child: child);
              },
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        app(
          AppIllustrations.archetype(
            ExperienceDimension.bag,
            width: 160,
            semanticLabel: 'Bağ',
          ),
        ),
      );
      await tester.runAsync(
        () => AppIllustrations.precacheArchetype(
          imageContext,
          ExperienceDimension.bag,
          logicalWidth: 160,
        ),
      );
      await tester.pump();
      Image image = tester.widget<Image>(find.byType(Image));
      expect((image.image as ResizeImage).width, 320);
      expect(image.semanticLabel, 'Bağ');
      expect(tester.getSize(find.byType(Image)), const Size(160, 120));
      expect(bundle.images.toSet(), <String>{
        AppIllustrations.archetypeAssets[ExperienceDimension.bag]!,
      });

      await tester.pumpWidget(
        app(AppIllustrations.rareSign(RareSignId.sessizTohum, width: 100)),
      );
      await tester.runAsync(
        () => AppIllustrations.precacheRareSign(
          imageContext,
          RareSignId.sessizTohum,
          logicalWidth: 100,
        ),
      );
      await tester.pump();
      image = tester.widget<Image>(find.byType(Image));
      expect((image.image as ResizeImage).width, 200);
      expect(image.excludeFromSemantics, isTrue);
      expect(tester.getSize(find.byType(Image)), const Size(100, 150));
      expect(bundle.images.toSet(), <String>{
        AppIllustrations.archetypeAssets[ExperienceDimension.bag]!,
        AppIllustrations.rareSignAssets[RareSignId.sessizTohum]!,
      });

      await tester.pumpWidget(
        app(
          AppIllustrations.rareSign(
            RareSignId.sessizTohum,
            width: 100,
            fullResolution: true,
          ),
        ),
      );
      image = tester.widget<Image>(find.byType(Image));
      expect((image.image as ResizeImage).width, 1024);
      expect(tester.takeException(), isNull);
    },
  );
}

class _TrackingBundle extends CachingAssetBundle {
  final List<String> images = <String>[];

  @override
  Future<ByteData> load(String key) {
    if ((key.endsWith('.webp') || key.endsWith('.png'))) images.add(key);
    return rootBundle.load(key);
  }
}
