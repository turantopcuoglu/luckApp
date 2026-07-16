import 'dart:math';

import 'package:flutter/material.dart';

import '../daily_luck_config.dart';

/// Kategori kutusunu sırası geldiğinde mini 3D flip ile açar:
/// [kapali] yüz (yalnız ikon) → [acik] yüz (etiket + skor).
///
/// Tüm kutular TEK üst controller'ı ([animasyon]) dinler; her kutu
/// kendi zaman dilimini [Interval] ile keser (öğe başına controller
/// yok — Session 5 stagger yaklaşımının flip'li devamı).
class KutuAcilisi extends StatelessWidget {
  /// [indeks]. kutu için açılış sarmalayıcısı.
  const KutuAcilisi({
    required this.animasyon,
    required this.kontrolSuresi,
    required this.indeks,
    required this.kapali,
    required this.acik,
    super.key,
  });

  /// Üst controller (0→1).
  final Animation<double> animasyon;

  /// Üst controller'ın toplam süresi (dilim oranları bundan türetilir).
  final Duration kontrolSuresi;

  /// Kutunun listedeki sırası (0 tabanlı).
  final int indeks;

  /// Kapalı yüz (yalnızca büyük ikon).
  final Widget kapali;

  /// Açık yüz (etiket + skor + bar).
  final Widget acik;

  @override
  Widget build(BuildContext context) {
    // Kutunun zaman dilimi: kendi gecikmesinden başlayıp açılış süresi
    // kadar sürer; Interval bu dilimi 0-1'e ölçekler.
    final double toplamMs = kontrolSuresi.inMilliseconds.toDouble();
    final double baslangicMs = (DailyLuckConfig.kutuGecikmesi * indeks)
        .inMilliseconds
        .toDouble();
    final double bitisMs =
        baslangicMs + DailyLuckConfig.kutuAcilisSuresi.inMilliseconds;

    final CurvedAnimation dilim = CurvedAnimation(
      parent: animasyon,
      curve: Interval(
        baslangicMs / toplamMs,
        bitisMs / toplamMs,
        curve: Curves.easeInOut,
      ),
    );

    // RepaintBoundary: her kutu komşularından bağımsız boyanır.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: dilim,
        // Child pattern: yüzler builder dışında hazır; builder yalnız
        // Transform üretir.
        builder: (BuildContext context, Widget? child) {
          final double aci = dilim.value * pi;
          final bool acikGorunur = aci > pi / 2;

          final Matrix4 donusum = Matrix4.identity()
            ..setEntry(3, 2, DailyLuckConfig.kartFlipPerspektifi)
            ..rotateY(aci);

          return Transform(
            transform: donusum,
            alignment: Alignment.center,
            child: acikGorunur
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: acik,
                  )
                : kapali,
          );
        },
      ),
    );
  }
}
