import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'share_config.dart';

/// Bir Keşfet aracı sonucunun paylaşım verisi (görsel + metin).
///
/// Araç ekranı neyin paylaşılacağını bu sınıfla tarif eder; kartın nasıl
/// çizileceği paylaşım özelliğinin işidir.
class AracPaylasimi {
  /// Tüm alanlarıyla paylaşım oluşturur.
  const AracPaylasimi({
    required this.ustEtiket,
    required this.baslik,
    required this.sayi,
    required this.sayiEtiketi,
    required this.metin,
  });

  /// Kartın üstündeki araç adı ("NUMARA ANALİZİ").
  final String ustEtiket;

  /// Analiz edilen ad ya da numara ("Elif Yılmaz", "0532 123 45 67").
  final String baslik;

  /// Ortadaki dev sayı ("11", "95").
  final String sayi;

  /// Dev sayının altındaki etiket ("Usta İlham", "Çok uyumlu").
  final String sayiEtiketi;

  /// Kısa yorum (kartta en fazla [ShareConfig.aracMetinSatiri] satır).
  final String metin;

  /// Paylaşım menüsüne eklenen düz metin (görselin yanında), davet
  /// [metinler] dilinde.
  String paylasimMetni(AppLocalizations metinler) =>
      '$baslik · $sayiEtiketi $sayi\n${metinler.paylasimAracDavet}';
}

/// Keşfet aracı sonucu için 1080x1920 story kartı (off-screen render
/// edilir).
///
/// Günün kartıyla ([StoryCard]) aynı görsel dil: çapraz gradient, dev
/// altın sayı, alt köşede marka; altına "sen de hesapla" daveti eklenir —
/// bu kartın asıl işi yeni kullanıcı getirmektir.
///
/// Not: Metinler tema/GoogleFonts yerine yerel sabit stiller kullanır;
/// off-screen render ağacında asenkron font yüklemesine güvenilmez.
class AracStoryCard extends StatelessWidget {
  /// [paylasim] verisiyle kart oluşturur.
  const AracStoryCard({
    required this.paylasim,
    required this.metinler,
    this.arkaPlan,
    super.key,
  });

  /// Kartta gösterilecek veri.
  final AracPaylasimi paylasim;

  /// Kart metinlerinin dili (bkz. [StoryCard.metinler]).
  final AppLocalizations metinler;

  /// Kartı kaplayan tema görseli (null ise lacivert-mor gradyan). Üstüne
  /// uzun metin yazıldığı için düz bir karartmayla koyulaştırılır.
  final Widget? arkaPlan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ShareConfig.kartBoyutu.width,
      height: ShareConfig.kartBoyutu.height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (arkaPlan != null) ...<Widget>[
            arkaPlan!,
            ColoredBox(
              color: AppColors.background.withValues(
                alpha: ShareConfig.aracKarartma,
              ),
            ),
          ] else
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: ShareConfig.gradyanRenkleri,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(ShareConfig.kenarBoslugu),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  paylasim.ustEtiket,
                  style: const TextStyle(
                    fontSize: ShareConfig.tarihPunto,
                    color: AppColors.textSecondary,
                    letterSpacing: ShareConfig.etiketHarfAraligi,
                  ),
                ),
                Text(
                  paylasim.baslik,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: ShareConfig.baslikPunto,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        paylasim.sayi,
                        style: const TextStyle(
                          fontSize: ShareConfig.skorPunto,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                          height: 1,
                        ),
                      ),
                      Text(
                        paylasim.sayiEtiketi,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: ShareConfig.aracEtiketPunto,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldAcik,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  paylasim.metin,
                  maxLines: ShareConfig.aracMetinSatiri,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: ShareConfig.aracMetinPunto,
                    color: AppColors.textPrimary,
                    height: ShareConfig.aracMetinSatirYuksekligi,
                  ),
                ),
                const SizedBox(height: ShareConfig.kenarBoslugu),
                Text(
                  metinler.paylasimMarka,
                  style: TextStyle(
                    fontSize: ShareConfig.markaPunto,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
                Text(
                  metinler.paylasimAracDavet,
                  style: TextStyle(
                    fontSize: ShareConfig.tarihPunto,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
