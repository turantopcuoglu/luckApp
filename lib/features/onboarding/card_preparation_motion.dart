import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/cosmic_config.dart';

/// Hazırlık geçişi: cam hacim içinde dolan ışık ve eşzamanlı ilerleme izi.
/// Gösterge ritüel animasyonudur; bilimsel işlem yüzdesi veya skor değildir.
class CardPreparationMotion extends StatelessWidget {
  /// Kayıt tamamlanmadan tamamen dolmuş başarı durumu çizilmez.
  const CardPreparationMotion({
    required this.animation,
    required this.reducedMotion,
    super.key,
  });

  /// Ekranın tek hazırlık controller'ı.
  final Animation<double> animation;

  /// Sistem hareket azaltması; canlı dalga yerine sabit hacim.
  final bool reducedMotion;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: SizedBox(
        width: CosmicConfig.orbSize,
        height: CosmicConfig.orbSize + 48,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (Rect bounds) => const RadialGradient(
                  radius: .5,
                  colors: <Color>[
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: <double>[0, .89, 1],
                ).createShader(bounds),
                child: Image.asset(
                  CosmicConfig.glassOrb,
                  cacheWidth: CosmicConfig.sceneDecodeWidth(
                    CosmicConfig.orbSize,
                    MediaQuery.devicePixelRatioOf(context),
                  ),
                  excludeFromSemantics: true,
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _FillPainter(animation, reducedMotion),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FillPainter extends CustomPainter {
  _FillPainter(this.animation, this.reduced) : super(repaint: animation);
  final Animation<double> animation;
  final bool reduced;
  @override
  void paint(Canvas canvas, Size size) {
    final double t = reduced ? .55 : animation.value;
    final Offset center = Offset(size.width / 2, size.width / 2);
    final double r = size.width * .40;
    final Rect orb = Rect.fromCircle(center: center, radius: r);
    final Paint p = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          CosmicConfig.cyan.withValues(alpha: .23),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r * 1.45));
    canvas.drawCircle(center, r * 1.45, p);
    p
      ..shader = null
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = CosmicConfig.gold.withValues(alpha: .6);
    canvas.drawCircle(center, r * 1.13, p);
    final double angle = t * math.pi * 1.5 - math.pi / 2;
    final Offset star =
        center + Offset(math.cos(angle), math.sin(angle)) * r * 1.13;
    p
      ..style = PaintingStyle.fill
      ..color = CosmicConfig.goldLight;
    canvas.drawCircle(star, 3, p);
    p.shader = null;
    canvas.save();
    canvas.clipPath(Path()..addOval(orb));
    final double level = orb.bottom - (.12 + t * .76) * orb.height;
    final Path wave = Path()
      ..moveTo(orb.left, orb.bottom)
      ..lineTo(orb.left, level);
    for (int i = 0; i <= 64; i++) {
      final double x = orb.left + orb.width * i / 64;
      final double y =
          level + math.sin(i / 64 * math.pi * 3 + t * math.pi * 4) * r * .045;
      wave.lineTo(x, y);
    }
    wave
      ..lineTo(orb.right, orb.bottom)
      ..close();
    p.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        CosmicConfig.cyan.withValues(alpha: .24),
        const Color(0x33167AAA),
        CosmicConfig.gold.withValues(alpha: .12),
      ],
    ).createShader(orb);
    canvas.drawPath(wave, p);
    final Path surface = Path();
    for (int i = 0; i <= 64; i++) {
      final double x = orb.left + orb.width * i / 64;
      final double y =
          level + math.sin(i / 64 * math.pi * 3 + t * math.pi * 4) * r * .045;
      if (i == 0) {
        surface.moveTo(x, y);
      } else {
        surface.lineTo(x, y);
      }
    }
    p
      ..shader = null
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = CosmicConfig.cyan
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawPath(surface, p);
    p
      ..strokeWidth = 1.5
      ..color = CosmicConfig.goldLight
      ..maskFilter = null;
    canvas.drawPath(surface, p);
    p.style = PaintingStyle.fill;
    // Camın içinde kırılan ince ışık iplikleri: ayrı bir büyük şekil değil.
    for (int band = 0; band < 5; band++) {
      final Path caustic = Path();
      for (int i = 0; i <= 80; i++) {
        final double x = orb.left + orb.width * i / 80;
        final double y =
            level +
            math.sin(i / 80 * math.pi * 2 + t * math.pi * 4 + band * .14) *
                r *
                .08 +
            math.sin(i / 80 * math.pi) * band * 1.5;
        if (i == 0) {
          caustic.moveTo(x, y);
        } else {
          caustic.lineTo(x, y);
        }
      }
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = band == 0 ? 1.3 : .65
        ..color = (band.isEven ? CosmicConfig.cyan : Colors.white).withValues(
          alpha: band == 0 ? .9 : .35,
        );
      canvas.drawPath(caustic, p);
    }
    p.style = PaintingStyle.fill;
    for (int i = 0; i < 72; i++) {
      final double x = orb.left + (i * .6180339 % 1) * orb.width;
      final double y =
          orb.bottom - ((i * .754877666 + t * .65) % 1) * (orb.bottom - level);
      p.color = (i.isEven ? CosmicConfig.goldLight : CosmicConfig.cyan)
          .withValues(alpha: .28 + (i % 4) * .16);
      canvas.drawCircle(Offset(x, y), i % 5 == 0 ? 1.5 : .65, p);
    }
    canvas.restore();
    p
      ..style = PaintingStyle.stroke
      ..color = CosmicConfig.cyan.withValues(alpha: .4)
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center, r, p);
    p
      ..maskFilter = null
      ..color = const Color(0xFFE5F5FF)
      ..strokeWidth = 1.3;
    canvas.drawCircle(center, r, p);
    p
      ..color = CosmicConfig.gold.withValues(alpha: .65)
      ..strokeWidth = 1;
    canvas.drawArc(orb.inflate(2), -.3, math.pi * .9, false, p);
    p.color = CosmicConfig.cyan.withValues(alpha: .38);
    canvas.drawArc(orb.deflate(8), .15, math.pi * .82, false, p);
    p
      ..color = Colors.white.withValues(alpha: .85)
      ..strokeWidth = 2.6;
    canvas.drawArc(orb.deflate(4), math.pi * 1.08, math.pi * .45, false, p);
    p
      ..color = Colors.white.withValues(alpha: .35)
      ..strokeWidth = .8;
    canvas.drawArc(orb.deflate(10), math.pi * 1.1, math.pi * .35, false, p);
    // İki sabit kutup ve zeminde ince yansımalar, küreyi sahneye bağlar.
    for (final double direction in <double>[-1, 1]) {
      final Offset pole = center + Offset(0, direction * r * 1.13);
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = CosmicConfig.goldLight;
      canvas.drawCircle(pole, 5, p);
      canvas.drawLine(
        pole - const Offset(0, 10),
        pole + const Offset(0, 10),
        p,
      );
    }
    for (int i = 0; i < 4; i++) {
      final Rect reflection = Rect.fromCenter(
        center: Offset(center.dx, size.width - 7 + i * 4),
        width: r * (.65 + i * .18),
        height: 4 + i * 1.5,
      );
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7
        ..color = CosmicConfig.goldLight.withValues(alpha: .30 - i * .05);
      canvas.drawArc(reflection, t * .3 + i, math.pi * 1.3, false, p);
    }
    final Rect track = Rect.fromLTWH(
      size.width * .10,
      size.width + 20,
      size.width * .8,
      8,
    );
    p
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF18374B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(track, const Radius.circular(4)),
      p,
    );
    p.shader = const LinearGradient(
      colors: <Color>[CosmicConfig.cyan, CosmicConfig.goldLight],
    ).createShader(track);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          track.left,
          track.top,
          track.width * (.12 + t * .76),
          track.height,
        ),
        const Radius.circular(4),
      ),
      p,
    );
    final Offset head = Offset(
      track.left + track.width * (.12 + t * .76),
      track.center.dy,
    );
    p
      ..shader = null
      ..color = CosmicConfig.cyan.withValues(alpha: .7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(head, 6, p);
    p
      ..color = CosmicConfig.goldLight
      ..maskFilter = null;
    canvas.drawCircle(head, 4, p);
  }

  @override
  bool shouldRepaint(_FillPainter old) =>
      old.animation != animation || old.reduced != reduced;
}
