import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_dil.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/cosmic_config.dart';
import '../../shared/widgets/cosmic_page.dart';
import '../../shared/widgets/kader_button.dart';
import '../daily_luck/daily_luck_providers.dart';
import 'categories_strings.dart';
import 'entitlement.dart';

/// Gerçek yetki durumunu anlatan Premium sayfası; mağaza bağlı değilken satış yoktur.
class PaywallScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const PaywallScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppDil dil = ref.watch(dilProvider);
    final bool active = ref.watch(entitlementProvider);
    final TextTheme text = Theme.of(context).textTheme;
    return CosmicPage(
      tone: CosmicTone.rare,
      appBar: AppBar(title: const Text(CategoriesStrings.paywallBaslik)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: SizedBox(
                      height: CosmicConfig.premiumHeroHeight,
                      child: Image.asset(
                        CosmicConfig.premium,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, .05),
                        cacheWidth: CosmicConfig.decodeWidth,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    CategoriesStrings.premiumHeadline(dil),
                    textAlign: TextAlign.center,
                    style: text.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    CategoriesStrings.paywallAciklama(dil),
                    textAlign: TextAlign.center,
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CosmicPanel(
                    child: Column(
                      children: <Widget>[
                        for (final String feature
                            in CategoriesStrings.paywallOzellikler(dil))
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: CosmicConfig.gold,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(feature, style: text.bodyLarge),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CosmicPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          active
                              ? CategoriesStrings.active(dil)
                              : CategoriesStrings.unavailable(dil),
                          style: text.titleMedium?.copyWith(
                            color: CosmicConfig.goldLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          CategoriesStrings.purchaseExplanation(dil, active),
                          style: text.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          CategoriesStrings.scoreUnchanged(dil),
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  KaderButton(
                    cosmic: true,
                    label: CategoriesStrings.backToCards(dil),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
