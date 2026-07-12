import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/history/aylik_ozet.dart';
import '../../core/history/gecmis_ozeti.dart';
import '../../core/localization/app_dil.dart';
import '../../core/storage/daily_record.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../daily_luck/tr_strings.dart';
import '../share/recap_strings.dart';
import '../share/share_service.dart';
import 'history_config.dart';
import 'history_providers.dart';
import 'history_strings.dart';
import 'widgets/luck_heatmap.dart';

/// Geçmiş ekranı: şans heatmap'i + "Kanıt Döngüsü" (Phase 2).
///
/// Akşam feedback'i ile günlük skorları görselleştirir; kullanıcının
/// tahmin ↔ his örtüşmesini kendi verisiyle gösterir.
class HistoryScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<DailyRecord> kayitlar = ref.watch(tumKayitlarProvider);
    final GecmisOzeti ozet = ref.watch(gecmisOzetiProvider);
    final AppDil dil = ref.watch(dilProvider);

    return Scaffold(
      appBar: AppBar(title: Text(HistoryStrings.baslik(dil))),
      body: SafeArea(
        child: kayitlar.isEmpty
            ? _bosDurum(context, dil)
            : _icerik(context, ref, kayitlar, ozet, dil),
      ),
    );
  }

  /// Hiç kayıt yokken kristal küre + davet metni.
  Widget _bosDurum(BuildContext context, AppDil dil) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppIllustrations.kristalKure(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              HistoryStrings.bosBaslik(dil),
              style: yaziTemasi.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              HistoryStrings.bosMetin(dil),
              style: yaziTemasi.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Kanıt kartı + özet kartı + heatmap.
  Widget _icerik(
    BuildContext context,
    WidgetRef ref,
    List<DailyRecord> kayitlar,
    GecmisOzeti ozet,
    AppDil dil,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _kanitKarti(context, ozet, dil),
          const SizedBox(height: AppSpacing.md),
          _ozetKarti(context, ozet, dil),
          const SizedBox(height: AppSpacing.md),
          _ayRaporuKarti(context, ref, dil),
          const SizedBox(height: AppSpacing.lg),
          LuckHeatmap(
            kayitlar: kayitlar,
            bugun: ref.watch(bugunProvider),
            dil: dil,
          ),
        ],
      ),
    );
  }

  /// Kanıt Döngüsü kartı: yeterli örnek varsa yüzde, yoksa davet.
  Widget _kanitKarti(BuildContext context, GecmisOzeti ozet, AppDil dil) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final String govde = ozet.kanitYeterli
        ? HistoryStrings.kanitMetni(
            dil,
            ozet.kanitOrnekSayisi,
            ozet.kanitYuzdesi!,
          )
        : HistoryStrings.kanitYetersizMetni(
            dil,
            HistoryConfig.enAzKanitGunu,
            ozet.kanitOrnekSayisi,
          );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.insights_rounded, color: AppColors.gold),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  HistoryStrings.kanitBasligi(dil),
                  style: yaziTemasi.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(govde, style: yaziTemasi.bodyMedium),
          ],
        ),
      ),
    );
  }

  /// Bu ayın Şans Raporu kartı + paylaş butonu.
  ///
  /// Bu ay hiç kayıt yoksa gösterilmez (boş kart yerine gizlenir).
  Widget _ayRaporuKarti(BuildContext context, WidgetRef ref, AppDil dil) {
    final AylikOzet ozet = ref.watch(buAyinOzetiProvider);
    if (ozet.bosMu) {
      return const SizedBox.shrink();
    }
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.auto_awesome_rounded, color: AppColors.gold),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  RecapStrings.bolumBasligi(dil),
                  style: yaziTemasi.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              RecapStrings.kartOzeti(
                dil,
                TrStrings.ayAdlari(dil)[ozet.ay - 1],
                ozet.yil,
                ozet.gunSayisi,
                ozet.ortalamaSkor,
              ),
              style: yaziTemasi.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => unawaited(
                  ref.read(shareServiceProvider).aylikOzetPaylas(ozet, dil),
                ),
                icon: const Icon(Icons.ios_share, color: AppColors.gold),
                label: Text(
                  RecapStrings.paylasButonu(dil),
                  style: yaziTemasi.titleSmall?.copyWith(color: AppColors.gold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Özet kartı: kayıtlı gün, ortalama skor, en şanslı gün.
  Widget _ozetKarti(BuildContext context, GecmisOzeti ozet, AppDil dil) {
    final String enSansli = ozet.enSansliGun == null
        ? '—'
        : '${TrStrings.tarihMetni(dil, ozet.enSansliGun!)} '
              '(${ozet.enSansliSkor})';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: <Widget>[
            _ozetSatiri(
              context,
              HistoryStrings.toplamGunEtiketi(dil),
              '${ozet.toplamGun}',
            ),
            const SizedBox(height: AppSpacing.sm),
            _ozetSatiri(
              context,
              HistoryStrings.ortalamaSkorEtiketi(dil),
              '${ozet.ortalamaSkor}',
            ),
            const SizedBox(height: AppSpacing.sm),
            _ozetSatiri(
              context,
              HistoryStrings.enSansliGunEtiketi(dil),
              enSansli,
            ),
          ],
        ),
      ),
    );
  }

  /// Tek özet satırı: solda etiket, sağda değer.
  Widget _ozetSatiri(BuildContext context, String etiket, String deger) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            etiket,
            style: yaziTemasi.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          deger,
          style: yaziTemasi.titleSmall?.copyWith(color: AppColors.gold),
        ),
      ],
    );
  }
}
