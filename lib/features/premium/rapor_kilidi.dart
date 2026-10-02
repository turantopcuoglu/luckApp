import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_route.dart';
import 'magaza_servisi.dart';
import 'paywall_screen.dart';
import 'premium_kontrolcu.dart';
import 'premium_providers.dart';
import 'premium_strings.dart';

/// Numeroloji Raporu'nun kilitli bölümüne dokunulunca açılan seçenekler:
/// raporu tek seferlik ödemeyle aç ya da Premium'a geç.
///
/// Ödüllü reklam seçeneği bilinçli olarak yoktur (bkz.
/// [raporAcikProvider]). Rapor açıldığında sheet kendiliğinden kapanır.
///
/// Döndürdüğü değer: rapor bu akışla açıldıysa true.
Future<bool> raporKilidiniGoster(BuildContext context) async {
  final bool? sonuc = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext _) => const _RaporKilidiSheet(),
  );
  return sonuc ?? false;
}

class _RaporKilidiSheet extends ConsumerStatefulWidget {
  const _RaporKilidiSheet();

  @override
  ConsumerState<_RaporKilidiSheet> createState() => _RaporKilidiSheetState();
}

class _RaporKilidiSheetState extends ConsumerState<_RaporKilidiSheet> {
  @override
  void initState() {
    super.initState();
    // Ürün açılışta yüklenemediyse (ör. ağ yoktu) burada yeniden denenir.
    if (ref.read(premiumKontrolcuProvider).raporUrunu == null) {
      unawaited(ref.read(premiumKontrolcuProvider.notifier).raporUrunuYukle());
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final PremiumDurumu durum = ref.watch(premiumKontrolcuProvider);
    final TekSeferlikUrun? urun = durum.raporUrunu;

    ref.listen<bool>(raporAcikProvider, (bool? eski, bool yeni) {
      if (yeni && !(eski ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(PremiumStrings.raporAcildi)),
        );
        Navigator.of(context).pop(true);
      }
    });

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.auto_stories_rounded, color: AppColors.gold),
            const SizedBox(height: AppSpacing.sm),
            Text(
              PremiumStrings.raporKilitBaslik,
              style: yazi.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              PremiumStrings.raporKilitAciklama,
              style: yazi.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (durum.hataMesaji != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                durum.hataMesaji!,
                style: yazi.bodySmall?.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: urun == null || durum.islemde
                  ? null
                  : () => unawaited(
                      ref
                          .read(premiumKontrolcuProvider.notifier)
                          .raporuSatinAl(),
                    ),
              child: durum.islemde
                  ? const SizedBox.square(
                      dimension: AppSpacing.md,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      urun == null
                          ? PremiumStrings.raporFiyatYukleniyor
                          : PremiumStrings.raporuSatinAl(urun.fiyatMetni),
                    ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                unawaited(
                  Navigator.of(
                    context,
                  ).push(fadeThroughRoute<void>(const PaywallScreen())),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.xxl),
                side: const BorderSide(color: AppColors.gold),
                foregroundColor: AppColors.gold,
              ),
              child: const Text(PremiumStrings.raporPremiumSecenegi),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              PremiumStrings.raporOdemeBilgisi,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
