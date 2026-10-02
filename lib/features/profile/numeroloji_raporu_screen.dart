import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/rapor_okumasi.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../legal/legal_texts.dart';
import '../premium/premium_providers.dart';
import '../premium/rapor_kilidi.dart';
import 'kilitli_bolum_karti.dart';
import 'profile_config.dart';
import 'profile_providers.dart';
import 'profile_strings.dart';
import 'tam_ad_duzenle.dart';

/// Derin numeroloji raporu: hayatın dört dönemi, karmik sayılar ve isim
/// analizleri.
///
/// Zaman çizelgesi ve şu anki dönemin zirvesi ücretsizdir; diğer bölümler
/// Premium ya da tek seferlik rapor satın alımıyla açılır (reklamla
/// açılmaz, bkz. `raporAcikProvider`).
class NumerolojiRaporuScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const NumerolojiRaporuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final UserProfile profil = ref.watch(aktifProfilProvider);
    final RaporOkumasi okuma = ref.watch(raporOkumasiProvider);
    final bool kilitli = ref.watch(raporKilitliProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(ProfileStrings.raporBaslik)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            Text(
              ProfileStrings.raporAciklama,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            _ZamanCizelgesi(donemler: okuma.zamanCizelgesi),
            if (profil.tamAd == null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.gold,
                  ),
                  title: const Text(ProfileStrings.raporTamAdEksikBaslik),
                  subtitle: const Text(ProfileStrings.raporTamAdEksikAciklama),
                  onTap: () => unawaited(tamAdiDuzenle(context, ref)),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            for (final RaporBolumu bolum in okuma.bolumler) ...<Widget>[
              KilitliBolumKarti(
                baslik: bolum.baslik,
                metin: bolum.metin,
                kilitli: bolum.premium && kilitli,
                onKilidiAc: () => unawaited(raporKilidiniGoster(context)),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              YasalMetinler.kisaNot,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dört dönemin dikey zaman çizelgesi; aktif dönem vurgulanır.
class _ZamanCizelgesi extends StatelessWidget {
  const _ZamanCizelgesi({required this.donemler});

  final List<DonemOzeti> donemler;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(ProfileStrings.zamanCizelgesiBaslik, style: yazi.titleMedium),
            const SizedBox(height: AppSpacing.md),
            for (int i = 0; i < donemler.length; i++)
              _DonemSatiri(ozet: donemler[i], sonMu: i == donemler.length - 1),
          ],
        ),
      ),
    );
  }
}

/// Zaman çizelgesinin tek satırı: daire + çizgi solda, metin sağda.
class _DonemSatiri extends StatelessWidget {
  const _DonemSatiri({required this.ozet, required this.sonMu});

  final DonemOzeti ozet;
  final bool sonMu;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final bool aktif = ozet.aktif;
    return Opacity(
      opacity: aktif ? 1 : ProfileConfig.pasifDonemOpakligi,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  width: ProfileConfig.donemDairesiCapi,
                  height: ProfileConfig.donemDairesiCapi,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: aktif ? AppColors.gold : AppColors.surface,
                    border: Border.all(color: AppColors.gold),
                  ),
                  child: Text(
                    '${ozet.donem.zirve}',
                    style: yazi.titleMedium?.copyWith(
                      color: aktif ? AppColors.background : AppColors.gold,
                    ),
                  ),
                ),
                if (!sonMu)
                  Expanded(
                    child: Container(
                      width: ProfileConfig.donemCizgiKalinligi,
                      color: AppColors.gold,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: sonMu ? 0 : AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${ozet.yasAraligi} · '
                            '${ProfileStrings.zirveEtiketi(ozet.donem.zirve)}',
                            style: yazi.labelLarge?.copyWith(
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        if (aktif)
                          Chip(
                            label: const Text(ProfileStrings.suAn),
                            visualDensity: VisualDensity.compact,
                            labelStyle: yazi.labelSmall,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(ozet.zirveOzeti, style: yazi.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ozet.zorlukOzeti,
                      style: yazi.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
