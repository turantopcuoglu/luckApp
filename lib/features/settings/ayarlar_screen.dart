import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/sahne_arka_plani.dart';
import '../../shared/widgets/sahne_config.dart';
import '../ads/ads_providers.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../daily_luck/tr_strings.dart';
import '../feedback/notification_service.dart';
import '../legal/legal_config.dart';
import '../legal/legal_texts.dart';
import '../legal/yasal_belge_screen.dart';
import '../onboarding/tanisma_screen.dart';
import '../onboarding/welcome_screen.dart';
import '../premium/paywall_screen.dart';
import '../premium/premium_kontrolcu.dart';
import '../premium/premium_strings.dart';
import '../profile/tam_ad_duzenle.dart';
import 'ayarlar_strings.dart';

/// Ayarlar: profil, premium, bildirimler, gizlilik/yasal ve veri silme.
class AyarlarScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const AyarlarScreen({super.key});

  Future<void> _verileriSil(BuildContext context, WidgetRef ref) async {
    final bool? onay = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: const Text(AyarlarStrings.silOnayBaslik),
        content: const Text(AyarlarStrings.verileriSilAciklama),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(d).pop(false),
            child: const Text(AyarlarStrings.vazgec),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(d).pop(true),
            child: const Text(AyarlarStrings.sil),
          ),
        ],
      ),
    );
    if (!(onay ?? false)) {
      return;
    }
    await Future.wait(<Future<Object?>>[
      ref.read(userProfileBoxProvider).clear(),
      ref.read(dailyRecordsBoxProvider).clear(),
      ref.read(kisilerBoxProvider).clear(),
      ref.read(appStateBoxProvider).clear(),
      ref.read(notificationServiceProvider).hepsiniIptalEt(),
    ]);
    ref
      ..invalidate(aktifProfilProvider)
      ..invalidate(gununSansiProvider)
      ..invalidate(premiumKontrolcuProvider);
    if (!context.mounted) {
      return;
    }
    await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      fadeThroughRoute<void>(const WelcomeScreen()),
      (Route<dynamic> r) => false,
    );
  }

  void _bilgiGoster(BuildContext context, String metin) {
    showDialog<void>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        content: Text(metin),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(d).pop(),
            child: const Text(AyarlarStrings.tamam),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final UserProfile profil = ref.watch(aktifProfilProvider);
    final PremiumDurumu premium = ref.watch(premiumKontrolcuProvider);
    final bool gizlilikGerekli = ref
        .watch(reklamServisiProvider)
        .gizlilikSecenekleriGerekli;

    Widget bolumBasligi(String metin) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        metin.toUpperCase(),
        style: yazi.labelMedium?.copyWith(color: AppColors.gold),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SahneliZemin(
        gorsel: AppImages.sahneKapali,
        altKarartmaBaslangici: SahneConfig.listeKarartmaBaslangici,
        altKarartmaSonu: SahneConfig.listeKarartmaSonu,
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(AyarlarStrings.baslik, style: yazi.headlineMedium),
              ),
              bolumBasligi(AyarlarStrings.profil),
              ListTile(
                title: const Text(AyarlarStrings.ad),
                trailing: Text(profil.isim),
              ),
              ListTile(
                title: const Text(AyarlarStrings.dogumTarihi),
                subtitle: const Text(AyarlarStrings.sabitAlanNotu),
                trailing: Text(
                  TrStrings.tarihMetni(profil.dogumTarihi).split(',').first,
                ),
              ),
              ListTile(
                title: const Text(AyarlarStrings.tamAd),
                subtitle: Text(profil.tamAd ?? AyarlarStrings.tamAdYok),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => unawaited(tamAdiDuzenle(context, ref)),
              ),
              ListTile(
                title: const Text(AyarlarStrings.tercihler),
                subtitle: const Text(AyarlarStrings.tercihlerAciklama),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  fadeThroughRoute<void>(const TanismaScreen(duzenleme: true)),
                ),
              ),
              bolumBasligi(AyarlarStrings.premium),
              ListTile(
                leading: Icon(
                  premium.aktif
                      ? Icons.workspace_premium_rounded
                      : Icons.workspace_premium_outlined,
                  color: AppColors.gold,
                ),
                title: Text(
                  premium.aktif
                      ? AyarlarStrings.premiumAktif
                      : AyarlarStrings.premiumDegil,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: premium.aktif
                    ? () => _bilgiGoster(context, PremiumStrings.yonetimBilgisi)
                    : () => Navigator.of(
                        context,
                      ).push(fadeThroughRoute<void>(const PaywallScreen())),
                subtitle: Text(
                  premium.aktif
                      ? AyarlarStrings.aboneligiYonet
                      : AyarlarStrings.premiumaGec,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.restore_rounded),
                title: const Text(AyarlarStrings.geriYukle),
                onTap: premium.islemde
                    ? null
                    : () => unawaited(
                        ref.read(premiumKontrolcuProvider.notifier).geriYukle(),
                      ),
              ),
              bolumBasligi(AyarlarStrings.bildirimler),
              const ListTile(
                leading: Icon(Icons.notifications_none_rounded),
                title: Text(AyarlarStrings.bildirimSaatleri),
                subtitle: Text(AyarlarStrings.bildirimAciklama),
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text(AyarlarStrings.bildirimleriTazele),
                onTap: () async {
                  final ScaffoldMessengerState mesajci = ScaffoldMessenger.of(
                    context,
                  );
                  final NotificationService servis = ref.read(
                    notificationServiceProvider,
                  );
                  if (await servis.izinIste()) {
                    await servis.gunlukBildirimleriPlanla(
                      simdi: DateTime.now(),
                    );
                  }
                  mesajci.showSnackBar(
                    const SnackBar(
                      content: Text(AyarlarStrings.bildirimlerKuruldu),
                    ),
                  );
                },
              ),
              bolumBasligi(AyarlarStrings.gizlilikYasal),
              if (gizlilikGerekli)
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text(AyarlarStrings.reklamGizlilik),
                  onTap: () => unawaited(
                    ref
                        .read(reklamServisiProvider)
                        .gizlilikSecenekleriniGoster(),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text(AyarlarStrings.uyari),
                onTap: () => _bilgiGoster(
                  context,
                  YasalMetinler.uyariMaddeleri.join('\n\n'),
                ),
              ),
              for (final YasalBelge belge in YasalBelge.values)
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(belge.baslik),
                  onTap: () => Navigator.of(context).push(
                    fadeThroughRoute<void>(YasalBelgeScreen(belge: belge)),
                  ),
                ),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_outlined,
                  color: AppColors.error,
                ),
                title: const Text(
                  AyarlarStrings.verileriSil,
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => unawaited(_verileriSil(context, ref)),
              ),
              if (kDebugMode) ...<Widget>[
                bolumBasligi(AyarlarStrings.gelistirici),
                SwitchListTile(
                  title: const Text(AyarlarStrings.premiumSimulasyonu),
                  value: premium.aktif,
                  onChanged: (bool acik) => unawaited(
                    ref
                        .read(premiumKontrolcuProvider.notifier)
                        .gelistiriciPremiumAyarla(acik: acik),
                  ),
                ),
                ListTile(
                  title: const Text(AyarlarStrings.rizaSifirla),
                  onTap: () async {
                    final ScaffoldMessengerState mesajci = ScaffoldMessenger.of(
                      context,
                    );
                    await ref.read(reklamServisiProvider).rizayiSifirla();
                    mesajci.showSnackBar(
                      const SnackBar(
                        content: Text(AyarlarStrings.rizaSifirlandi),
                      ),
                    );
                  },
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  AyarlarStrings.surum(LegalConfig.uygulamaSurumu),
                  style: yazi.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
