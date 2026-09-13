import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/shared/widgets/app_illustrations.dart';

void main() {
  testWidgets('üretim amblemi ikon ve güvenli native katman üretir', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final bytes = await rootBundle.load(AppIllustrations.markAsset);
    await tester.runAsync(() async {
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes.buffer.asUint8List(),
      );
      try {
        final ui.FrameInfo frame = await codec.getNextFrame();
        try {
          expect(frame.image.width, AppIllustrations.markMasterWidth);
          expect(frame.image.height, AppIllustrations.markMasterWidth);
          final pixels = (await frame.image.toByteData())!.buffer.asUint8List();
          // Dama deseni veya beyaz sahte şeffaflık yok: köşe koyu lacivert.
          expect(pixels[2], greaterThan(pixels[0]));
          expect(pixels[3], 255);
        } finally {
          frame.image.dispose();
        }
      } finally {
        codec.dispose();
      }
    });
    for (final bool foreground in <bool>[false, true]) {
      final Image logo = Image.asset(
        AppIllustrations.markAsset,
        fit: BoxFit.cover,
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: const ValueKey<String>('brand-export'),
            child: ColoredBox(
              color: foreground ? Colors.transparent : const Color(0xFF041428),
              child: SizedBox.expand(child: logo),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => precacheImage(logo.image, tester.element(find.byType(Image))),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('KADER_EXPORT_BRAND')) {
        final RenderRepaintBoundary box = tester.renderObject(
          find.byKey(const ValueKey<String>('brand-export')),
        );
        await tester.runAsync(() async {
          final ui.Image image = await box.toImage();
          try {
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            final String path = foreground
                ? 'assets/launcher/cosmic-foreground-v4.png'
                : 'assets/launcher/cosmic-icon-v4.png';
            await File(path).parent.create(recursive: true);
            await File(path).writeAsBytes(data!.buffer.asUint8List());
          } finally {
            image.dispose();
          }
        });
      }
    }
  });
}
