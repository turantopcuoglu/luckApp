import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/burc_metinleri.dart';
import '../../core/content/harita_okumasi.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_route.dart';
import '../legal/legal_texts.dart';
import '../premium/kilit_secenekleri.dart';
import '../premium/premium_providers.dart';
import 'dogum_bilgisi_duzenle.dart';
import 'kilitli_bolum_karti.dart';
import 'profile_providers.dart';
import 'profile_strings.dart';

/// Kader Profili'ndeki "Büyük Üçlü" kartı: Güneş, Ay ve Yükselen.
///
/// Yükselen bilinmiyorsa "Yükselenini öğren" doğum bilgisi düzenleyicisini
/// açar; biliniyorsa kart harita ekranına götürür.
class BuyukUcluKarti extends ConsumerWidget {
  /// Varsayılan kurucu.
  const BuyukUcluKarti({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Text(ProfileStrings.buyukUcluBaslik, style: yazi.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                ProfileStrings.buyukUcluAciklama,
                style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  for (final (String, String?) s in <(String, String?)>[
                    (ProfileStrings.gunes, okuma.gunes.etiket),
                    (ProfileStrings.ay, okuma.ay.etiket),
                    (ProfileStrings.yukselen, okuma.yukselen?.etiket),
                  ])
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            s.$1,
                            style: yazi.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            s.$2 ?? ProfileStrings.bilinmiyor,
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
                        child: const Text(ProfileStrings.yukseleniniOgren),
                      )
                    : TextButton(
                        onPressed: haritayaGit,
                        child: const Text(ProfileStrings.haritaniOku),
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
    final TextTheme yazi = Theme.of(context).textTheme;
    final HaritaOkumasi okuma = ref.watch(haritaOkumasiProvider);
    final bool kilitli = ref.watch(profilKilitliProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ProfileStrings.buyukUcluBaslik),
        actions: <Widget>[
          IconButton(
            tooltip: ProfileStrings.dogumBilgisiBaslik,
            icon: const Icon(Icons.edit_calendar_outlined),
            onPressed: () => unawaited(dogumBilgisiniDuzenle(context)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            Text(okuma.ozet, style: yazi.titleLarge),
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
              baslik: ProfileStrings.gunesBasligi(okuma.gunes.etiket),
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
                    aciklama: ProfileStrings.haritaKilitAciklamasi,
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
