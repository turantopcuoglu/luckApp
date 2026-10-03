import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_images.dart';
import '../onboarding_config.dart';

/// "Kartın hazırlanıyor" ekranının ışık küresi: cam kürenin içi
/// [ilerleme] arttıkça yıldızlı mavi ışıkla dolar; sıvının yüzeyi
/// dalgalanır ve ince bir ışık çizgisiyle parlar.
///
/// Katmanlar (alttan üste, hepsi aynı merkezde): altın yörünge çerçevesi,
/// dalga biçiminde kırpılmış sıvı, yüzey ışığı, boş cam. Dalga döngüsü
/// lokal animasyon state'idir (kural 5); dolum [ilerleme]'den gelir.
class IsikKuresi extends StatefulWidget {
  /// [ilerleme] (0-1) ile dolan küre.
  const IsikKuresi({required this.ilerleme, super.key});

  /// Dolum oranı (0 = boş, 1 = dolu).
  final Animation<double> ilerleme;

  @override
  State<IsikKuresi> createState() => _IsikKuresiState();
}

class _IsikKuresiState extends State<IsikKuresi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dalga = AnimationController(
    vsync: this,
    duration: OnboardingConfig.dalgaDongusu,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _dalga.stop();
    } else if (!_dalga.isAnimating) {
      _dalga.repeat();
    }
  }

  @override
  void dispose() {
    _dalga.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double cap = OnboardingConfig.kureCapi;
    const double cerceve = cap * OnboardingConfig.kureCerceveOrani;
    const double sivi = cap * OnboardingConfig.kureSiviOrani;
    final Widget siviGorseli = Image.asset(
      AppImages.kureSivi,
      width: sivi,
      height: sivi,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: cerceve,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.asset(
              AppImages.kureCerceve,
              width: cerceve,
              height: cerceve,
              gaplessPlayback: true,
              excludeFromSemantics: true,
            ),
            AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[
                _dalga,
                widget.ilerleme,
              ]),
              child: siviGorseli,
              builder: (BuildContext context, Widget? cocuk) {
                final double seviye =
                    OnboardingConfig.siviTabanOrani +
                    (1 - OnboardingConfig.siviTabanOrani) *
                        widget.ilerleme.value;
                final double faz = _dalga.value * 2 * pi;
                return SizedBox.square(
                  dimension: sivi,
                  child: Stack(
                    children: <Widget>[
                      ClipPath(
                        clipper: _DalgaKirpici(seviye: seviye, faz: faz),
                        child: cocuk,
                      ),
                      CustomPaint(
                        size: const Size.square(sivi),
                        painter: _YuzeyPainter(seviye: seviye, faz: faz),
                      ),
                    ],
                  ),
                );
              },
            ),
            Image.asset(
              AppImages.kureCam,
              width: cap,
              height: cap,
              gaplessPlayback: true,
              excludeFromSemantics: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// [seviye] (0-1) yüksekliğindeki dalgalı yüzeyin [y] koordinatı.
double _yuzeyY(Size boyut, double seviye, double faz, double x) {
  // Dolum tamamlanınca dalga söner: sıvı camı tam doldurur.
  final double genlik =
      boyut.height * OnboardingConfig.dalgaGenligi * (1 - seviye * seviye);
  return boyut.height * (1 - seviye) +
      sin(x / boyut.width * 2 * pi + faz) * genlik;
}

/// Sıvıyı daire içinde, dalgalı yüzeyin altında kalan bölgeyle kırpar.
class _DalgaKirpici extends CustomClipper<Path> {
  _DalgaKirpici({required this.seviye, required this.faz});

  final double seviye;
  final double faz;

  @override
  Path getClip(Size size) {
    final Path dalga = Path()..moveTo(0, size.height);
    const int adim = 24;
    for (int i = 0; i <= adim; i++) {
      final double x = size.width * i / adim;
      dalga.lineTo(x, _yuzeyY(size, seviye, faz, x));
    }
    dalga
      ..lineTo(size.width, size.height)
      ..close();
    return Path.combine(
      PathOperation.intersect,
      Path()..addOval(Offset.zero & size),
      dalga,
    );
  }

  @override
  bool shouldReclip(_DalgaKirpici eski) =>
      eski.seviye != seviye || eski.faz != faz;
}

/// Sıvı yüzeyindeki ince ışık çizgisi (altın-turkuaz hale + beyaz çekirdek).
class _YuzeyPainter extends CustomPainter {
  _YuzeyPainter({required this.seviye, required this.faz});

  final double seviye;
  final double faz;

  @override
  void paint(Canvas canvas, Size size) {
    if (seviye >= 1) {
      return;
    }
    final Path cizgi = Path();
    const int adim = 24;
    for (int i = 0; i <= adim; i++) {
      final double x = size.width * i / adim;
      final double y = _yuzeyY(size, seviye, faz, x);
      if (i == 0) {
        cizgi.moveTo(x, y);
      } else {
        cizgi.lineTo(x, y);
      }
    }
    canvas
      ..save()
      ..clipPath(Path()..addOval(Offset.zero & size))
      ..drawPath(
        cizgi,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth =
              OnboardingConfig.yuzeyCizgiKalinligi *
              OnboardingConfig.yuzeyHaleCarpani
          ..color = AppColors.sahneYuksek.withValues(
            alpha: OnboardingConfig.yuzeyHaleOpakligi,
          )
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            OnboardingConfig.yuzeyHaleBulanikligi,
          ),
      )
      ..drawPath(
        cizgi,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = OnboardingConfig.yuzeyCizgiKalinligi
          ..color = AppColors.isikCekirdegi,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_YuzeyPainter eski) =>
      eski.seviye != seviye || eski.faz != faz;
}
