import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/yillik_rapor.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_route.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../premium/premium_config.dart';
import 'profile_config.dart';
import 'profile_providers.dart';
import 'profile_strings.dart';
import 'yil_raporu_screen.dart';

/// Satıştaki yılın Kişisel Yıl Raporu'nu ana ekranda tanıtan kart.
///
/// Yalnızca tanıtım döneminde görünür: satıştaki yıldan önceki yılın
/// [ProfileConfig.yilRaporuTanitimAyi] ayından satıştaki yılın sonuna
/// kadar. Kişinin o yılki lakabını gösterir ("2027 senin için Tohum
/// Yılı") — rapor açılmadan da kişisel bir ipucu verir.
class YilRaporuKarti extends ConsumerWidget {
  /// Varsayılan kurucu.
  const YilRaporuKarti({super.key});

  /// [bugun] tarihinde [yil] raporu tanıtılmalı mı?
  static bool gosterilmeli(DateTime bugun, int yil) =>
      bugun.year == yil ||
      (bugun.year == yil - 1 &&
          bugun.month >= ProfileConfig.yilRaporuTanitimAyi);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const int yil = PremiumConfig.satistakiYil;
    if (!gosterilmeli(ref.watch(bugunProvider), yil)) {
      return const SizedBox.shrink();
    }
    final YillikRaporOkumasi okuma = ref.watch(yillikRaporProvider(yil));
    final TextTheme yazi = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.gold),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => unawaited(
          Navigator.of(
            context,
          ).push(fadeThroughRoute<void>(const YilRaporuScreen(yil: yil))),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              Text(
                '${okuma.kisiselYil}',
                style: yazi.displaySmall?.copyWith(color: AppColors.gold),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ProfileStrings.yilRaporuKartBaslik(yil),
                      style: yazi.titleMedium?.copyWith(color: AppColors.gold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ProfileStrings.yilRaporuKartAciklama(
                        yil,
                        okuma.yilLakabi,
                      ),
                      style: yazi.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}
