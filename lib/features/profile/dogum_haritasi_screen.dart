import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/burc_metinleri.dart';
import '../../core/content/harita_okumasi.dart';
import '../../core/luck_engine/burc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/app_route.dart';
import '../legal/legal_texts.dart';
import '../premium/kilit_secenekleri.dart';
import '../premium/premium_providers.dart';
import 'dogum_bilgisi_duzenle.dart';
import 'kilitli_bolum_karti.dart';
import 'profile_config.dart';
import 'profile_providers.dart';

/// Kader Profili'ndeki "Büyük Üçlü" kartı: Güneş, Ay ve Yükselen.
///
/// Yükselen bilinmiyorsa "Yükselenini öğren" doğum bilgisi düzenleyicisini
/// açar; biliniyorsa kart harita ekranına götürür.
class BuyukUcluKarti extends ConsumerWidget {
  /// Varsayılan kurucu.
  const BuyukUcluKarti({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final HaritaOkumasi okuma = ref.watch(haritaOkumasiProvider);
    void haritayaGit() => unawaited(
      Navigator.of(
        context,
      ).push(fadeThroughRoute<void>(const DogumHaritasiScreen())),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: haritayaGit,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l.profilBuyukUcluBaslik, style: yazi.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.profilBuyukUcluAciklama,
                style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  for (final (String, String, Burc?) s
                      in <(String, String, Burc?)>[
                        (l.profilGunes, AppImages.madalyonGunes, okuma.gunes),
                        (l.profilAy, AppImages.madalyonAy, okuma.ay),
                        (
                          l.profilYukselen,
                          AppImages.madalyonYukselen,
                          okuma.yukselen,
                        ),
                      ])
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            s.$2,
                            width: ProfileConfig.ucluMadalyonBoyutu,
                            height: ProfileConfig.ucluMadalyonBoyutu,
                            excludeFromSemantics: true,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            s.$1,
                            style: yazi.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            s.$3?.etiket ?? ProfileConfig.bilinmeyenDeger,
                            style: yazi.titleMedium?.copyWith(
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: okuma.yukselen == null
                    ? FilledButton.tonal(
                        onPressed: () =>
                            unawaited(dogumBilgisiniDuzenle(context)),
                        child: Text(l.profilYukseleniniOgren),
                      )
                    : TextButton(
                        onPressed: haritayaGit,
                        child: Text(l.profilHaritaniOku),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Doğum haritası ekranı: büyük üçlü özeti, belirsizlik notları, Güneş,
/// Ay ve Yükselen yorumları (Yükselen premium; profil kilidini paylaşır).
class DogumHaritasiScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const DogumHaritasiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final HaritaOkumasi okuma = ref.watch(haritaOkumasiProvider);
    final bool kilitli = ref.watch(profilKilitliProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profilBuyukUcluBaslik),
        actions: <Widget>[
          IconButton(
            tooltip: l.profilDogumBilgisiBaslik,
            icon: const Icon(Icons.edit_calendar_outlined),
            onPressed: () => unawaited(dogumBilgisiniDuzenle(context)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            _HaritaBasligi(okuma: okuma),
            const SizedBox(height: AppSpacing.md),
            Text(
              okuma.ozet,
              style: yazi.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final String not in okuma.notlar)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.gold,
                    ),
                    title: Text(not, style: yazi.bodyMedium),
                    onTap: () => unawaited(dogumBilgisiniDuzenle(context)),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            KilitliBolumKarti(
              baslik: l.profilGunesBasligi(okuma.gunes.etiket),
              metin: BurcMetinleri.oz[okuma.gunes]!,
              kilitli: false,
              onKilidiAc: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            for (final HaritaBolumu b in okuma.bolumler) ...<Widget>[
              KilitliBolumKarti(
                baslik: b.baslik,
                metin: b.metin,
                kilitli: b.premium && kilitli,
                onKilidiAc: () => unawaited(
                  kilitSecenekleriniGoster(
                    context,
                    ref,
                    kilitAnahtari: KilitAnahtarlari.profil,
                    aciklama: l.profilHaritaKilitAciklamasi,
                  ),
                ),
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

/// Harita ekranının başlığı: Güneş, Ay ve Yükselen burçlarının
/// madalyonları; her birinin köşesinde gezegenin küçük madalyonu durur.
/// Yükselen bilinmiyorsa yerinde soluk bir boş madalyon görünür.
class _HaritaBasligi extends StatelessWidget {
  const _HaritaBasligi({required this.okuma});

  final HaritaOkumasi okuma;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (final (String, String, Burc?) s in <(String, String, Burc?)>[
          (l.profilGunes, AppImages.madalyonGunes, okuma.gunes),
          (l.profilAy, AppImages.madalyonAy, okuma.ay),
          (l.profilYukselen, AppImages.madalyonYukselen, okuma.yukselen),
        ])
          Column(
            children: <Widget>[
              SizedBox.square(
                dimension: ProfileConfig.haritaMadalyonBoyutu,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Opacity(
                      opacity: s.$3 == null
                          ? ProfileConfig.pasifDonemOpakligi
                          : 1,
                      child: Image.asset(
                        s.$3 == null
                            ? AppImages.sayiMadalyonu
                            : AppImages.burc(s.$3!.name),
                        width: ProfileConfig.haritaMadalyonBoyutu,
                        height: ProfileConfig.haritaMadalyonBoyutu,
                        excludeFromSemantics: true,
                      ),
                    ),
                    Positioned(
                      right: -AppSpacing.xs,
                      bottom: -AppSpacing.xs,
                      child: Image.asset(
                        s.$2,
                        width: ProfileConfig.haritaGezegenRozeti,
                        height: ProfileConfig.haritaGezegenRozeti,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                s.$1,
                style: yazi.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
