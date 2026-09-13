import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/cosmic_config.dart';
import '../../../shared/widgets/cosmic_scene.dart';
import '../reveal_config.dart';

/// Referansın dört aşaması: mühür, ışık, iki menteşeli kanat, açık sahne.
/// Skor almaz; yerleşmiş aynı geometri sonuç metninin arkasında da kullanılır.
class CardRevealMotion extends StatelessWidget {
  /// Tek saat ve statik bitmap çocukları; ışıklar ayrı boyanır.
  const CardRevealMotion({
    required this.animation,
    required this.reducedMotion,
    this.tone = CosmicTone.sealed,
    this.showScene = true,
    super.key,
  });

  /// 0–1, ilk 1300 ms. Sonuç metni sonraki 700 ms'de yerleşir.
  final Animation<double> animation;

  /// Azaltılmış harekette kapalı statik yüz; sonuç sahnesi ayrıca sabittir.
  final bool reducedMotion;

  /// Açılmış sonuçta görsel renk ailesi; açılış nötr/sealed kalır.
  final CosmicTone tone;

  /// Ana ekranda sahne başlıkla ortak çizilir; bağımsız kullanımda yerel portal.
  final bool showScene;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double cardWidth = math.min(
            CosmicConfig.cardWidth,
            width * RevealConfig.stageCardRatio,
          );
          final double cardHeight = cardWidth * RevealConfig.cardAspect;
          final double top = (CosmicConfig.heroHeight - cardHeight) / 2;
          if (reducedMotion) {
            return SizedBox(
              height: CosmicConfig.heroHeight,
              child: Center(child: CosmicCardFace(width: cardWidth)),
            );
          }
          return SizedBox(
            height: CosmicConfig.heroHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                if (showScene)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: animation,
                      child: CosmicPortal(tone: tone),
                      builder: (BuildContext context, Widget? child) => Opacity(
                        opacity: RevealFrame.at(animation.value).sceneOpacity,
                        child: child,
                      ),
                    ),
                  ),
                for (final bool left in <bool>[true, false])
                  Positioned(
                    top: top,
                    left: width / 2 + (left ? -cardWidth / 2 : 0),
                    width: cardWidth / 2,
                    height: cardHeight,
                    child: AnimatedBuilder(
                      animation: animation,
                      child: RepaintBoundary(
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: left
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            minWidth: cardWidth,
                            maxWidth: cardWidth,
                            child: CosmicCardFace(width: cardWidth),
                          ),
                        ),
                      ),
                      builder: (BuildContext context, Widget? child) {
                        final RevealFrame frame = RevealFrame.at(
                          animation.value,
                        );
                        final double direction = left ? -1 : 1;
                        return Transform.translate(
                          offset: Offset(
                            direction * frame.unfold * RevealConfig.travel,
                            -frame.press * AppSpacing.xs,
                          ),
                          child: Transform(
                            alignment: left
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, RevealConfig.perspective)
                              ..rotateY(
                                direction *
                                    (frame.unfold * RevealConfig.hingeAngle +
                                        frame.press * RevealConfig.tilt),
                              ),
                            // Son ışıkta hareketli yüzler, aynı yöndeki ayrıntılı
                            // açık kapı çizimine birleşir. Koyu yüzler üstte kalmaz.
                            child: Opacity(
                              opacity: frame.panelOpacity,
                              child: child,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _GateLight(animation, cardWidth),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

/// Kare zamanının saf, test edilebilir görsel karşılığı; motor veya veri taşımaz.
class RevealFrame {
  const RevealFrame._(this.press, this.seam, this.unfold);

  /// İlk mühür darbesi; başladığı noktaya sıçramadan döner.
  final double press;

  /// 250–650 ms ışık ilerlemesi.
  final double seam;

  /// 650–1300 ms fiziksel kanat açılımı.
  final double unfold;

  /// Son karede fiziksel koyu dokular sahneyi kapatmaz.
  double get panelOpacity =>
      1 -
      Curves.easeInOut.transform(
        _part(unfold, RevealConfig.panelBlendStart, 1),
      );

  /// Işık patlaması sırasında çizilmiş kapıya kesintisiz geçiş.
  double get sceneOpacity => Curves.easeOut.transform(
    _part(unfold, RevealConfig.panelBlendStart / 2, 1),
  );

  /// 0 ve 1 dahil kapalı/açık uçlar süreklidir.
  factory RevealFrame.at(double value) {
    final double t = value.clamp(0, 1);
    return RevealFrame._(
      math.sin(math.pi * _part(t, 0, RevealConfig.sealEnd)),
      _part(t, RevealConfig.seamStart, RevealConfig.seamEnd),
      Curves.easeInOutCubic.transform(_part(t, RevealConfig.unfoldStart, 1)),
    );
  }
}

double _part(double t, double a, double b) => ((t - a) / (b - a)).clamp(0, 1);

class _GateLight extends CustomPainter {
  _GateLight(this.animation, this.cardWidth) : super(repaint: animation);
  final Animation<double> animation;
  final double cardWidth;
  @override
  void paint(Canvas canvas, Size size) {
    final double t = animation.value;
    final RevealFrame f = RevealFrame.at(t);
    final Offset center = size.center(Offset.zero);
    final double cardHeight = cardWidth * RevealConfig.cardAspect;
    final Paint p = Paint()..style = PaintingStyle.stroke;
    final double seal = (1 - f.unfold) * (.12 + f.press * .8);
    p
      ..color = CosmicConfig.goldLight.withValues(alpha: seal)
      ..strokeWidth = 1.2;
    canvas.drawCircle(
      center,
      RevealConfig.sealRadius + f.press * RevealConfig.sealPulse,
      p,
    );
    if (t > RevealConfig.seamStart && f.unfold < 1) {
      final double alpha = (1 - f.unfold) * Curves.easeOut.transform(f.seam);
      final Offset a = center + Offset(0, cardHeight / 2 - cardHeight * f.seam);
      final Offset b = center + Offset(0, cardHeight / 2);
      p
        ..color = CosmicConfig.cyan.withValues(alpha: alpha * .65)
        ..strokeWidth = 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawLine(a, b, p);
      p
        ..color = CosmicConfig.goldLight.withValues(alpha: alpha)
        ..strokeWidth = 1.7
        ..maskFilter = null;
      canvas.drawLine(a, b, p);
      p.style = PaintingStyle.fill;
      canvas.drawCircle(a, 3, p);
    }
    if (f.unfold > 0) {
      final double burst = math.sin(math.pi * f.unfold);
      final Rect orbit = Rect.fromCenter(
        center: center,
        width: size.width * .91,
        height: size.height * .36,
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-.18 + f.unfold * .30);
      canvas.translate(-center.dx, -center.dy);
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = CosmicConfig.cyan.withValues(alpha: burst * .38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawArc(orbit, math.pi * .10, math.pi * 1.8, false, p);
      p
        ..strokeWidth = 1.2
        ..maskFilter = null
        ..color = CosmicConfig.goldLight.withValues(alpha: burst * .7);
      canvas.drawArc(orbit, math.pi * .10, math.pi * 1.8, false, p);
      canvas.restore();
      // Tek odak çevresinde küçük ışık tozu: ekranın tamamına taşmaz.
      for (int i = 0; i < RevealConfig.particleCount; i++) {
        final double a = i * 2.39996;
        final double r = cardWidth * (.40 + f.unfold * .23);
        final Offset pos =
            center + Offset(math.cos(a) * r, math.sin(a) * r * 1.35);
        p
          ..style = PaintingStyle.fill
          ..color = (i.isEven ? CosmicConfig.goldLight : CosmicConfig.cyan)
              .withValues(alpha: burst * .75);
        canvas.drawCircle(pos, i % 3 == 0 ? 1.6 : .7, p);
      }
    }
  }

  @override
  bool shouldRepaint(_GateLight old) =>
      old.animation != animation || old.cardWidth != cardWidth;
}
