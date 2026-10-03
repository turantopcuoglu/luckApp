import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/yillik_rapor.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/sahne_config.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../premium/premium_config.dart';
import 'profile_config.dart';
import 'profile_providers.dart';
import 'profile_strings.dart';
import 'yil_afisi.dart';
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
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: () => unawaited(
          Navigator.of(
            context,
          ).push(fadeThroughRoute<void>(const YilRaporuScreen(yil: yil))),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.gold),
          ),
          child: YilAfisi(
            kisiselYil: okuma.kisiselYil,
            yukseklik: SahneConfig.afisKartYuksekligi,
            child: Row(
              children: <Widget>[
                Text(
                  '${okuma.kisiselYil}',
                  style: yazi.displaySmall?.copyWith(color: AppColors.gold),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        ProfileStrings.yilRaporuKartBaslik(yil),
                        style: yazi.titleMedium?.copyWith(
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        ProfileStrings.yilRaporuKartAciklama(
                          yil,
                          okuma.yilLakabi,
                        ),
                        maxLines: ProfileConfig.yilKartiSatirSayisi,
                        overflow: TextOverflow.ellipsis,
                        style: yazi.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
