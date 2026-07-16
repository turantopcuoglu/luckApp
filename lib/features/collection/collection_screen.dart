import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/fortune_composer.dart';
import '../../core/content/gunun_icerigi.dart';
import '../../core/history/history_analiz_config.dart';
import '../../core/localization/app_dil.dart';
import '../../core/storage/daily_record.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../daily_luck/tr_strings.dart';
import '../daily_luck/widgets/comment_card.dart';
import '../daily_luck/widgets/lucky_row.dart';
import '../daily_luck/widgets/score_ring.dart';
import '../history/history_providers.dart';
import 'collection_config.dart';
import 'collection_strings.dart';
import 'widgets/kart_minik.dart';

/// Kader Kartı Koleksiyonu ekranı: geçmiş günlük kartların grid'i.
///
/// Her gün bir minik kart; nadir "Altın Gün"ler (skor ≥ eşik) altın
/// kenar + 🌟 ile öne çıkar. Karta dokununca o günün yorumu
/// deterministik yeniden üretilip alttan açılan sayfada gösterilir
/// (kural 8: aynı gün her zaman aynı içerik). Yeni motor/analiz yok;
/// mevcut altyapı yeniden kullanılır.
class CollectionScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // En yeniden eskiye: kutu artan sıralı olduğundan ters çevrilir.
    final List<DailyRecord> kayitlar = ref
        .watch(tumKayitlarProvider)
        .reversed
        .toList();
    final AppDil dil = ref.watch(dilProvider);

    return Scaffold(
      appBar: AppBar(title: Text(CollectionStrings.baslik(dil))),
      body: SafeArea(
        child: kayitlar.isEmpty
            ? _bosDurum(context, dil)
            : _grid(context, ref, kayitlar, dil),
      ),
    );
  }

  /// Hiç kayıt yokken kristal küre + davet metni (HistoryScreen deseni).
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
              CollectionStrings.bosBaslik(dil),
              style: yaziTemasi.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              CollectionStrings.bosMetin(dil),
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

  /// Özet başlığı + kart grid'i.
  Widget _grid(
    BuildContext context,
    WidgetRef ref,
    List<DailyRecord> kayitlar,
    AppDil dil,
  ) {
    final int altinSayisi = kayitlar
        .where(
          (DailyRecord k) =>
              k.sonuc.genelSkor >= HistoryAnalizConfig.altinGunEsigi,
        )
        .length;
    final TextTheme yaziTemasi = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            CollectionStrings.ozet(dil, kayitlar.length, altinSayisi),
            style: yaziTemasi.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: CollectionConfig.sutunSayisi,
              childAspectRatio: CollectionConfig.kartOrani,
              crossAxisSpacing: CollectionConfig.kartAraligi,
              mainAxisSpacing: CollectionConfig.kartAraligi,
            ),
            itemCount: kayitlar.length,
            itemBuilder: (BuildContext context, int i) => KartMinik(
              kayit: kayitlar[i],
              dil: dil,
              onTap: () => _kartDetay(context, ref, kayitlar[i], dil),
            ),
          ),
        ),
      ],
    );
  }

  /// Karta dokunulunca o günün yorumunu deterministik yeniden üretip
  /// alttan açılan sayfada (bottom sheet) gösterir.
  void _kartDetay(
    BuildContext context,
    WidgetRef ref,
    DailyRecord kayit,
    AppDil dil,
  ) {
    // İçerik saklanmaz; kayıtlı sonuç + deterministik tohumdan aynı
    // şekilde yeniden türetilir (kural 8).
    final GununIcerigi icerik = gununIcerigi(
      motor: ref.read(luckEngineProvider),
      kullanici: ref.read(aktifProfilProvider).seed,
      sonuc: kayit.sonuc,
      dil: dil,
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final TextTheme yaziTemasi = Theme.of(sheetContext).textTheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(CollectionConfig.detayDolgu),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  CollectionStrings.detayBaslik(dil),
                  style: yaziTemasi.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  TrStrings.tarihMetni(dil, kayit.gun),
                  style: yaziTemasi.titleMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: ScoreRing(skor: kayit.sonuc.genelSkor, dil: dil),
                ),
                const SizedBox(height: AppSpacing.lg),
                CommentCard(metin: icerik.yorum),
                const SizedBox(height: AppSpacing.md),
                SansOgeleriKarti(icerik: icerik, dil: dil),
              ],
            ),
          ),
        );
      },
    );
  }
}
