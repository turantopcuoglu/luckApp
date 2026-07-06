import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/luck_engine/luck_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../daily_luck_config.dart';
import '../tr_strings.dart';

/// Dairesel skor göstergesi: arka halka + skor oranında dolan
/// altın gradient halka, ortasında skor sayısı ve etiketi.
///
/// Statik çizimdir; count-up ve dolum animasyonu Session 5'te bu
/// widget sarmalanarak eklenecek.
class ScoreRing extends StatelessWidget {
  /// 0-100 arası [skor] ile gösterge oluşturur.
  const ScoreRing({required this.skor, super.key});

  /// Gösterilecek genel skor.
  final int skor;

  @override
  Widget build(BuildContext context) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    return SizedBox(
      width: DailyLuckConfig.halkaCapi,
      height: DailyLuckConfig.halkaCapi,
      child: CustomPaint(
        painter: _ScoreRingPainter(oran: skor / EngineConfig.skorMaks),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$skor',
                style: yaziTemasi.displayLarge?.copyWith(
                  color: AppColors.gold,
                ),
              ),
              Text(
                TrStrings.genelSkorEtiketi,
                style: yaziTemasi.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Halkayı çizen painter: tam daire arka halka ve üstten (saat 12)
/// başlayıp skor oranı kadar süpüren gradient yay.
class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({required this.oran});

  /// Halkanın dolu kısmının oranı (0.0 - 1.0).
  final double oran;

  /// Yayın başlangıç açısı: saat 12 yönü.
  static const double _baslangicAcisi = -pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset merkez = size.center(Offset.zero);
    // Çizgi kalınlığının yarısı içeri alınır ki halka kutuya sığsın.
    final double yaricap =
        (size.shortestSide - DailyLuckConfig.halkaKalinligi) / 2;
    final Rect cerceve = Rect.fromCircle(center: merkez, radius: yaricap);

    final Paint arkaHalka = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DailyLuckConfig.halkaKalinligi
      ..color = AppColors.surface;
    canvas.drawCircle(merkez, yaricap, arkaHalka);

    if (oran <= 0) {
      return; // dolum yok, yalnızca arka halka
    }

    final Paint dolum = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DailyLuckConfig.halkaKalinligi
      ..strokeCap = StrokeCap.round
      // Gradient yayın başladığı açıdan itibaren döndürülür ki renk
      // geçişi her zaman dolumun başından sonuna doğru aksın.
      ..shader = SweepGradient(
        colors: const <Color>[AppColors.gold, AppColors.goldAcik],
        endAngle: 2 * pi * oran,
        transform: const GradientRotation(_baslangicAcisi),
      ).createShader(cerceve);

    canvas.drawArc(cerceve, _baslangicAcisi, 2 * pi * oran, false, dolum);
  }

  @override
  bool shouldRepaint(_ScoreRingPainter onceki) => onceki.oran != oran;
}
