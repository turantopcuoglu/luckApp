import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/luck_engine/engine_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../daily_luck_config.dart';

/// Kart açılınca kanatların arasından görünen günün puanı: büyük altın
/// rakam, "/100", etiket ve rakamın etrafında çizilerek beliren ışık
/// kemeri.
///
/// Zemin şeffaftır; arkadaki skor sahnesi görünür. Count-up ve kemer
/// çizimi AYNI [ilerleme] değerinden türer, böylece kendiliğinden
/// senkrondur. Kart boyutundadır ([DailyLuckConfig.kartGenisligi] ×
/// [DailyLuckConfig.kartYuksekligi]).
class GununPuani extends StatelessWidget {
  /// Hedef [skor], [ilerleme] (0→1) ve sahne [vurgu] rengiyle kurar.
  const GununPuani({
    required this.skor,
    required this.ilerleme,
    required this.vurgu,
    super.key,
  });

  /// Count-up'ın ulaşacağı genel skor.
  final int skor;

  /// Count-up ve kemer çizimi ilerlemesi (0-1).
  final Animation<double> ilerleme;

  /// Kemer ve hale rengi (skor sahnesine göre).
  final Color vurgu;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    return Semantics(
      label: l.gunlukPuanSemantik(skor, EngineConfig.skorMaks),
      excludeSemantics: true,
      child: SizedBox(
        width: DailyLuckConfig.kartGenisligi,
        height: DailyLuckConfig.kartYuksekligi,
        // RepaintBoundary: count-up her karede yalnız bu katmanı boyar.
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: ilerleme,
            builder: (BuildContext context, Widget? child) {
              final double v = ilerleme.value;
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CustomPaint(
                    painter: _KemerPainter(ilerleme: v, renk: vurgu),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Altın gradyanlı rakam: ShaderMask beyaz metni boyar.
                      ShaderMask(
                        shaderCallback: (Rect r) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[AppColors.goldAcik, AppColors.gold],
                        ).createShader(r),
                        child: Text(
                          '${(v * skor).round()}',
                          style: yazi.displayLarge?.copyWith(
                            fontSize: DailyLuckConfig.puanYaziBoyutu,
                            height: 1,
                            color: AppColors.textPrimary,
                            fontFeatures: const <FontFeature>[
                              // Rakamlar eşit genişlikte: sayarken titremez.
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        l.gunlukPuanPaydasi(EngineConfig.skorMaks),
                        style: yazi.titleMedium?.copyWith(
                          color: AppColors.goldAcik,
                        ),
                      ),
                      Text(
                        l.gunlukSansPuani,
                        style: yazi.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Rakamın arkasındaki yumuşak hale ve tepeden iki yana inen ışık kemeri.
class _KemerPainter extends CustomPainter {
  _KemerPainter({required this.ilerleme, required this.renk});

  /// Çizim ilerlemesi (0-1).
  final double ilerleme;

  /// Kemer ve hale rengi.
  final Color renk;

  @override
  void paint(Canvas canvas, Size size) {
    if (ilerleme <= 0) {
      return;
    }
    final Offset merkez = size.center(Offset.zero);

    // Hale: rakamın arkasında sahne renginde yumuşak ışık.
    final double haleR = size.width / 2;
    canvas.drawCircle(
      merkez,
      haleR,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            renk.withValues(alpha: DailyLuckConfig.puanHaleOpakligi * ilerleme),
            renk.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: merkez, radius: haleR)),
    );

    // Kemer: üstte yarım daire, iki yanda dikey ayaklar. Tepeden başlayan
    // iki ayrı yol olarak kurulur ki iki yana simetrik inerek çizilsin.
    final double kenar = size.width * DailyLuckConfig.kemerKenarOrani;
    final double sol = kenar;
    final double sag = size.width - kenar;
    final double r = (sag - sol) / 2;
    final double kemerMerkezY = kenar + r;
    final double alt = size.height - kenar;
    final Rect daire = Rect.fromCircle(
      center: Offset(size.width / 2, kemerMerkezY),
      radius: r,
    );
    final Path solYol = Path()
      ..addArc(daire, -pi / 2, -pi / 2)
      ..lineTo(sol, alt);
    final Path sagYol = Path()
      ..addArc(daire, -pi / 2, pi / 2)
      ..lineTo(sag, alt);

    final Paint hale = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          DailyLuckConfig.kemerKalinligi * DailyLuckConfig.kemerHaleCarpani
      ..color = renk
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        DailyLuckConfig.kemerBulanikligi,
      );
    final Paint cekirdek = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DailyLuckConfig.kemerKalinligi
      ..strokeCap = StrokeCap.round
      ..color = AppColors.goldAcik;

    for (final Path yol in <Path>[solYol, sagYol]) {
      final PathMetric olcu = yol.computeMetrics().first;
      final Path parca = olcu.extractPath(
        0,
        olcu.length * Curves.easeInOut.transform(ilerleme),
      );
      canvas
        ..drawPath(parca, hale)
        ..drawPath(parca, cekirdek);
    }
  }

  @override
  bool shouldRepaint(_KemerPainter eski) =>
      eski.ilerleme != ilerleme || eski.renk != renk;
}
