import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/rapor_okumasi.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_images.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../legal/legal_texts.dart';
import '../premium/premium_providers.dart';
import '../premium/rapor_kilidi.dart';
import 'kilitli_bolum_karti.dart';
import 'profile_config.dart';
import 'profile_providers.dart';
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
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final UserProfile profil = ref.watch(aktifProfilProvider);
    final RaporOkumasi okuma = ref.watch(raporOkumasiProvider);
    final bool kilitli = ref.watch(raporKilitliProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.profilRaporBaslik)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            Center(
              child: Image.asset(
                AppImages.raporKitap,
                height: ProfileConfig.raporKitapBuyuk,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l.profilRaporAciklama,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
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
                  title: Text(l.profilRaporTamAdEksikBaslik),
                  subtitle: Text(l.profilRaporTamAdEksikAciklama),
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
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l.profilZamanCizelgesiBaslik, style: yazi.titleMedium),
            const SizedBox(height: AppSpacing.md),
            for (int i = 0; i < donemler.length; i++)
              _DonemSatiri(
                ozet: donemler[i],
                sonMu: i == donemler.length - 1,
                // Dört dönem ayın dört ana evresiyle simgelenir: yeni ay,
                // ilk dördün, dolunay, son dördün.
                ayEvresi: (i * ProfileConfig.donemEvreAdimi) %
                    ProfileConfig.ayEvresiSayisi,
              ),
          ],
        ),
      ),
    );
  }
}

/// Zaman çizelgesinin tek satırı: daire + çizgi solda, metin sağda.
class _DonemSatiri extends StatelessWidget {
  const _DonemSatiri({
    required this.ozet,
    required this.sonMu,
    required this.ayEvresi,
  });

  final DonemOzeti ozet;
  final bool sonMu;

  /// Dönemi simgeleyen ay evresinin indeksi ([AyEvresi.index]).
  final int ayEvresi;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
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
                // Ay evresi simgesi; zirve sayısı üstüne yazılır.
                SizedBox.square(
                  dimension: ProfileConfig.donemAyBoyutu,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Image.asset(
                        AppImages.ayEvresi(ayEvresi),
                        excludeFromSemantics: true,
                      ),
                      Text(
                        '${ozet.donem.zirve}',
                        style: yazi.titleMedium?.copyWith(
                          color: aktif ? AppColors.gold : AppColors.goldAcik,
                          fontWeight: FontWeight.w700,
                          shadows: const <Shadow>[
                            Shadow(
                              color: AppColors.background,
                              blurRadius: AppSpacing.sm,
                            ),
                          ],
                        ),
                      ),
                    ],
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
                            '${l.profilZirve(ozet.donem.zirve)}',
                            style: yazi.labelLarge?.copyWith(
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        if (aktif)
                          Chip(
                            label: Text(l.profilSuAn),
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
