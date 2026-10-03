import 'package:flutter/material.dart';

import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../daily_luck/tr_strings.dart';
import 'share_config.dart';
import 'share_strings.dart';

/// 1080x1920 story formatında paylaşım kartı (off-screen render edilir;
/// paylaşım ekranında küçültülmüş önizleme olarak da gösterilir).
///
/// Tasarım (mockup `9635f67f` 1. ekran): seçilen temanın kemerli gece
/// sahnesi, ortadaki sakin gökyüzünde dev skor, altında kategori barları
/// ve marka. [skoruGizle] açıkken skor ve kategori puanları yazılmaz;
/// ortada günün başlığı durur.
///
/// Not: Metinler tema/GoogleFonts yerine yerel sabit stiller kullanır;
/// off-screen render ağacında asenkron font yüklemesine güvenilmez. Aynı
/// sebeple [arkaPlan] dışarıdan, önceden çözülmüş görsel olarak verilir.
class StoryCard extends StatelessWidget {
  /// Günün [sonuc]u ile kart oluşturur.
  const StoryCard({
    required this.sonuc,
    this.baslik,
    this.arkaPlan,
    this.skoruGizle = false,
    super.key,
  });

  /// Paylaşılan günün sonucu.
  final LuckResult sonuc;

  /// Günün kişisel başlığı; paylaşılabilir kimlik etiketi olarak tarihin
  /// altına yazılır (yoksa gösterilmez).
  final String? baslik;

  /// Kartı kaplayan tema görseli (null ise lacivert-mor gradyan).
  final Widget? arkaPlan;

  /// Skor ve kategori puanları gizlensin mi?
  final bool skoruGizle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ShareConfig.kartBoyutu.width,
      height: ShareConfig.kartBoyutu.height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          arkaPlan ?? const _GradyanZemin(),
          const _OkumaKarartmasi(),
          Padding(
            padding: const EdgeInsets.all(ShareConfig.kenarBoslugu),
            child: Column(
              children: <Widget>[
                // Üst: tarih ve günün başlığı.
                Text(
                  TrStrings.tarihMetni(sonuc.gun),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: ShareConfig.tarihPunto,
                    color: AppColors.goldAcik,
                    letterSpacing: ShareConfig.etiketHarfAraligi,
                    shadows: ShareConfig.yaziGolgesi,
                  ),
                ),
                if (baslik != null && !skoruGizle)
                  Text(
                    baslik!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: ShareConfig.baslikPunto,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      shadows: ShareConfig.yaziGolgesi,
                    ),
                  ),
                const Spacer(),
                if (skoruGizle)
                  Text(
                    baslik ?? ShareStrings.paylasimMetni,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: ShareConfig.gizliBaslikPunto,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldAcik,
                      height: ShareConfig.aracMetinSatirYuksekligi,
                      shadows: ShareConfig.yaziGolgesi,
                    ),
                  )
                else ...<Widget>[
                  const Text(
                    ShareStrings.genelSkor,
                    style: TextStyle(
                      fontSize: ShareConfig.skorEtiketPunto,
                      color: AppColors.textPrimary,
                      letterSpacing: ShareConfig.skorEtiketHarfAraligi,
                      shadows: ShareConfig.yaziGolgesi,
                    ),
                  ),
                  Text(
                    '${sonuc.genelSkor}',
                    style: const TextStyle(
                      fontSize: ShareConfig.skorPunto,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldAcik,
                      height: 1,
                      shadows: ShareConfig.skorGolgesi,
                    ),
                  ),
                ],
                const Spacer(),
                // Alt: kategori mini barları (skor gizliyse gösterilmez).
                if (!skoruGizle)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(
                        alpha: ShareConfig.panelOpakligi,
                      ),
                      borderRadius: BorderRadius.circular(
                        ShareConfig.panelYaricapi,
                      ),
                      border: Border.all(
                        color: AppColors.gold.withValues(
                          alpha: ShareConfig.panelKenarOpakligi,
                        ),
                        width: ShareConfig.panelKenarKalinligi,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ShareConfig.kenarBoslugu / 2,
                        vertical: ShareConfig.kenarBoslugu / 3,
                      ),
                      child: Column(
                        children: <Widget>[
                          for (final LuckCategory kategori
                              in LuckCategory.values)
                            _KategoriBari(
                              kategori: kategori,
                              skor: sonuc.kategoriSkorlari[kategori] ?? 0,
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: ShareConfig.kenarBoslugu / 2),

                // Alt orta: uygulama imzası.
                const Text(
                  ShareStrings.marka,
                  style: TextStyle(
                    fontSize: ShareConfig.markaPunto,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                    shadows: ShareConfig.yaziGolgesi,
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

/// Tema görseli verilmediğinde kullanılan lacivertten mora gradyan.
class _GradyanZemin extends StatelessWidget {
  const _GradyanZemin();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ShareConfig.gradyanRenkleri,
        ),
      ),
    );
  }
}

/// Üstte ve altta metinlerin okunmasını sağlayan yumuşak karartma; orta
/// (skor alanı) açık kalır.
class _OkumaKarartmasi extends StatelessWidget {
  const _OkumaKarartmasi();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.background.withValues(alpha: ShareConfig.ustKarartma),
            AppColors.background.withValues(alpha: 0),
            AppColors.background.withValues(alpha: 0),
            AppColors.background.withValues(alpha: ShareConfig.altKarartma),
          ],
          stops: ShareConfig.karartmaDuraklari,
        ),
      ),
    );
  }
}

/// Tek kategori satırı: etiket — dolan bar — skor.
class _KategoriBari extends StatelessWidget {
  const _KategoriBari({required this.kategori, required this.skor});

  final LuckCategory kategori;
  final int skor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ShareConfig.kategoriSatirYuksekligi,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: ShareConfig.kategoriEtiketGenisligi,
            child: Text(
              kategori.etiket,
              style: const TextStyle(
                fontSize: ShareConfig.kategoriPunto,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: SizedBox(
                height: ShareConfig.barYuksekligi,
                child: Stack(
                  children: <Widget>[
                    Container(color: AppColors.surface),
                    FractionallySizedBox(
                      widthFactor: skor / EngineConfig.skorMaks,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[AppColors.gold, AppColors.goldAcik],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: ShareConfig.kategoriSkorGenisligi,
            child: Text(
              '$skor',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: ShareConfig.kategoriPunto,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
