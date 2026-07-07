import 'package:flutter/material.dart';

import '../daily_luck_config.dart';

/// Tek bir liste öğesine, dizindeki sırasına göre gecikmeli
/// fade+slide girişi uygular (plan Session 5, madde 3).
///
/// Tüm öğeler TEK bir üst controller'ı ([animasyon]) dinler; her öğe
/// kendi zaman dilimini [Interval] eğrisiyle keser. Böylece n öğe için
/// n controller yerine 1 controller çalışır.
class StaggeredEntrance extends StatelessWidget {
  /// [indeks]. öğe için, [toplam] öğelik listede giriş sarmalayıcısı.
  const StaggeredEntrance({
    required this.animasyon,
    required this.indeks,
    required this.toplam,
    required this.child,
    super.key,
  });

  /// Üst controller (0→1, süresi [toplamSure] olmalı).
  final Animation<double> animasyon;

  /// Öğenin listedeki sırası (0 tabanlı).
  final int indeks;

  /// Listedeki toplam öğe sayısı.
  final int toplam;

  /// Girişi yapılan içerik.
  final Widget child;

  /// [toplam] öğelik bir listenin tüm girişinin toplam süresi:
  /// son öğenin gecikmesi + tek öğe giriş süresi.
  static Duration toplamSure(int toplam) =>
      DailyLuckConfig.kategoriGecikmesi * (toplam - 1) +
      DailyLuckConfig.kategoriGirisSuresi;

  @override
  Widget build(BuildContext context) {
    // Öğenin zaman dilimi: [gecikme, gecikme + girişSüresi] aralığının
    // toplam süre içindeki oranı. Interval bu dilimi 0-1'e ölçekler.
    final double toplamMs =
        toplamSure(toplam).inMilliseconds.toDouble();
    final double baslangicMs =
        (DailyLuckConfig.kategoriGecikmesi * indeks).inMilliseconds
            .toDouble();
    final double bitisMs = baslangicMs +
        DailyLuckConfig.kategoriGirisSuresi.inMilliseconds;

    final CurvedAnimation dilim = CurvedAnimation(
      parent: animasyon,
      curve: Interval(
        baslangicMs / toplamMs,
        bitisMs / toplamMs,
        curve: Curves.easeOut,
      ),
    );

    // FadeTransition/SlideTransition child'ı yeniden inşa etmez,
    // yalnızca boyar; RepaintBoundary öğeyi komşularından izole eder.
    return RepaintBoundary(
      child: FadeTransition(
        opacity: dilim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, DailyLuckConfig.kategoriSlideOrani),
            end: Offset.zero,
          ).animate(dilim),
          child: child,
        ),
      ),
    );
  }
}
