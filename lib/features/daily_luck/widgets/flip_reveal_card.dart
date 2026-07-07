import 'dart:math';

import 'package:flutter/material.dart';

import '../daily_luck_config.dart';

/// 3D flip ile açılan kart: kullanıcı dokunana kadar [arkaYuz]
/// ("Bugünün kaderini gör") görünür, dokununca Y ekseninde dönerek
/// [onYuz] (yorum kartı) açılır (plan Session 5, madde 2).
class FlipRevealCard extends StatefulWidget {
  /// Açık ([onYuz]) ve kapalı ([arkaYuz]) yüzlerle kart oluşturur.
  const FlipRevealCard({required this.onYuz, required this.arkaYuz, super.key});

  /// Flip tamamlandığında görünen içerik.
  final Widget onYuz;

  /// Başlangıçta görünen kapalı yüz.
  final Widget arkaYuz;

  @override
  State<FlipRevealCard> createState() => _FlipRevealCardState();
}

class _FlipRevealCardState extends State<FlipRevealCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol = AnimationController(
    vsync: this,
    duration: DailyLuckConfig.kartFlipSuresi,
  );

  late final Animation<double> _egri = CurvedAnimation(
    parent: _kontrol,
    curve: DailyLuckConfig.kartFlipEgrisi,
  );

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  /// Kart yalnızca kapalıyken ve animasyon yokken açılır; geri
  /// kapanma yoktur (günün yorumu açık kalır).
  void _ac() {
    if (!_kontrol.isAnimating && _kontrol.value == 0) {
      _kontrol.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _ac,
      // RepaintBoundary: flip sırasında yalnızca kart boyanır.
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _egri,
          // Child pattern: yüzler builder DIŞINDA (widget alanlarında)
          // kuruludur; builder her tick'te yalnızca Transform üretir,
          // yüz alt ağaçları yeniden inşa edilmez (Session 5, madde 5).
          builder: (BuildContext context, Widget? child) {
            // easeInOutBack eğrisi 0-1 dışına hafif taşar; açı da
            // orantılı taşarak "fizikli" his verir.
            final double aci = _egri.value * pi;
            final bool onYuzGorunur = aci > pi / 2;

            // Perspektifli Y ekseni dönüşü. Ön yüz pi kadar önceden
            // ters çevrilir ki dönüş bittiğinde düz okunsun.
            final Matrix4 donusum = Matrix4.identity()
              ..setEntry(3, 2, DailyLuckConfig.kartFlipPerspektifi)
              ..rotateY(aci);

            return Transform(
              transform: donusum,
              alignment: Alignment.center,
              child: onYuzGorunur
                  ? Transform(
                      transform: Matrix4.identity()..rotateY(pi),
                      alignment: Alignment.center,
                      child: widget.onYuz,
                    )
                  : widget.arkaYuz,
            );
          },
        ),
      ),
    );
  }
}
