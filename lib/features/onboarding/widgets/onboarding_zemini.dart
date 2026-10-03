import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../shared/widgets/app_images.dart';
import '../../../shared/widgets/sahne_arka_plani.dart';
import '../onboarding_config.dart';
import '../onboarding_strings.dart';

/// Onboarding ekranlarının ortak zemini: sütunlu kemerler ve ayna göl
/// ([AppImages.sahneOnboarding]); alt kısım form alanları için koyulaşır.
class OnboardingZemini extends StatelessWidget {
  /// [child] içeriğini sahnenin önüne koyar.
  const OnboardingZemini({required this.child, this.yogun = false, super.key});

  /// Sahnenin önündeki içerik.
  final Widget child;

  /// Yoğun metinli ekran mı (form, sorular)? Öyleyse karartma erken
  /// başlar ki metin her yerde okunur kalsın.
  final bool yogun;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: SahneArkaPlani(
            gorsel: AppImages.sahneOnboarding,
            hizalama: Alignment.topCenter,
            altKarartmaBaslangici: yogun
                ? OnboardingConfig.yogunKarartmaBaslangici
                : OnboardingConfig.karartmaBaslangici,
            altKarartmaSonu: yogun
                ? OnboardingConfig.yogunKarartmaSonu
                : OnboardingConfig.karartmaSonu,
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

/// "─ ✦ Günlük bir ilham ritüeli. ✦ ─" alt notu (mockup).
class RituelNotu extends StatelessWidget {
  /// Varsayılan kurucu.
  const RituelNotu({this.metin = OnboardingStrings.rituelNotu, super.key});

  /// Gösterilecek not.
  final String metin;

  @override
  Widget build(BuildContext context) {
    Widget cizgi({required bool sol}) => Expanded(
      child: Divider(
        color: AppColors.gold.withValues(
          alpha: OnboardingConfig.notCizgiOpakligi,
        ),
        indent: sol ? AppSpacing.lg : AppSpacing.sm,
        endIndent: sol ? AppSpacing.sm : AppSpacing.lg,
      ),
    );
    return Row(
      children: <Widget>[
        cizgi(sol: true),
        Text(
          metin,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        cizgi(sol: false),
      ],
    );
  }
}
