import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'comment_builder.dart';
import 'daily_luck_config.dart';
import 'daily_luck_providers.dart';
import 'tr_strings.dart';
import 'widgets/category_card.dart';
import 'widgets/comment_card.dart';
import 'widgets/score_ring.dart';

/// Ana ekran: tarih + selamlama, skor halkası, yorum kartı ve
/// kategori mini kartları (plan Session 3).
///
/// Bilinçli olarak animasyonsuzdur; animasyon katmanı Session 5'te
/// mevcut widget'lar sarmalanarak eklenecek.
class DailyLuckScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const DailyLuckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LuckResult> sonuc = ref.watch(gununSansiProvider);
    return Scaffold(
      body: SafeArea(
        child: sonuc.when(
          data: (LuckResult veri) => _Icerik(sonuc: veri),
          loading: () => const _Yukleniyor(),
          error: (Object hata, StackTrace iz) => const _Hata(),
        ),
      ),
    );
  }
}

/// Başarılı durumda ekranın tam içeriği.
class _Icerik extends ConsumerWidget {
  const _Icerik({required this.sonuc});

  final LuckResult sonuc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final DateTime bugun = ref.watch(bugunProvider);
    final String isim = ref.watch(aktifProfilProvider).isim;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Üst blok: tarih ve selamlama.
          Text(
            TrStrings.tarihMetni(bugun),
            style: yaziTemasi.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(TrStrings.selamlama(isim), style: yaziTemasi.headlineMedium),
          const SizedBox(height: AppSpacing.xl),

          // Orta blok: dairesel skor göstergesi.
          Center(child: ScoreRing(skor: sonuc.genelSkor)),
          const SizedBox(height: AppSpacing.xl),

          // Yorum kartı: skor aralığı + modifiyer şablonları.
          CommentCard(metin: gunYorumu(sonuc)),
          const SizedBox(height: AppSpacing.lg),

          // Alt blok: 5 kategorinin yatay kaydırılabilir mini kartları.
          SizedBox(
            height: DailyLuckConfig.kategoriListeYuksekligi,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: LuckCategory.values.length,
              separatorBuilder: (BuildContext context, int i) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (BuildContext context, int i) {
                final LuckCategory kategori = LuckCategory.values[i];
                return CategoryCard(
                  kategori: kategori,
                  skor: sonuc.kategoriSkorlari[kategori]!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Skor üretilirken gösterilen basit yükleme durumu.
class _Yukleniyor extends StatelessWidget {
  const _Yukleniyor();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(color: AppColors.gold),
          const SizedBox(height: AppSpacing.md),
          Text(
            TrStrings.yukleniyor,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Beklenmeyen hata durumu.
class _Hata extends StatelessWidget {
  const _Hata();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          TrStrings.hataMetni,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
