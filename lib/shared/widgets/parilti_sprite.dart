import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'app_images.dart';

/// Dört uçlu parıltı sprite'ının ([AppImages.parilti]) paylaşılan,
/// bir kez çözülmüş hâli.
///
/// CustomPainter'lar her karede görseli çizer; görseli widget ağacına
/// koymak yerine `ui.Image` olarak tutmak, onlarca kıvılcımı tek
/// boyamada çizmeyi sağlar. Görsel henüz çözülmediyse [goruntu] null'dır
/// ve ressamlar yumuşak daireye geri düşer.
abstract final class PariltiSprite {
  static ui.Image? _goruntu;
  static ImageStream? _akis;
  static ImageStreamListener? _dinleyici;

  /// Çözülmüş sprite (henüz yoksa null).
  static ui.Image? get goruntu => _goruntu;

  /// Sprite'ı (bir kez) çözmeye başlar; tekrar çağrılması zararsızdır.
  static void yukle(BuildContext context) {
    if (_goruntu != null || _akis != null) {
      return;
    }
    final ImageStream akis = const AssetImage(
      AppImages.parilti,
    ).resolve(createLocalImageConfiguration(context));
    final ImageStreamListener dinleyici = ImageStreamListener(
      (ImageInfo bilgi, bool senkron) {
        // Kendi tutamacımız: önbellek görseli bıraksa da sprite yaşar.
        _goruntu = bilgi.image.clone();
        _birak();
      },
      onError: (Object hata, StackTrace? iz) => _birak(),
    );
    _akis = akis;
    _dinleyici = dinleyici;
    akis.addListener(dinleyici);
  }

  static void _birak() {
    final ImageStreamListener? dinleyici = _dinleyici;
    if (dinleyici != null) {
      _akis?.removeListener(dinleyici);
    }
    _dinleyici = null;
  }

  /// [merkez]'e [kenar] boyunda, [renk] ile boyanmış ve [opaklik]
  /// saydamlığında sprite çizer. Sprite yoksa yumuşak bir daire çizer.
  static void ciz(
    Canvas canvas,
    Offset merkez,
    double kenar,
    Color renk,
    double opaklik,
  ) {
    final ui.Image? g = _goruntu;
    if (g == null) {
      canvas.drawCircle(
        merkez,
        kenar / 8,
        Paint()
          ..color = renk.withValues(alpha: opaklik)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, kenar / 12),
      );
      return;
    }
    canvas.drawImageRect(
      g,
      Rect.fromLTWH(0, 0, g.width.toDouble(), g.height.toDouble()),
      Rect.fromCenter(center: merkez, width: kenar, height: kenar),
      Paint()
        ..filterQuality = FilterQuality.medium
        // Modulate: sprite'ın sıcak beyazı renge boyanır, alfa korunur.
        ..colorFilter = ColorFilter.mode(
          renk.withValues(alpha: opaklik),
          BlendMode.modulate,
        ),
    );
  }
}
