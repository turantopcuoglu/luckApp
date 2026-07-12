import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_dil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../daily_luck/daily_luck_providers.dart';
import 'categories_config.dart';
import 'categories_strings.dart';

/// Paywall placeholder'ı: satın alma entegrasyonu YOKTUR (plan
/// Session 9, madde 2); yalnızca premium teklifinin arayüzü.
///
/// RevenueCat bağlanınca buton, `entitlementProvider`'ı güncelleyen
/// gerçek satın alma akışına bağlanacak.
class PaywallScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final AppDil dil = ref.watch(dilProvider);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              AppIllustrations.kristalKure(
                boyut: CategoriesConfig.paywallIllustrasyonBoyutu,
                renk: AppColors.gold,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                CategoriesStrings.paywallBaslik,
                style: yaziTemasi.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                CategoriesStrings.paywallAciklama(dil),
                style: yaziTemasi.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final String ozellik in CategoriesStrings.paywallOzellikler(
                dil,
              ))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.gold,
                        size: AppSpacing.md,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(ozellik, style: yaziTemasi.bodyMedium),
                    ],
                  ),
                ),
              const Spacer(),
              FilledButton(
                // Placeholder: gerçek satın alma yok, bilgi mesajı var.
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(CategoriesStrings.paywallYakinda(dil)),
                  ),
                ),
                child: Text(CategoriesStrings.paywallButon(dil)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
