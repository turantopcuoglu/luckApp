import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../categories_config.dart';

/// Premium kilidi görseli: [kilitli] ise içeriği blur'layıp üzerine
/// altın kilit ikonu koyar; değilse içeriği olduğu gibi gösterir
/// (plan Session 9, madde 2).
///
/// Dokunma davranışı bu widget'ın DIŞINDA ele alınır; gate yalnızca
/// görsel katmandır.
class PremiumGate extends StatelessWidget {
  /// [kilitli] durumuna göre [child]'ı sarmalayan gate oluşturur.
  const PremiumGate({required this.kilitli, required this.child, super.key});

  /// İçerik kilitli mi gösterilsin?
  final bool kilitli;

  /// Sarmalanan içerik.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kilitli) {
      return child;
    }
    return Stack(
      children: <Widget>[
        // Blur: içerik seçilemeyecek kadar bulanık ama biçimi belli.
        ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: CategoriesConfig.blurSigma,
            sigmaY: CategoriesConfig.blurSigma,
          ),
          child: child,
        ),
        // Scrim: blur'un okunabilir bırakabileceği yüksek kontrastlı
        // içeriği (ör. skor sayısı) örten yarı saydam karartma.
        Positioned.fill(
          child: ColoredBox(
            color: AppColors.background
                .withValues(alpha: CategoriesConfig.kilitScrimOpaklik),
          ),
        ),
        const Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_rounded,
              color: AppColors.gold,
              size: CategoriesConfig.kilitIkonBoyutu,
            ),
          ),
        ),
      ],
    );
  }
}
