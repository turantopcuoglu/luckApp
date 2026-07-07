import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/luck_engine/luck_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../daily_luck_config.dart';
import '../tr_strings.dart';

/// Dairesel skor göstergesi: arka halka + skor oranında dolan
/// altın gradient halka, ortasında skor sayısı ve etiketi.
///
/// [boyut] ve [kalinlik] ile ölçeklenebilir (kart içinde küçük,
/// tek başına büyük kullanım için).
class ScoreRing extends StatelessWidget {
  /// 0-100 arası [skor] ile gösterge oluşturur.
  const ScoreRing({
    required this.skor,
    this.boyut = DailyLuckConfig.halkaCapi,
    this.kalinlik = DailyLuckConfig.halkaKalinligi,
    super.key,
  });

  /// Gösterilecek genel skor.
  final int skor;

  /// Halkanın dış çapı.
  final double boyut;

  /// Halkanın çizgi kalınlığı.
  final double kalinlik;

  @override
  Widget build(BuildContext context) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    return SizedBox(
      width: boyut,
      height: boyut,
      child: CustomPaint(
        painter: ScoreRingPainter(
          oran: skor / EngineConfig.skorMaks,
          kalinlik: kalinlik,
        ),
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
///
/// Public'tir: story kartı (features/share) aynı halkayı farklı
/// boyutta yeniden çizer.
class ScoreRingPainter extends CustomPainter {
  /// [oran] (0-1) ve çizgi [kalinlik]'ı ile painter oluşturur.
  const ScoreRingPainter({required this.oran, required this.kalinlik});

  /// Halkanın dolu kısmının oranı (0.0 - 1.0).
  final double oran;

  /// Çizgi kalınlığı.
  final double kalinlik;

  /// Yayın başlangıç açısı: saat 12 yönü.
  static const double _baslangicAcisi = -pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset merkez = size.center(Offset.zero);
    // Çizgi kalınlığının yarısı içeri alınır ki halka kutuya sığsın.
    final double yaricap = (size.shortestSide - kalinlik) / 2;
    final Rect cerceve = Rect.fromCircle(center: merkez, radius: yaricap);

    final Paint arkaHalka = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = kalinlik
      ..color = AppColors.surface;
    canvas.drawCircle(merkez, yaricap, arkaHalka);

    if (oran <= 0) {
      return; // dolum yok, yalnızca arka halka
    }

    final Paint dolum = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = kalinlik
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
  bool shouldRepaint(ScoreRingPainter onceki) =>
      onceki.oran != oran || onceki.kalinlik != kalinlik;
}
