import 'package:flutter/material.dart';

import '../../../core/content/content_config.dart';
import '../../../core/history/history_analiz_config.dart';
import '../../../core/localization/app_dil.dart';
import '../../../core/luck_engine/luck_engine.dart';
import '../../../core/storage/daily_record.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../history/history_config.dart';
import '../collection_config.dart';
import '../collection_strings.dart';

/// Koleksiyon grid'indeki tek bir günü temsil eden minik kader kartı.
///
/// Arka plan rengi, günün skor bandından (`HistoryConfig.bandRampasi`)
/// gelir — heatmap ile aynı görsel dil. Skor "Altın Gün" eşiğini
/// (`HistoryAnalizConfig.altinGunEsigi`) geçen nadir günler altın kenar
/// + 🌟 rozetiyle öne çıkar. Dokununca [onTap] tetiklenir.
class KartMinik extends StatelessWidget {
  /// [kayit] gününü temsil eden kartı, [onTap] dokunuş geri çağrısıyla
  /// oluşturur.
  const KartMinik({
    required this.kayit,
    required this.dil,
    this.onTap,
    super.key,
  });

  /// Gösterilecek günün kaydı.
  final DailyRecord kayit;

  /// Aktif uygulama dili.
  final AppDil dil;

  /// Karta dokunulunca çağrılır (null ise kart pasiftir).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final int skor = kayit.sonuc.genelSkor;
    final bool altinGun = skor >= HistoryAnalizConfig.altinGunEsigi;
    // Heatmap ile aynı kaynak: skor bandı → renk (magic renk yok).
    final Color bandRengi =
        HistoryConfig.bandRampasi[SkorBandi.bandiBul(skor)]!;
    final TextTheme yaziTemasi = Theme.of(context).textTheme;

    // Kartı tek anlamlı, dokunulabilir düğüme indir: iç tarih/skor
    // metinleri (ve 🌟 emojisi) yerine "6 Temmuz: 95 / 100, Altın Gün".
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: CollectionStrings.kartErisim(
          dil,
          kayit.gun,
          skor,
          EngineConfig.skorMaks,
          altinGun,
        ),
        child: GestureDetector(
          onTap: onTap,
          // Kartın tamamı dokunulabilir olsun (ortası boş olsa da).
          behavior: HitTestBehavior.opaque,
          child: ExcludeSemantics(
            child: Container(
              decoration: BoxDecoration(
                color: bandRengi,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: altinGun
                    ? Border.all(
                        color: AppColors.gold,
                        width: CollectionConfig.altinKenarKalinligi,
                      )
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  // Alt scrim: band rengi açık (altın) olsa da metnin her
                  // zaman okunur kalması için alttan koyu bir geçiş.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Colors.transparent, Colors.black45],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(CollectionConfig.kartIcDolgu),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          CollectionStrings.kartTarihi(dil, kayit.gun),
                          style: yaziTemasi.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$skor',
                          style: yaziTemasi.headlineMedium?.copyWith(
                            color: altinGun
                                ? AppColors.goldAcik
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Altın Gün rozeti (yalnız nadir günlerde).
                  if (altinGun)
                    const Positioned(
                      top: CollectionConfig.rozetKenarBoslugu,
                      right: CollectionConfig.rozetKenarBoslugu,
                      child: Text(CollectionStrings.altinRozet),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
