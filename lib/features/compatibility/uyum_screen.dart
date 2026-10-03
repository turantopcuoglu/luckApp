import 'dart:async';

import 'package:flutter/cupertino.dart'
    show CupertinoDatePicker, CupertinoDatePickerMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/kayitli_kisi.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/app_route.dart';
import '../onboarding/onboarding_config.dart';
import '../premium/paywall_screen.dart';
import '../premium/premium_config.dart';
import '../premium/premium_providers.dart';
import '../premium/premium_strings.dart';
import 'uyum_config.dart';
import 'uyum_sonuc_screen.dart';
import 'uyum_strings.dart';

/// Kayıtlı kişilerin listesi.
///
/// Kişi ekleme/silme sonrası invalidate edilir.
final Provider<List<KayitliKisi>> kisilerProvider = Provider<List<KayitliKisi>>(
  (Ref ref) => ref.watch(kisiRepositoryProvider).tumu(),
);

/// Uyum ekranı: kayıtlı kişiler ve yeni kişi ekleme.
///
/// Ücretsiz sürümde [PremiumConfig.ucretsizKisiSiniri] kişi kaydedilebilir.
class UyumScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const UyumScreen({super.key});

  Future<void> _ekle(BuildContext context, WidgetRef ref) async {
    final List<KayitliKisi> mevcut = ref.read(kisilerProvider);
    if (!ref.read(entitlementProvider) &&
        mevcut.length >= PremiumConfig.ucretsizKisiSiniri) {
      final bool? premiumaGit = await showDialog<bool>(
        context: context,
        builder: (BuildContext d) => AlertDialog(
          content: const Text(PremiumStrings.kisiSiniri),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(d).pop(false),
              child: const Text(UyumStrings.vazgec),
            ),
            FilledButton(
              onPressed: () => Navigator.of(d).pop(true),
              child: const Text(PremiumStrings.premiumaGec),
            ),
          ],
        ),
      );
      if ((premiumaGit ?? false) && context.mounted) {
        await Navigator.of(
          context,
        ).push(fadeThroughRoute<void>(const PaywallScreen()));
      }
      return;
    }
    final KayitliKisi? yeni = await Navigator.of(
      context,
    ).push<KayitliKisi>(fadeThroughRoute<KayitliKisi>(const KisiEkleScreen()));
    if (yeni == null || !context.mounted) {
      return;
    }
    // Bellek içi kutu anında güncellenir; disk yazması beklenmez.
    unawaited(ref.read(kisiRepositoryProvider).kaydet(yeni));
    ref.invalidate(kisilerProvider);
    await Navigator.of(
      context,
    ).push(fadeThroughRoute<void>(UyumSonucScreen(kisi: yeni)));
  }

  Future<void> _sil(
    BuildContext context,
    WidgetRef ref,
    KayitliKisi kisi,
  ) async {
    final bool? onay = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text(UyumStrings.silBaslik(kisi.kisaAd)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(d).pop(false),
            child: const Text(UyumStrings.vazgec),
          ),
          FilledButton(
            onPressed: () => Navigator.of(d).pop(true),
            child: const Text(UyumStrings.sil),
          ),
        ],
      ),
    );
    if (onay ?? false) {
      unawaited(ref.read(kisiRepositoryProvider).sil(kisi.id));
      ref.invalidate(kisilerProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final List<KayitliKisi> kisiler = ref.watch(kisilerProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(_ekle(context, ref)),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(UyumStrings.kisiEkle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            Center(
              child: Image.asset(
                AppImages.uyumBos,
                width: UyumConfig.kahramanBoyutu,
                height: UyumConfig.kahramanBoyutu,
                excludeFromSemantics: true,
              ),
            ),
            Text(
              UyumStrings.baslik,
              style: yazi.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              UyumStrings.aciklama,
              style: yazi.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (kisiler.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Text(
                  UyumStrings.bosDurum,
                  style: yazi.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            for (final KayitliKisi kisi in kisiler)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Image.asset(
                      AppImages.burc(kisi.profil.burc.name),
                      width: UyumConfig.kisiMadalyonBoyutu,
                      height: UyumConfig.kisiMadalyonBoyutu,
                      excludeFromSemantics: true,
                    ),
                    title: Text(kisi.ad),
                    subtitle: Text(
                      UyumStrings.kisiOzeti(
                        rol: kisi.rol.etiket,
                        burc: kisi.profil.burc.etiket,
                        yasamYolu: kisi.profil.yasamYolu.deger,
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: UyumStrings.sil,
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => unawaited(_sil(context, ref, kisi)),
                    ),
                    onTap: () => Navigator.of(
                      context,
                    ).push(fadeThroughRoute<void>(UyumSonucScreen(kisi: kisi))),
                  ),
                ),
              ),
            // FAB içeriği örtmesin diye alt boşluk.
            const SizedBox(height: AppSpacing.xxl + AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// Form durumu: seçili doğum tarihi.
final AutoDisposeStateProvider<DateTime> kisiDogumProvider =
    StateProvider.autoDispose<DateTime>(
      (Ref ref) => OnboardingConfig.varsayilanDogumTarihi,
    );

/// Form durumu: seçili rol.
final AutoDisposeStateProvider<KisiRolu> kisiRolProvider =
    StateProvider.autoDispose<KisiRolu>((Ref ref) => KisiRolu.partner);

/// Yeni kişi formu; kaydedilecek [KayitliKisi]'yi geri döndürür.
class KisiEkleScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const KisiEkleScreen({super.key});

  @override
  ConsumerState<KisiEkleScreen> createState() => _KisiEkleScreenState();
}

class _KisiEkleScreenState extends ConsumerState<KisiEkleScreen> {
  final TextEditingController _ad = TextEditingController();

  @override
  void dispose() {
    _ad.dispose();
    super.dispose();
  }

  void _kaydet() {
    final String ad = _ad.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (ad.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(UyumStrings.adBos)));
      return;
    }
    Navigator.of(context).pop(
      KayitliKisi(
        id: KisiRepository.yeniKimlik(DateTime.now()),
        ad: ad,
        dogumTarihi: ref.read(kisiDogumProvider),
        rol: ref.read(kisiRolProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final KisiRolu rol = ref.watch(kisiRolProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(UyumStrings.formBaslik)),
      // Kaydet butonu listenin dışında, altta sabit: klavye ve tarih
      // seçici açıkken de her zaman erişilebilir.
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  Text(UyumStrings.adEtiketi, style: yazi.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    key: const Key('kisi-ad-alani'),
                    controller: _ad,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: UyumStrings.adIpucu,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(UyumStrings.dogumEtiketi, style: yazi.titleMedium),
                  SizedBox(
                    height: OnboardingConfig.tarihSeciciYuksekligi,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: ref.read(kisiDogumProvider),
                      minimumDate: DateTime(OnboardingConfig.enEskiDogumYili),
                      maximumDate: DateTime.now(),
                      backgroundColor: AppColors.background,
                      onDateTimeChanged: (DateTime yeni) =>
                          ref.read(kisiDogumProvider.notifier).state = yeni,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(UyumStrings.rolEtiketi, style: yazi.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: <Widget>[
                      for (final KisiRolu r in KisiRolu.values)
                        ChoiceChip(
                          label: Text(r.etiket),
                          selected: r == rol,
                          onSelected: (_) =>
                              ref.read(kisiRolProvider.notifier).state = r,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    UyumStrings.rizaNotu,
                    style: yazi.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: FilledButton(
                onPressed: _kaydet,
                child: const Text(UyumStrings.kaydet),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
