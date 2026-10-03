import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/fortune_composer.dart' as composer;
import '../../core/content/gunluk_okuma.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/hata_gorunumu.dart';
import '../../shared/widgets/sahne_arka_plani.dart';
import '../../shared/widgets/sahne_config.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../daily_luck/tr_strings.dart';
import '../daily_luck/widgets/category_card.dart';
import '../daily_luck/widgets/score_ring.dart';
import '../legal/legal_texts.dart';
import 'categories_config.dart';
import 'categories_strings.dart';

/// Kategori detay sayfası: kategori skoru, kişiye özel paragraf (açılış +
/// burç elementi + ilişki durumu + tavsiye), şanslı saatli eylem önerisi
/// ve düşük günlerde dikkat notu.
class CategoryDetailScreen extends ConsumerWidget {
  /// Detayı gösterilecek [kategori] ile sayfa oluşturur.
  const CategoryDetailScreen({required this.kategori, super.key});

  /// Gösterilen kategori.
  final LuckCategory kategori;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final AsyncValue<LuckResult> sonuc = ref.watch(gununSansiProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcons.kategori(
              kategori,
              boyut: CategoriesConfig.detayIkonBoyutu,
              renk: kategoriRengi(kategori),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(kategori.etiket),
          ],
        ),
      ),
      body: SahneliZemin(
        gorsel: AppImages.sahneKapali,
        altKarartmaBaslangici: SahneConfig.yogunKarartmaBaslangici,
        altKarartmaSonu: SahneConfig.yogunKarartmaSonu,
        child: SafeArea(
          child: sonuc.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
            error: (Object hata, StackTrace iz) =>
                const HataGorunumu(metin: TrStrings.hataMetni),
            data: (LuckResult veri) {
              // Okuma, saklanan sonuç + profil + bağımsız içerik tohumundan
              // deterministik seçilir.
              final KategoriOkumasi okuma = composer.kategoriOkumasi(
                motor: ref.watch(luckEngineProvider),
                okuyucu: ref.watch(aktifProfilProvider).okuyucu,
                sonuc: veri,
                kategori: kategori,
              );
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: ScoreRing(
                      skor: okuma.skor,
                      boyut: CategoriesConfig.detayHalkaCapi,
                      kalinlik: CategoriesConfig.detayHalkaKalinligi,
                      etiket: kategori.etiket.toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Orijinal tek yorum kartı: paragraf ve eylem önerisi.
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        '${okuma.paragraf}\n\n${okuma.eylem}',
                        style: yaziTemasi.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.schedule_rounded,
                            color: AppColors.purple,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              CategoriesStrings.sansliSaatBaslik,
                              style: yaziTemasi.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            okuma.sansliSaat.etiket,
                            style: yaziTemasi.titleMedium?.copyWith(
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    YasalMetinler.kisaNot,
                    style: yaziTemasi.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
