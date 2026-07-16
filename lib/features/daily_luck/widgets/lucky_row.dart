import 'package:flutter/material.dart';

import '../../../core/content/gunun_icerigi.dart';
import '../../../core/localization/app_dil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../daily_luck_config.dart';
import '../tr_strings.dart';

/// Günün şans ögelerini gösteren kart: şans rengi + şanslı sayı üstte
/// yan yana, günün tavsiyesi altta tam satır.
class SansOgeleriKarti extends StatelessWidget {
  /// [icerik] paketindeki renk/sayı/tavsiye ile kart oluşturur.
  const SansOgeleriKarti({required this.icerik, required this.dil, super.key});

  /// Gösterilecek günün içeriği.
  final GununIcerigi icerik;

  /// Aktif uygulama dili.
  final AppDil dil;

  @override
  Widget build(BuildContext context) {
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
                // Sol sütun: renk yuvarlağı + adı.
                Expanded(
                  child: _OgeSutunu(
                    etiket: TrStrings.sansRengiEtiketi(dil),
                    deger: Row(
                      children: <Widget>[
                        Container(
                          width: DailyLuckConfig.sansRengiCapi,
                          height: DailyLuckConfig.sansRengiCapi,
                          decoration: BoxDecoration(
                            color: Color(icerik.sansRengi.hexArgb),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gold),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            icerik.sansRengi.ad(dil),
                            style: yaziTemasi.titleSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Sağ sütun: altın renkli şanslı sayı.
                Expanded(
                  child: _OgeSutunu(
                    etiket: TrStrings.sansliSayiEtiketi(dil),
                    deger: Text(
                      '${icerik.sansliSayi}',
                      style: yaziTemasi.headlineMedium?.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Alt satır: günün tavsiyesi.
            _OgeSutunu(
              etiket: TrStrings.tavsiyeEtiketi(dil),
              deger: Text(icerik.tavsiye, style: yaziTemasi.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soluk etiket + değer içeriğinden oluşan dikey öge bloğu.
class _OgeSutunu extends StatelessWidget {
  const _OgeSutunu({required this.etiket, required this.deger});

  /// Üstteki soluk açıklama etiketi.
  final String etiket;

  /// Etiketin altında gösterilen içerik.
  final Widget deger;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          etiket,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        deger,
      ],
    );
  }
}
