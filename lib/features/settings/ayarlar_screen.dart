import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/icerik_paketi.dart';
import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/dil_config.dart';
import '../../l10n/dil_providers.dart';
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

/// Ayarlar: profil, premium, bildirimler, dil, gizlilik/yasal ve veri silme.
class AyarlarScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const AyarlarScreen({super.key});

  Future<void> _verileriSil(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool? onay = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text(l.ayarlarSilOnayBaslik),
        content: Text(l.ayarlarVerileriSilAciklama),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(d).pop(false),
            child: Text(l.ayarlarVazgec),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(d).pop(true),
            child: Text(l.ayarlarSil),
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
    final AppLocalizations l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        content: Text(metin),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(d).pop(),
            child: Text(l.ayarlarTamam),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);
    final IcerikDili? dilTercihi = ref.watch(dilTercihiProvider);
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
                child: Text(l.ayarlarBaslik, style: yazi.headlineMedium),
              ),
              bolumBasligi(l.ayarlarProfil),
              ListTile(title: Text(l.ayarlarAd), trailing: Text(profil.isim)),
              ListTile(
                title: Text(l.ayarlarDogumTarihi),
                subtitle: Text(l.ayarlarSabitAlanNotu),
                trailing: Text(
                  TrStrings.tarihMetni(profil.dogumTarihi).split(',').first,
                ),
              ),
              ListTile(
                title: Text(l.ayarlarTamAd),
                subtitle: Text(profil.tamAd ?? l.ayarlarTamAdYok),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => unawaited(tamAdiDuzenle(context, ref)),
              ),
              ListTile(
                title: Text(l.ayarlarTercihler),
                subtitle: Text(l.ayarlarTercihlerAciklama),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  fadeThroughRoute<void>(const TanismaScreen(duzenleme: true)),
                ),
              ),
              bolumBasligi(l.ayarlarPremium),
              ListTile(
                leading: Icon(
                  premium.aktif
                      ? Icons.workspace_premium_rounded
                      : Icons.workspace_premium_outlined,
                  color: AppColors.gold,
                ),
                title: Text(
                  premium.aktif ? l.ayarlarPremiumAktif : l.ayarlarPremiumDegil,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: premium.aktif
                    ? () => _bilgiGoster(context, PremiumStrings.yonetimBilgisi)
                    : () => Navigator.of(
                        context,
                      ).push(fadeThroughRoute<void>(const PaywallScreen())),
                subtitle: Text(
                  premium.aktif
                      ? l.ayarlarAboneligiYonet
                      : l.ayarlarPremiumaGec,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.restore_rounded),
                title: Text(l.ayarlarGeriYukle),
                onTap: premium.islemde
                    ? null
                    : () => unawaited(
                        ref.read(premiumKontrolcuProvider.notifier).geriYukle(),
                      ),
              ),
              bolumBasligi(l.ayarlarBildirimler),
              ListTile(
                leading: const Icon(Icons.notifications_none_rounded),
                title: Text(l.ayarlarBildirimSaatleri),
                subtitle: Text(l.ayarlarBildirimAciklama),
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: Text(l.ayarlarBildirimleriTazele),
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
                    SnackBar(content: Text(l.ayarlarBildirimlerKuruldu)),
                  );
                },
              ),
              // İngilizce yayına kadar dil seçimi yalnız debug'da (DilConfig).
              if (DilConfig.ingilizceYayinda || kDebugMode) ...<Widget>[
                bolumBasligi(l.ayarlarDil),
                for (final IcerikDili? dil in <IcerikDili?>[
                  null,
                  ...IcerikDili.values,
                ])
                  ListTile(
                    key: ValueKey<String>('dil_${dil?.name ?? 'cihaz'}'),
                    leading: const Icon(Icons.translate_rounded),
                    title: Text(
                      dil == null ? l.ayarlarDilCihaz : DilConfig.yerelAd(dil),
                    ),
                    trailing: dil == dilTercihi
                        ? const Icon(Icons.check_rounded, color: AppColors.gold)
                        : null,
                    onTap: () => unawaited(
                      ref.read(dilTercihiProvider.notifier).sec(dil),
                    ),
                  ),
              ],
              bolumBasligi(l.ayarlarGizlilikYasal),
              if (gizlilikGerekli)
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l.ayarlarReklamGizlilik),
                  onTap: () => unawaited(
                    ref
                        .read(reklamServisiProvider)
                        .gizlilikSecenekleriniGoster(),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(l.ayarlarUyari),
                onTap: () => _bilgiGoster(
                  context,
                  YasalMetinler.uyariMaddeleri.join('\n\n'),
                ),
              ),
              for (final YasalBelge belge in YasalBelge.values)
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(belge.baslik(l)),
                  onTap: () => Navigator.of(context).push(
                    fadeThroughRoute<void>(YasalBelgeScreen(belge: belge)),
                  ),
                ),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_outlined,
                  color: AppColors.error,
                ),
                title: Text(
                  l.ayarlarVerileriSil,
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () => unawaited(_verileriSil(context, ref)),
              ),
              if (kDebugMode) ...<Widget>[
                bolumBasligi(l.ayarlarGelistirici),
                SwitchListTile(
                  title: Text(l.ayarlarPremiumSimulasyonu),
                  value: premium.aktif,
                  onChanged: (bool acik) => unawaited(
                    ref
                        .read(premiumKontrolcuProvider.notifier)
                        .gelistiriciPremiumAyarla(acik: acik),
                  ),
                ),
                ListTile(
                  title: Text(l.ayarlarRizaSifirla),
                  onTap: () async {
                    final ScaffoldMessengerState mesajci = ScaffoldMessenger.of(
                      context,
                    );
                    await ref.read(reklamServisiProvider).rizayiSifirla();
                    mesajci.showSnackBar(
                      SnackBar(content: Text(l.ayarlarRizaSifirlandi)),
                    );
                  },
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l.ayarlarSurum(LegalConfig.uygulamaSurumu),
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
