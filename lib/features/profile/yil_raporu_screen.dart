import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/yillik_rapor.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../legal/legal_texts.dart';
import '../premium/premium_providers.dart';
import '../premium/rapor_kilidi.dart';
import 'kilitli_bolum_karti.dart';
import 'profile_config.dart';
import 'profile_providers.dart';
import 'yil_afisi.dart';

/// Kişisel Yıl Raporu: bir takvim yılının kişiye özel rehberi.
///
/// Sıra: kişisel yıl başlığı → yılın teması (ücretsiz) → rehber bölümleri
/// → ay ay 12 kart (Ocak ücretsiz) → yılın sorusu. Kilitli kısımlar
/// Premium ya da o yılın tek seferlik raporuyla açılır (reklamla açılmaz).
class YilRaporuScreen extends ConsumerWidget {
  /// [yil] için ekran oluşturur.
  const YilRaporuScreen({super.key, required this.yil});

  /// Raporun takvim yılı.
  final int yil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final YillikRaporOkumasi okuma = ref.watch(yillikRaporProvider(yil));
    final bool kilitli = !ref.watch(yilRaporuAcikProvider(yil));
    void kilidiAc() => unawaited(yilRaporuKilidiniGoster(context, yil));

    final List<YillikBolum> rehber = <YillikBolum>[
      for (final YillikBolum b in okuma.bolumler)
        if (b.tur != YillikBolumTuru.niyet) b,
    ];
    final List<YillikBolum> niyet = <YillikBolum>[
      for (final YillikBolum b in okuma.bolumler)
        if (b.tur == YillikBolumTuru.niyet) b,
    ];

    Widget bolumKarti(YillikBolum b) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: KilitliBolumKarti(
        baslik: b.baslik,
        metin: b.metin,
        kilitli: b.premium && kilitli,
        onKilidiAc: kilidiAc,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.profilYilRaporuBaslik(yil))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            _YilBasligi(okuma: okuma),
            const SizedBox(height: AppSpacing.lg),
            ...rehber.map(bolumKarti),
            const SizedBox(height: AppSpacing.sm),
            Text(l.profilAyAyBaslik(yil), style: yazi.titleLarge),
            const SizedBox(height: AppSpacing.md),
            for (final YillikAy ay in okuma.aylar)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _AyKarti(
                  ay: ay,
                  kilitli: ay.premium && kilitli,
                  onKilidiAc: kilidiAc,
                ),
              ),
            ...niyet.map(bolumKarti),
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

/// Yıl afişi: büyük kişisel yıl sayısı ve yılın lakabı, sağda yılın sahnesi.
class _YilBasligi extends StatelessWidget {
  const _YilBasligi({required this.okuma});

  final YillikRaporOkumasi okuma;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    return YilAfisi(
      kisiselYil: okuma.kisiselYil,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l.profilKisiselYilEtiketi,
            style: yazi.bodySmall?.copyWith(color: AppColors.goldAcik),
          ),
          Text(
            '${okuma.kisiselYil}',
            style: yazi.displayMedium?.copyWith(
              color: AppColors.gold,
              fontSize: ProfileConfig.kisiselYilSayiBoyutu,
            ),
          ),
          Text(okuma.yilLakabi, style: yazi.headlineSmall),
        ],
      ),
    );
  }
}

/// Tek bir ayın kartı: başlık + akış çipi + metin (kilitliyse bulanık).
class _AyKarti extends StatelessWidget {
  const _AyKarti({
    required this.ay,
    required this.kilitli,
    required this.onKilidiAc,
  });

  final YillikAy ay;
  final bool kilitli;
  final VoidCallback onKilidiAc;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final (String, Color)? cip = switch (ay.akis) {
      AyAkisi.akis => (l.profilAkisCipi, AppColors.gold),
      AyAkisi.zorlu => (l.profilZorluCipi, AppColors.purple),
      AyAkisi.dengeli => null,
    };
    return KilitliBolumKarti(
      baslik: ay.baslik,
      metin: ay.metin,
      kilitli: kilitli,
      onKilidiAc: onKilidiAc,
      // Akış çipi kilitliyken de görünür: hangi ayların öne çıktığını
      // görmek, raporun tamamını açma isteğini artırır.
      etiket: cip == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs / 2,
              ),
              decoration: BoxDecoration(
                color: cip.$2.withValues(alpha: ProfileConfig.ayCipiOpakligi),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                cip.$1,
                style: yazi.labelSmall?.copyWith(color: cip.$2),
              ),
            ),
    );
  }
}
