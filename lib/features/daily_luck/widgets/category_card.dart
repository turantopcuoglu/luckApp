import 'package:flutter/material.dart';

import '../../../core/luck_engine/luck_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../shared/widgets/app_icons.dart';
import '../daily_luck_config.dart';

/// [kategori]'nin karo rengi (pembe aşk, altın para, yeşil sağlık,
/// mavi sosyal, turuncu risk).
Color kategoriRengi(LuckCategory kategori) => switch (kategori) {
  LuckCategory.ask => AppColors.kategoriAsk,
  LuckCategory.para => AppColors.kategoriPara,
  LuckCategory.saglik => AppColors.kategoriSaglik,
  LuckCategory.sosyal => AppColors.kategoriSosyal,
  LuckCategory.risk => AppColors.kategoriRisk,
};

/// Kapalı kategori karosu: koyu cam zeminde yalnızca soluk, kategori
/// renginde glif; metin yok. Kart açılışından sonra [CategoryCard]'a flip'lenir.
///
/// Genişliği ebeveyn belirler (ana ekranda beş karo bir satırı paylaşır).
class KapaliKategoriKutusu extends StatelessWidget {
  /// [kategori] ikonu ile kapalı karo oluşturur.
  const KapaliKategoriKutusu({required this.kategori, super.key});

  /// Karonun temsil ettiği kategori.
  final LuckCategory kategori;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(
          alpha: DailyLuckConfig.kapaliKaroOpakligi,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.gold.withValues(
            alpha: DailyLuckConfig.karoZeminOpakligi,
          ),
        ),
      ),
      child: Center(
        child: AppIcons.kategori(
          kategori,
          boyut: DailyLuckConfig.kapaliKutuIkonBoyutu,
          renk: kategoriRengi(
            kategori,
          ).withValues(alpha: DailyLuckConfig.kapaliIkonOpakligi),
        ),
      ),
    );
  }
}

/// Açık kategori karosu: kategori renginde hafif tonlu cam zemin, renkli
/// ikon, ad ve büyük skor.
class CategoryCard extends StatelessWidget {
  /// [kategori] ve 0-100 arası [skor] ile karo oluşturur.
  const CategoryCard({required this.kategori, required this.skor, super.key});

  /// Gösterilen kategori.
  final LuckCategory kategori;

  /// Kategorinin bugünkü skoru.
  final int skor;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final Color renk = kategoriRengi(kategori);
    return DecoratedBox(
      decoration: BoxDecoration(
        // Üstten kategori rengi, alta doğru koyu yüzeye inen ton.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            renk.withValues(alpha: DailyLuckConfig.karoZeminOpakligi),
            AppColors.surface.withValues(
              alpha: DailyLuckConfig.kapaliKaroOpakligi,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: renk.withValues(alpha: DailyLuckConfig.karoKenarOpakligi),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            AppIcons.kategori(
              kategori,
              boyut: DailyLuckConfig.kategoriIkonBoyutu,
              renk: renk,
            ),
            // Dar karoda "Sağlık" gibi uzun adlar küçülerek sığar.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                kategori.etiket,
                style: yazi.labelSmall?.copyWith(color: AppColors.textPrimary),
              ),
            ),
            Text(
              '$skor',
              style: yazi.titleLarge?.copyWith(
                color: Color.lerp(
                  renk,
                  AppColors.textPrimary,
                  DailyLuckConfig.karoSkorAcikligi,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
