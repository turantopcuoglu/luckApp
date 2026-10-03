import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/koleksiyon_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../shared/widgets/app_route.dart';
import '../../../shared/widgets/cam_panel.dart';
import '../koleksiyon_config.dart';
import '../koleksiyon_katalogu.dart';
import '../koleksiyon_providers.dart';
import '../koleksiyon_screen.dart';
import '../koleksiyon_strings.dart';
import 'koleksiyon_karti_gorseli.dart';

/// Koleksiyon ekranını açar.
void _koleksiyonaGit(BuildContext context) => unawaited(
  Navigator.of(
    context,
  ).push(fadeThroughRoute<void>(const KoleksiyonScreen())),
);

/// Ana ekranda, okumanın altında "Bugünün kartı" paneli: küçük kart,
/// adı ve koleksiyona eklendiği bilgisi. Dokununca koleksiyon açılır.
///
/// Kart, ana ekrandaki kader kartı açılınca koleksiyona işlenir
/// ([bugununKartiniKazan]); panel kazanılmış durumu gösterir.
class GununKartiPaneli extends ConsumerWidget {
  /// Varsayılan kurucu.
  const GununKartiPaneli({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final GununKarti gunun = ref.watch(gununKartiProvider);
    final KazanilanKart? kayit = ref.watch(koleksiyonProvider)[gunun.kart.id];
    return CamPanel(
      onTap: () => _koleksiyonaGit(context),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: KoleksiyonConfig.panelKartGenisligi,
            child: KoleksiyonKartiGorseli(
              kart: gunun.kart,
              kazanildi: true,
              nadir: gunun.nadir || (kayit?.nadir ?? false),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  KoleksiyonStrings.bugununKarti,
                  style: yazi.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  gunun.kart.ad,
                  style: yazi.titleMedium?.copyWith(color: AppColors.goldAcik),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  gunun.nadir
                      ? KoleksiyonStrings.nadirEklendi
                      : KoleksiyonStrings.eklendi,
                  style: yazi.bodySmall?.copyWith(
                    color: gunun.nadir
                        ? AppColors.gold
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
        ],
      ),
    );
  }
}

/// Profil ekranındaki koleksiyon özeti: sayaç, son gelen birkaç kart ve
/// koleksiyona geçiş.
class KoleksiyonOzetKarti extends ConsumerWidget {
  /// Varsayılan kurucu.
  const KoleksiyonOzetKarti({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final Map<String, KazanilanKart> kazanilan = ref.watch(koleksiyonProvider);
    const List<KoleksiyonKarti> katalog = KoleksiyonKatalogu.kartlar;
    // Son gelenler önce.
    final List<KoleksiyonKarti> sonlar =
        katalog.where((KoleksiyonKarti k) => kazanilan.containsKey(k.id)).toList()
          ..sort(
            (KoleksiyonKarti a, KoleksiyonKarti b) =>
                kazanilan[b.id]!.sonGun.compareTo(kazanilan[a.id]!.sonGun),
          );
    return CamPanel(
      onTap: () => _koleksiyonaGit(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(KoleksiyonStrings.baslik, style: yazi.titleMedium),
              ),
              Text(
                KoleksiyonStrings.sayac(sonlar.length, katalog.length),
                style: yazi.bodySmall?.copyWith(color: AppColors.goldAcik),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            KoleksiyonStrings.ozetAciklama,
            style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          if (sonlar.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                for (final KoleksiyonKarti k
                    in sonlar.take(KoleksiyonConfig.ozetKartSayisi)) ...<Widget>[
                  SizedBox(
                    width: KoleksiyonConfig.ozetKartGenisligi,
                    child: KoleksiyonKartiGorseli(
                      kart: k,
                      kazanildi: true,
                      nadir: kazanilan[k.id]!.nadir,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
