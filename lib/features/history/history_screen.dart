import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/history/gecmis_ozeti.dart';
import '../../core/storage/daily_record.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../daily_luck/tr_strings.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text(HistoryStrings.baslik)),
      body: SafeArea(
        child: kayitlar.isEmpty
            ? _bosDurum(context)
            : _icerik(context, ref, kayitlar, ozet),
      ),
    );
  }

  /// Hiç kayıt yokken kristal küre + davet metni.
  Widget _bosDurum(BuildContext context) {
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
              HistoryStrings.bosBaslik,
              style: yaziTemasi.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              HistoryStrings.bosMetin,
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
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _kanitKarti(context, ozet),
          const SizedBox(height: AppSpacing.md),
          _ozetKarti(context, ozet),
          const SizedBox(height: AppSpacing.lg),
          LuckHeatmap(kayitlar: kayitlar, bugun: ref.watch(bugunProvider)),
        ],
      ),
    );
  }

  /// Kanıt Döngüsü kartı: yeterli örnek varsa yüzde, yoksa davet.
  Widget _kanitKarti(BuildContext context, GecmisOzeti ozet) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final String govde = ozet.kanitYeterli
        ? HistoryStrings.kanitMetni(ozet.kanitOrnekSayisi, ozet.kanitYuzdesi!)
        : HistoryStrings.kanitYetersizMetni(
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
                  HistoryStrings.kanitBasligi,
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

  /// Özet kartı: kayıtlı gün, ortalama skor, en şanslı gün.
  Widget _ozetKarti(BuildContext context, GecmisOzeti ozet) {
    final String enSansli = ozet.enSansliGun == null
        ? '—'
        : '${TrStrings.tarihMetni(ozet.enSansliGun!)} (${ozet.enSansliSkor})';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: <Widget>[
            _ozetSatiri(
              context,
              HistoryStrings.toplamGunEtiketi,
              '${ozet.toplamGun}',
            ),
            const SizedBox(height: AppSpacing.sm),
            _ozetSatiri(
              context,
              HistoryStrings.ortalamaSkorEtiketi,
              '${ozet.ortalamaSkor}',
            ),
            const SizedBox(height: AppSpacing.sm),
            _ozetSatiri(
              context,
              HistoryStrings.enSansliGunEtiketi,
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
