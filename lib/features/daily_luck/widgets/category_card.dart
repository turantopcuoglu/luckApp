import 'package:flutter/material.dart';

import '../../../core/luck_engine/luck_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../shared/widgets/app_icons.dart';
import '../../categories/categories_config.dart';
import '../../categories/categories_strings.dart';
import '../daily_luck_config.dart';

/// Kapalı kategori kutusu: yalnızca ortada büyük kategori ikonu,
/// metin yok. Kart açılışından sonra [CategoryCard]'a flip'lenir.
class KapaliKategoriKutusu extends StatelessWidget {
  /// [kategori] ikonu ile kapalı kutu oluşturur.
  const KapaliKategoriKutusu({required this.kategori, super.key});

  /// Kutunun temsil ettiği kategori.
  final LuckCategory kategori;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DailyLuckConfig.kategoriKartGenisligi,
      child: Card(
        margin: EdgeInsets.zero,
        child: Center(
          child: AppIcons.kategori(
            kategori,
            boyut: DailyLuckConfig.kapaliKutuIkonBoyutu,
            renk: AppColors.gold,
          ),
        ),
      ),
    );
  }
}

/// Tek bir kategorinin mini kartı: ikon + ad, skor ve ince ilerleme barı.
///
/// [kilitli] ise gerçek skor widget ağacına HİÇ girmez: sayı yerine
/// maske metni, bar yerine sabit dolgu çizilir. Üstteki blur/scrim
/// (PremiumGate) yalnızca görsel cila — gizlilik burada sağlanır.
class CategoryCard extends StatelessWidget {
  /// [kategori] ve 0-100 arası [skor] ile kart oluşturur.
  const CategoryCard({
    required this.kategori,
    required this.skor,
    this.kilitli = false,
    super.key,
  });

  /// Gösterilen kategori.
  final LuckCategory kategori;

  /// Kategorinin bugünkü skoru.
  final int skor;

  /// Kart premium kilidi altında mı? (skor maskelenir)
  final bool kilitli;

  @override
  Widget build(BuildContext context) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    return SizedBox(
      width: DailyLuckConfig.kategoriKartGenisligi,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  AppIcons.kategori(
                    kategori,
                    boyut: DailyLuckConfig.kategoriIkonBoyutu,
                    renk: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Uzun etiketler (ör. "Sağlık") kart genişliğini
                  // aşabilir; Expanded + ellipsis taşmayı önler.
                  Expanded(
                    child: Text(
                      kategori.etiket,
                      overflow: TextOverflow.ellipsis,
                      style: yaziTemasi.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                kilitli ? CategoriesStrings.kilitliSkor : '$skor',
                style: yaziTemasi.headlineSmall?.copyWith(
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  // Kilitliyken bar dolgusu da skoru sızdırmasın.
                  value: kilitli
                      ? CategoriesConfig.kilitliBarOran
                      : skor / EngineConfig.skorMaks,
                  minHeight: DailyLuckConfig.kategoriBarYuksekligi,
                  color: AppColors.gold,
                  backgroundColor: AppColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
