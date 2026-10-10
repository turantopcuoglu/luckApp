import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/luck_history_repository.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/kilit_amblemi.dart';
import '../ads/ads_providers.dart';
import '../daily_luck/daily_luck_providers.dart';
import 'paywall_screen.dart';
import 'premium_providers.dart';

/// Kilitli içeriğe dokunulunca açılan seçenekler: Premium'a geç ya da
/// ödüllü reklam izleyerek içeriği YALNIZCA BUGÜN için aç.
///
/// Döndürdüğü değer: içerik bu akışla açıldıysa true.
Future<bool> kilitSecenekleriniGoster(
  BuildContext context,
  WidgetRef ref, {
  required String kilitAnahtari,
  required String aciklama,
}) async {
  final bool? sonuc = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => _KilitSheet(
      kilitAnahtari: kilitAnahtari,
      aciklama: aciklama,
    ),
  );
  return sonuc ?? false;
}

class _KilitSheet extends ConsumerWidget {
  const _KilitSheet({required this.kilitAnahtari, required this.aciklama});

  final String kilitAnahtari;
  final String aciklama;

  Future<void> _reklamIzle(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final ScaffoldMessengerState mesajci = ScaffoldMessenger.of(context);
    final NavigatorState gezgin = Navigator.of(context);
    final bool kazandi = await ref.read(reklamServisiProvider).odulluGoster();
    if (!kazandi) {
      mesajci.showSnackBar(
        SnackBar(
          content: Text(
            ref.read(reklamServisiProvider).hazir
                ? l.premiumOdulYok
                : l.premiumReklamYok,
          ),
        ),
      );
      return;
    }
    final LuckHistoryRepository repo = ref.read(luckHistoryRepositoryProvider);
    final DateTime bugun = ref.read(bugunProvider);
    // Bugünün kaydı yoksa (nadir: ekran kaydı üretmeden açıldı) önce üret.
    await ref.read(gununSansiProvider.future);
    await repo.reklamKilidiAc(bugun, kilitAnahtari);
    kilitleriTazele(ref);
    mesajci.showSnackBar(
      SnackBar(content: Text(l.premiumAcildi)),
    );
    gezgin.pop(true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final bool reklamHazir = ref.watch(reklamHazirProvider);
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
            const Center(
              child: KilitAmblemi(boyut: PaywallConfig.kilitPencereAmblemi),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.premiumKilitBaslik,
              style: yazi.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              aciklama,
              style: yazi.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                Navigator.of(context).push(
                  fadeThroughRoute<void>(const PaywallScreen()),
                );
              },
              child: Text(l.premiumPremiumaGec),
            ),
            if (reklamHazir) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => _reklamIzle(context, ref),
                icon: const Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppColors.gold,
                ),
                label: Text(l.premiumReklamlaAc),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSpacing.xxl),
                  side: const BorderSide(color: AppColors.gold),
                  foregroundColor: AppColors.gold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
