import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/fortune_composer.dart';
import '../../core/content/gunluk_okuma.dart';
import '../../core/storage/kayitli_kisi.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../categories/categories_config.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../daily_luck/widgets/score_ring.dart';
import 'uyum_strings.dart';

/// Kullanıcı ile [kisi] arasındaki uyum okuması.
class UyumSonucScreen extends ConsumerWidget {
  /// [kisi] ile ekran oluşturur.
  const UyumSonucScreen({required this.kisi, super.key});

  /// Uyumu hesaplanan kişi.
  final KayitliKisi kisi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final UyumOkumasi okuma = uyumOkumasi(
      okuyucu: ref.watch(aktifProfilProvider).okuyucu,
      digerIsim: kisi.kisaAd,
      digerProfil: kisi.profil,
    );
    return Scaffold(
      appBar: AppBar(title: Text(kisi.kisaAd)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Center(
              child: ScoreRing(
                skor: okuma.sonuc.skor,
                boyut: CategoriesConfig.detayHalkaCapi,
                kalinlik: CategoriesConfig.detayHalkaKalinligi,
                etiket: UyumStrings.uyumEtiketi,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              okuma.sonuc.derece.etiket,
              style: yazi.titleLarge?.copyWith(color: AppColors.gold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final UyumBolumu bolum in okuma.bolumler) ...<Widget>[
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        bolum.baslik,
                        style: yazi.titleSmall?.copyWith(
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        bolum.metin,
                        style: yazi.bodyLarge?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              UyumStrings.sonucNotu,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
