import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../daily_luck_config.dart';
import '../tr_strings.dart';

/// Kader kartı: kapalı ([arkaYuz]) başlar; dokununca 3D flip ile döner,
/// ardından ekrana yaklaşıp (büyüme) üzerine "düşer" (sıkışıp oturma)
/// ve [onYuz] (skor) açık kalır.
///
/// Tek controller iki fazı da sürer: [0, flip] aralığı dönüş,
/// (flip, son] aralığı yaklaşma + düşme ölçek koreografisi.
/// Açılış bitince [onAcilisTamam] çağrılır (kutu açılışlarını tetikler).
class FortuneRevealCard extends StatefulWidget {
  /// Açık yüz, kapalı yüz ve tamamlanma callback'i ile kart oluşturur.
  const FortuneRevealCard({
    required this.onYuz,
    required this.arkaYuz,
    this.onAcilisTamam,
    super.key,
  });

  /// Flip sonrası görünen içerik (skor).
  final Widget onYuz;

  /// Başlangıçta görünen işlemeli kapalı yüz.
  final Widget arkaYuz;

  /// Flip + iniş tamamlanınca çağrılır.
  final VoidCallback? onAcilisTamam;

  @override
  State<FortuneRevealCard> createState() => _FortuneRevealCardState();
}

class _FortuneRevealCardState extends State<FortuneRevealCard>
    with SingleTickerProviderStateMixin {
  /// Toplam süre: flip + iniş.
  static final Duration _toplamSure =
      DailyLuckConfig.kartFlipSuresi + DailyLuckConfig.kartInisSuresi;

  /// Flip fazının toplam süre içindeki bitiş oranı.
  static final double _flipSonu =
      DailyLuckConfig.kartFlipSuresi.inMilliseconds /
          _toplamSure.inMilliseconds;

  late final AnimationController _kontrol = AnimationController(
    vsync: this,
    duration: _toplamSure,
  );

  /// Dönüş açısını süren eğri (yalnızca flip fazında ilerler).
  late final Animation<double> _flip = CurvedAnimation(
    parent: _kontrol,
    curve: Interval(0, _flipSonu, curve: DailyLuckConfig.kartFlipEgrisi),
  );

  /// Ölçek koreografisi: flip boyunca 1.0 sabit → yaklaşma (büyüme) →
  /// düşme (hedefin altına sıkışma) → oturma. "Ekrana yaklaşıp düşme"
  /// hissinin tamamı bu dizidir.
  late final Animation<double> _olcek = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1),
        weight: _flipSonu,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1, end: DailyLuckConfig.kartYaklasmaOlcegi)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: (1 - _flipSonu) * 0.5,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: DailyLuckConfig.kartYaklasmaOlcegi,
          end: DailyLuckConfig.kartCarpmaOlcegi,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: (1 - _flipSonu) * 0.3,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: DailyLuckConfig.kartCarpmaOlcegi, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: (1 - _flipSonu) * 0.2,
      ),
    ],
  ).animate(_kontrol);

  @override
  void initState() {
    super.initState();
    _kontrol.addStatusListener((AnimationStatus durum) {
      if (durum == AnimationStatus.completed) {
        widget.onAcilisTamam?.call();
      }
    });
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  /// Kart yalnızca kapalıyken açılır; geri kapanma yoktur.
  void _ac() {
    if (!_kontrol.isAnimating && _kontrol.value == 0) {
      _kontrol.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _ac,
      // RepaintBoundary: açılış boyunca yalnızca kart boyanır.
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _kontrol,
          // Child pattern: yüzler ve ipucu builder DIŞINDA kuruludur;
          // builder her tick'te yalnızca Transform/Opacity üretir.
          builder: (BuildContext context, Widget? child) {
            final double aci = _flip.value * pi;
            final bool onYuzGorunur = aci > pi / 2;

            final Matrix4 donusum = Matrix4.identity()
              ..setEntry(3, 2, DailyLuckConfig.kartFlipPerspektifi)
              ..rotateY(aci)
              // Ölçek aynı matriste: yaklaşma/düşme flip merkezinden.
              ..scaleByDouble(_olcek.value, _olcek.value, _olcek.value, 1);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Transform(
                  transform: donusum,
                  alignment: Alignment.center,
                  child: onYuzGorunur
                      ? Transform(
                          transform: Matrix4.identity()..rotateY(pi),
                          alignment: Alignment.center,
                          child: widget.onYuz,
                        )
                      : widget.arkaYuz,
                ),
                const SizedBox(height: DailyLuckConfig.ipucuBoslugu),
                // İpucu dokunuşla hızla söner (3x hız, 0-1 kırpılır).
                Opacity(
                  opacity: (1 - _kontrol.value * 3).clamp(0.0, 1.0),
                  child: Text(
                    TrStrings.kartIpucu,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

