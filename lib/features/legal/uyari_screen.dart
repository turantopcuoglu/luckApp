import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/altin_buton.dart';
import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/sahne_arka_plani.dart';
import 'legal_config.dart';
import 'legal_texts.dart';
import 'yasal_belge_screen.dart';

/// Uyarı ekranındaki kabul kutusunun durumu.
final AutoDisposeStateProvider<bool> uyariOnayProvider =
    StateProvider.autoDispose<bool>((Ref ref) => false);

/// Uygulamanın başındaki uyarı ve onay ekranı.
///
/// İki yerde kullanılır: onboarding'in ikinci adımı ve koşullar sürümü
/// değiştiğinde mevcut kullanıcıya gösterilen kapı. Ne yapılacağı
/// [onKabul] ile dışarıdan verilir.
class UyariScreen extends ConsumerWidget {
  /// [onKabul] kabul sonrası akışı yürütür.
  const UyariScreen({required this.onKabul, super.key});

  /// Kullanıcı kutuyu işaretleyip "Devam"a basınca çağrılır.
  final void Function(BuildContext context, WidgetRef ref) onKabul;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);
    final bool onay = ref.watch(uyariOnayProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: SahneArkaPlani(
              gorsel: AppImages.sahneOnboarding,
              hizalama: Alignment.topCenter,
              altKarartmaBaslangici: LegalConfig.karartmaBaslangici,
              altKarartmaSonu: LegalConfig.karartmaSonu,
            ),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: <Widget>[
                      Center(
                        child: Image.asset(
                          AppImages.parilti,
                          width: LegalConfig.uyariParilti,
                          height: LegalConfig.uyariParilti,
                          excludeFromSemantics: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l.yasalUyariBaslik,
                        style: yazi.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      for (final String madde in YasalMetinler.uyariMaddeleri)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(top: AppSpacing.xs),
                                child: Icon(
                                  Icons.circle,
                                  size: AppSpacing.sm,
                                  color: AppColors.purple,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  madde,
                                  style: yazi.bodyMedium?.copyWith(
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: <Widget>[
                          for (final YasalBelge belge in YasalBelge.values)
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                fadeThroughRoute<void>(
                                  YasalBelgeScreen(belge: belge),
                                ),
                              ),
                              child: Text(belge.baslik(l)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    children: <Widget>[
                      CheckboxListTile(
                        key: const Key('uyari-onay'),
                        value: onay,
                        onChanged: (bool? yeni) =>
                            ref.read(uyariOnayProvider.notifier).state =
                                yeni ?? false,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.gold,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          YasalMetinler.uyariKabul,
                          style: yazi.bodySmall,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AltinButon(
                        genislik: null,
                        metin: l.yasalDevam,
                        onPressed: onay ? () => onKabul(context, ref) : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
