import 'package:flutter/material.dart';

import '../../../core/localization/app_dil.dart';
import '../daily_luck_config.dart';
import 'score_ring.dart';

/// [ScoreRing]'i sarmalayan count-up animasyonu: açılışta skor 0'dan
/// hedefe 1.2 sn'de easeOutCubic ile sayar (plan Session 5, madde 1).
///
/// Sayı ve halka dolumu AYNI animasyon değerinden türediği için
/// kendiliğinden senkrondur. Statik [ScoreRing] hiç değiştirilmedi.
class AnimatedScoreRing extends StatefulWidget {
  /// Hedef [skor] ile animasyonlu gösterge oluşturur.
  const AnimatedScoreRing({
    required this.skor,
    required this.dil,
    this.boyut = DailyLuckConfig.halkaCapi,
    this.kalinlik = DailyLuckConfig.halkaKalinligi,
    super.key,
  });

  /// Count-up'ın ulaşacağı genel skor.
  final int skor;

  /// Aktif uygulama dili ([ScoreRing.dil]).
  final AppDil dil;

  /// Halkanın dış çapı ([ScoreRing.boyut]).
  final double boyut;

  /// Halkanın çizgi kalınlığı ([ScoreRing.kalinlik]).
  final double kalinlik;

  @override
  State<AnimatedScoreRing> createState() => _AnimatedScoreRingState();
}

class _AnimatedScoreRingState extends State<AnimatedScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol = AnimationController(
    vsync: this,
    duration: DailyLuckConfig.skorSayacSuresi,
  );

  late final Animation<double> _egri = CurvedAnimation(
    parent: _kontrol,
    curve: DailyLuckConfig.skorSayacEgrisi,
  );

  @override
  void initState() {
    super.initState();
    _kontrol.forward();
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary: her tick'te yalnızca halka yeniden boyanır,
    // ekranın kalanı (kartlar, metinler) etkilenmez (Session 5, madde 5).
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _egri,
        // Not: klasik "child pattern" burada uygulanamaz çünkü her
        // tick'te değişen şey ScoreRing'in kendisidir (sayı + yay).
        // ScoreRing alt ağacı zaten küçüktür ve RepaintBoundary ile
        // izole edilmiştir; jank ölçülürse painter'a inilebilir.
        builder: (BuildContext context, Widget? child) => ScoreRing(
          skor: (_egri.value * widget.skor).round(),
          dil: widget.dil,
          boyut: widget.boyut,
          kalinlik: widget.kalinlik,
        ),
      ),
    );
  }
}
