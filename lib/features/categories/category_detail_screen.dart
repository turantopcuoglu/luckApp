import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/fortune_composer.dart' as composer;
import '../../core/localization/app_dil.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../daily_luck/tr_strings.dart';
import '../daily_luck/widgets/score_ring.dart';
import 'categories_config.dart';
import 'categories_strings.dart';
import 'entitlement.dart';
import 'paywall_screen.dart';

/// Kategori detay sayfası: kategori skoru, kategoriye özel 2 cümle
/// yorum ve deterministik "şanslı saat aralığı" (plan Session 9,
/// madde 1).
class CategoryDetailScreen extends ConsumerWidget {
  /// Detayı gösterilecek [kategori] ile sayfa oluşturur.
  const CategoryDetailScreen({required this.kategori, super.key});

  /// Gösterilen kategori.
  final LuckCategory kategori;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Savunma derinliği: bu sayfaya hangi yoldan gelinirse gelinsin
    // kilitli kategori içeriği KURULMAZ; paywall gösterilir. (Ana
    // ekran yönlendirmesi tek koruma olamaz.)
    if (ref.watch(kategoriKilitliProvider(kategori))) {
      return const PaywallScreen();
    }

    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final AsyncValue<LuckResult> sonuc = ref.watch(gununSansiProvider);
    final AppDil dil = ref.watch(dilProvider);

    // Şanslı saat, skordan bağımsız deterministik motor çağrısıdır.
    final SansliSaat sansliSaat = ref
        .watch(luckEngineProvider)
        .sansliSaat(
          kullanici: ref.watch(aktifProfilProvider).seed,
          gun: ref.watch(bugunProvider),
          kategori: kategori,
        );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcons.kategori(
              kategori,
              boyut: CategoriesConfig.detayIkonBoyutu,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(kategori.etiket(dil)),
          ],
        ),
      ),
      body: SafeArea(
        child: sonuc.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (Object hata, StackTrace iz) => Center(
            child: Text(TrStrings.hataMetni(dil), style: yaziTemasi.bodyMedium),
          ),
          data: (LuckResult veri) {
            final int skor = veri.kategoriSkorlari[kategori] ?? 0;
            // Yorum, saklanan sonuç + bağımsız içerik tohumundan
            // deterministik seçilir (şanslı saatle aynı sözleşme).
            final String yorum = composer.kategoriYorumu(
              motor: ref.watch(luckEngineProvider),
              kullanici: ref.watch(aktifProfilProvider).seed,
              sonuc: veri,
              kategori: kategori,
              dil: dil,
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: ScoreRing(
                      skor: skor,
                      dil: dil,
                      boyut: CategoriesConfig.detayHalkaCapi,
                      kalinlik: CategoriesConfig.detayHalkaKalinligi,
                      etiket: kategori.etiket(dil).toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(yorum, style: yaziTemasi.bodyMedium),
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
                              CategoriesStrings.sansliSaatBaslik(dil),
                              style: yaziTemasi.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            sansliSaat.etiket,
                            style: yaziTemasi.titleMedium?.copyWith(
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
