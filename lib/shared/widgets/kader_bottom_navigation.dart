import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/cosmic_config.dart';

/// Erişilebilir gezinme hedefi; metin çağıran feature tarafından yerelleştirilir.
class KaderNavigationItem {
  /// Gerçek etiket ve standart işlev ikonu.
  const KaderNavigationItem({required this.label, required this.icon});

  /// Görünen ve ekran okuyucunun duyacağı etiket.
  final String label;

  /// İşlev ikonu; ayrıca tekrar okutulmaz.
  final IconData icon;
}

/// Büyük yazıda yüksekliği artan, renk dışında seçimi semantics ile anlatan çubuk.
class KaderBottomNavigation extends StatelessWidget {
  /// Seçim çağıran katmanda tutulur; çubuk kendi state'ini saklamaz.
  const KaderBottomNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  }) : assert(items.length > 1),
       assert(selectedIndex >= 0 && selectedIndex < items.length);

  /// Sıralı hedefler.
  final List<KaderNavigationItem> items;

  /// Etkin hedefin indeksi.
  final int selectedIndex;

  /// Yeni hedefe geçme isteği.
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: CosmicConfig.navigationSurface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.md),
          ),
          border: Border.all(color: CosmicConfig.social.withValues(alpha: .22)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int index = 0; index < items.length; index++)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: selectedIndex == index,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          onTap: () => onSelected(index),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: AppLayout.navigationMinHeight,
                              minWidth: AppLayout.minTouchTarget,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ExcludeSemantics(
                                    child: AnimatedContainer(
                                      duration: AppMotion.reduceMotion(context)
                                          ? Duration.zero
                                          : AppMotion.press,
                                      width: AppLayout.minTouchTarget,
                                      height:
                                          AppLayout.navigationIndicatorHeight,
                                      decoration: BoxDecoration(
                                        gradient: selectedIndex == index
                                            ? RadialGradient(
                                                colors: <Color>[
                                                  CosmicConfig.gold.withValues(
                                                    alpha: .18,
                                                  ),
                                                  Colors.transparent,
                                                ],
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.full,
                                        ),
                                      ),
                                      child: Icon(
                                        items[index].icon,
                                        size: AppLayout.iconSize,
                                        color: selectedIndex == index
                                            ? CosmicConfig.gold
                                            : colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    items[index].label,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: selectedIndex == index
                                              ? CosmicConfig.goldLight
                                              : colors.onSurfaceVariant,
                                          fontWeight: selectedIndex == index
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  AnimatedContainer(
                                    key: ValueKey<String>(
                                      'navigation-light-$index',
                                    ),
                                    duration: AppMotion.reduceMotion(context)
                                        ? Duration.zero
                                        : AppMotion.press,
                                    width: CosmicConfig.navigationLightWidth,
                                    height: CosmicConfig.navigationLightHeight,
                                    decoration: BoxDecoration(
                                      gradient: selectedIndex == index
                                          ? const LinearGradient(
                                              colors: <Color>[
                                                Colors.transparent,
                                                CosmicConfig.goldLight,
                                                Colors.transparent,
                                              ],
                                            )
                                          : null,
                                      boxShadow: selectedIndex == index
                                          ? <BoxShadow>[
                                              BoxShadow(
                                                color: CosmicConfig.gold
                                                    .withValues(alpha: .30),
                                                blurRadius: 7,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
