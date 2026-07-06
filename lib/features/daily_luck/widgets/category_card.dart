import 'package:flutter/material.dart';

import '../../../core/luck_engine/luck_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../daily_luck_config.dart';

/// Tek bir kategorinin mini kartı: ad, skor ve ince ilerleme barı.
///
/// Kategori ikonları Session 4'te (SVG üretimi) eklenecek.
class CategoryCard extends StatelessWidget {
  /// [kategori] ve 0-100 arası [skor] ile kart oluşturur.
  const CategoryCard({required this.kategori, required this.skor, super.key});

  /// Gösterilen kategori.
  final LuckCategory kategori;

  /// Kategorinin bugünkü skoru.
  final int skor;

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
              Text(
                kategori.etiket,
                style: yaziTemasi.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '$skor',
                style: yaziTemasi.headlineSmall?.copyWith(
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: skor / EngineConfig.skorMaks,
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
