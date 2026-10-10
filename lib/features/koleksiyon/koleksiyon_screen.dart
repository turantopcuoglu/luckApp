import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/koleksiyon_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/tarih_bicimi.dart';
import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/sahne_arka_plani.dart';
import '../../shared/widgets/sahne_config.dart';
import 'koleksiyon_config.dart';
import 'koleksiyon_katalogu.dart';
import 'koleksiyon_providers.dart';
import 'koleksiyon_strings.dart';
import 'widgets/koleksiyon_karti_gorseli.dart';

/// Koleksiyon ekranı (mockup `9635f67f` 2. ekran): sayaç, en son gelen
/// kart öne çıkarılmış, altında tüm kartların ızgarası (gelmemişler
/// kilitli). Karta dokununca detay açılır.
class KoleksiyonScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const KoleksiyonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final Map<String, KazanilanKart> kazanilan = ref.watch(koleksiyonProvider);
    const List<KoleksiyonKarti> katalog = KoleksiyonKatalogu.kartlar;
    final int sayi = katalog
        .where((KoleksiyonKarti k) => kazanilan.containsKey(k.id))
        .length;

    // Öne çıkan: en son gelen kart.
    KoleksiyonKarti? oneCikan;
    KazanilanKart? oneCikanKaydi;
    for (final KoleksiyonKarti k in katalog) {
      final KazanilanKart? kayit = kazanilan[k.id];
      if (kayit != null &&
          (oneCikanKaydi == null ||
              kayit.sonGun.isAfter(oneCikanKaydi.sonGun))) {
        oneCikan = k;
        oneCikanKaydi = kayit;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(KoleksiyonStrings.baslik),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Text(
                KoleksiyonStrings.sayac(sayi, katalog.length),
                style: yazi.bodyMedium?.copyWith(color: AppColors.goldAcik),
              ),
            ),
          ),
        ],
      ),
      body: SahneliZemin(
        gorsel: AppImages.sahneKapali,
        altKarartmaBaslangici: SahneConfig.yogunKarartmaBaslangici,
        altKarartmaSonu: SahneConfig.yogunKarartmaSonu,
        child: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: oneCikan == null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          child: Text(
                            KoleksiyonStrings.bosDurum,
                            style: yazi.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _OneCikanKart(kart: oneCikan, kayit: oneCikanKaydi!),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverGrid.count(
                  crossAxisCount: KoleksiyonConfig.izgaraSutunu,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: KoleksiyonConfig.hucreOrani,
                  children: <Widget>[
                    for (final KoleksiyonKarti k in katalog)
                      _IzgaraHucresi(kart: k, kayit: kazanilan[k.id]),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    KoleksiyonStrings.altNot,
                    style: yazi.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kart detayına geçiş (Hero etiketi kart kimliğinden).
void _detayaGit(BuildContext context, KoleksiyonKarti kart) => unawaited(
  Navigator.of(
    context,
  ).push(fadeThroughRoute<void>(KartDetayScreen(kart: kart))),
);

/// Büyük kartın genişliği: ekran genişliğinin [genislikOrani] katı, ama
/// kart yüksekliği ekran yüksekliğinin [yukseklikOrani] katını aşmaz
/// (yatay ekran / tablet).
double _kartGenisligi(
  BuildContext context,
  double genislikOrani,
  double yukseklikOrani,
) {
  final Size ekran = MediaQuery.sizeOf(context);
  return min(
    ekran.width * genislikOrani,
    ekran.height * yukseklikOrani * KoleksiyonConfig.kartOrani,
  );
}

/// [kart] için ortak Hero etiketi.
String _heroEtiketi(KoleksiyonKarti kart) => 'koleksiyon-${kart.id}';

/// En son gelen kart: büyük görsel, adı, nadir rozeti ve gün sayısı.
class _OneCikanKart extends StatelessWidget {
  const _OneCikanKart({required this.kart, required this.kayit});

  final KoleksiyonKarti kart;
  final KazanilanKart kayit;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => _detayaGit(context, kart),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: _kartGenisligi(
              context,
              KoleksiyonConfig.oneCikanOrani,
              KoleksiyonConfig.oneCikanYukseklikOrani,
            ),
            // Hero yok: aynı kart ızgarada da var, etiket orada kullanılır.
            child: KoleksiyonKartiGorseli(
              kart: kart,
              kazanildi: true,
              nadir: kayit.nadir,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(child: Text(kart.ad, style: yazi.headlineSmall)),
              if (kayit.nadir) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                const NadirRozeti(),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            KoleksiyonStrings.gunSayisi(kayit.gunSayisi),
            style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Izgaradaki tek kart: görsel + ad.
class _IzgaraHucresi extends StatelessWidget {
  const _IzgaraHucresi({required this.kart, required this.kayit});

  final KoleksiyonKarti kart;
  final KazanilanKart? kayit;

  @override
  Widget build(BuildContext context) {
    final bool kazanildi = kayit != null;
    final Widget gorsel = KoleksiyonKartiGorseli(
      kart: kart,
      kazanildi: kazanildi,
      nadir: kayit?.nadir ?? false,
    );
    return Semantics(
      button: true,
      label: kart.ad,
      child: GestureDetector(
        onTap: () => _detayaGit(context, kart),
        child: Column(
          children: <Widget>[
            Expanded(
              child: kazanildi
                  ? Hero(tag: _heroEtiketi(kart), child: gorsel)
                  : gorsel,
            ),
            const SizedBox(height: AppSpacing.xs),
            ExcludeSemantics(
              child: Text(
                kart.ad,
                maxLines: KoleksiyonConfig.adSatirSayisi,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: kazanildi
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Altın "Nadir" rozeti.
class NadirRozeti extends StatelessWidget {
  /// Varsayılan kurucu.
  const NadirRozeti({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.gold),
        color: AppColors.background.withValues(
          alpha: SahneConfig.camZeminOpakligi,
        ),
      ),
      child: Text(
        KoleksiyonStrings.nadir,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.goldAcik),
      ),
    );
  }
}

/// Kart detayı: büyük kart (Hero), adı, sözü ve kazanılma bilgisi; kart
/// henüz gelmediyse kilitli görünüm ve açıklama.
class KartDetayScreen extends ConsumerWidget {
  /// [kart] için detay ekranı.
  const KartDetayScreen({required this.kart, super.key});

  /// Gösterilen kart.
  final KoleksiyonKarti kart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final KazanilanKart? kayit = ref.watch(koleksiyonProvider)[kart.id];
    final bool kazanildi = kayit != null;
    final Widget gorsel = KoleksiyonKartiGorseli(
      kart: kart,
      kazanildi: kazanildi,
      nadir: kayit?.nadir ?? false,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: SahneliZemin(
        gorsel: AppImages.sahneKapali,
        altKarartmaBaslangici: SahneConfig.yogunKarartmaBaslangici,
        altKarartmaSonu: SahneConfig.yogunKarartmaSonu,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: _kartGenisligi(
                    context,
                    KoleksiyonConfig.detayOrani,
                    KoleksiyonConfig.detayYukseklikOrani,
                  ),
                  child: kazanildi
                      ? Hero(tag: _heroEtiketi(kart), child: gorsel)
                      : gorsel,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      kart.ad,
                      style: yazi.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (kayit?.nadir ?? false) ...<Widget>[
                    const SizedBox(width: AppSpacing.sm),
                    const NadirRozeti(),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                kazanildi ? kart.soz : KoleksiyonStrings.kilitliAciklama,
                style: yazi.bodyLarge?.copyWith(
                  color: kazanildi
                      ? AppColors.goldAcik
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (kayit != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text(
                  KoleksiyonStrings.ilkGun(
                    kisaTarihMetni(l, kayit.ilkGun),
                  ),
                  style: yazi.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  KoleksiyonStrings.gunSayisi(kayit.gunSayisi),
                  style: yazi.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
