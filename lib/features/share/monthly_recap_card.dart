import 'package:flutter/material.dart';

import '../../core/history/aylik_ozet.dart';
import '../../core/localization/app_dil.dart';
import '../../core/theme/app_colors.dart';
import '../daily_luck/tr_strings.dart';
import 'recap_config.dart';
import 'recap_strings.dart';
import 'share_config.dart';
import 'share_strings.dart';

/// Ay Sonu Şans Raporu'nun 1080x1920 paylaşım kartı (off-screen render).
///
/// StoryCard deseni: tam ekran çapraz gradient, dev tipografi, yerel
/// sabit stiller (tema/GoogleFonts YOK — off-screen ağaçta asenkron font
/// yüklemesine güvenilmez). SVG asset KULLANILMAZ (off-screen'de asenkron
/// yüklenir); yonca filigranı emoji ile çizilir.
class MonthlyRecapCard extends StatelessWidget {
  /// [ozet] ay özetiyle kart oluşturur.
  const MonthlyRecapCard({required this.ozet, required this.dil, super.key});

  /// Kartta gösterilen ay özeti.
  final AylikOzet ozet;

  /// Aktif uygulama dili.
  final AppDil dil;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ShareConfig.kartBoyutu.width,
      height: ShareConfig.kartBoyutu.height,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.background,
              Color(0xFF231C4E),
              Color(0xFF43317A),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            // Soluk yonca filigranı (emoji — SVG değil).
            const Positioned(
              right: -ShareConfig.kenarBoslugu,
              bottom: ShareConfig.kenarBoslugu * 2,
              child: Opacity(
                opacity: 0.06,
                child: Text(
                  '🍀',
                  style: TextStyle(fontSize: RecapConfig.filigranPunto),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ShareConfig.kenarBoslugu),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    RecapStrings.ustBaslik(dil),
                    style: const TextStyle(
                      fontSize: RecapConfig.ustBaslikPunto,
                      color: AppColors.textSecondary,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: ShareConfig.kenarBoslugu / 4),
                  // Dev ay + yıl başlığı.
                  Text(
                    '${TrStrings.ayAdlari(dil)[ozet.ay - 1]} ${ozet.yil}',
                    style: const TextStyle(
                      fontSize: RecapConfig.ayBasligiPunto,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                      height: 1,
                    ),
                  ),
                  const Spacer(),
                  // Öne çıkanlar.
                  _stat(
                    RecapStrings.enSansliGunEtiketi(dil),
                    ozet.enSansliGun == null
                        ? '—'
                        : '${ozet.enSansliGun!.day} '
                              '${TrStrings.ayAdlari(dil)[ozet.enSansliGun!.month - 1]}'
                              ' · ${ozet.enSansliSkor}',
                  ),
                  _stat(
                    RecapStrings.ortalamaEtiketi(dil),
                    '${ozet.ortalamaSkor}',
                  ),
                  _stat(
                    RecapStrings.altinGunEtiketi(dil),
                    RecapStrings.altinGunDegeri(ozet.altinGunSayisi),
                  ),
                  _stat(
                    RecapStrings.enUzunSeriEtiketi(dil),
                    RecapStrings.enUzunSeriDegeri(ozet.enUzunSeri),
                  ),
                  _stat(
                    RecapStrings.baskinKategoriEtiketi(dil),
                    ozet.baskinKategori?.etiket(dil) ?? '—',
                  ),
                  const Spacer(),
                  const Text(
                    ShareStrings.marka,
                    style: TextStyle(
                      fontSize: RecapConfig.markaPunto,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tek istatistik bloğu: küçük etiket üstte, dev değer altta.
  Widget _stat(String etiket, String deger) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RecapConfig.statAraligi),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            etiket,
            style: const TextStyle(
              fontSize: RecapConfig.statEtiketPunto,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            deger,
            style: const TextStyle(
              fontSize: RecapConfig.statDegerPunto,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
