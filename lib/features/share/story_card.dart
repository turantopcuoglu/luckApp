import 'package:flutter/material.dart';

import '../../core/localization/app_dil.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../daily_luck/tr_strings.dart';
import '../daily_luck/widgets/score_ring.dart';
import 'share_config.dart';
import 'share_strings.dart';

/// 1080x1920 story formatında paylaşım kartı (off-screen render edilir).
///
/// Tasarım ekrandakinden bilinçli olarak farklı: tam ekran çapraz
/// gradient, dev tipografi, kategori mini barları ve alt köşede marka
/// (plan Session 7, madde 4).
///
/// Not: Metinler tema/GoogleFonts yerine yerel sabit stiller kullanır;
/// off-screen render ağacında asenkron font yüklemesine güvenilmez.
///
/// Gizlilik/premium: [kilitliKategoriler] içindeki kategorilerin
/// skoru karta HİÇ çizilmez — sayı yerine kilit ikonu, bar boş kalır.
/// Satır yine de görünür ki paylaşılan görsel premium'u tanıtsın.
class StoryCard extends StatelessWidget {
  /// Günün [sonuc]u ile kart oluşturur.
  const StoryCard({
    required this.sonuc,
    required this.dil,
    this.kilitliKategoriler = const <LuckCategory>{},
    super.key,
  });

  /// Paylaşılan günün sonucu.
  final LuckResult sonuc;

  /// Aktif uygulama dili.
  final AppDil dil;

  /// Skoru maskelenecek (premium kilitli) kategoriler.
  final Set<LuckCategory> kilitliKategoriler;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ShareConfig.kartBoyutu.width,
      height: ShareConfig.kartBoyutu.height,
      child: DecoratedBox(
        // Dramatik zemin: lacivertten mora çapraz gradient.
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
        child: Padding(
          padding: const EdgeInsets.all(ShareConfig.kenarBoslugu),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Üst: tarih.
              Text(
                TrStrings.tarihMetni(dil, sonuc.gun),
                style: const TextStyle(
                  fontSize: ShareConfig.tarihPunto,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),

              // Orta: dev skor halkası + dev sayı.
              Center(
                child: SizedBox(
                  width: ShareConfig.halkaCapi,
                  height: ShareConfig.halkaCapi,
                  child: CustomPaint(
                    painter: ScoreRingPainter(
                      oran: sonuc.genelSkor / EngineConfig.skorMaks,
                      kalinlik: ShareConfig.halkaKalinligi,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '${sonuc.genelSkor}',
                            style: const TextStyle(
                              fontSize: ShareConfig.skorPunto,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                              height: 1,
                            ),
                          ),
                          Text(
                            ShareStrings.genelSkor(dil),
                            style: const TextStyle(
                              fontSize: ShareConfig.skorEtiketPunto,
                              color: AppColors.textSecondary,
                              letterSpacing: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Alt: kategori mini barları. Kilitli kategorilerin
              // gerçek skoru bara hiç aktarılmaz (gizlilik).
              for (final LuckCategory kategori in LuckCategory.values)
                _KategoriBari(
                  kategori: kategori,
                  dil: dil,
                  skor: kilitliKategoriler.contains(kategori)
                      ? 0
                      : sonuc.kategoriSkorlari[kategori] ?? 0,
                  kilitli: kilitliKategoriler.contains(kategori),
                ),
              const SizedBox(height: ShareConfig.kenarBoslugu / 2),

              // Alt köşe: uygulama imzası.
              const Text(
                ShareStrings.marka,
                style: TextStyle(
                  fontSize: ShareConfig.markaPunto,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tek kategori satırı: etiket — dolan bar — skor.
///
/// [kilitli] ise bar boş kalır ve skor yerine kilit ikonu çizilir.
class _KategoriBari extends StatelessWidget {
  const _KategoriBari({
    required this.kategori,
    required this.skor,
    required this.dil,
    this.kilitli = false,
  });

  final LuckCategory kategori;

  /// Aktif uygulama dili.
  final AppDil dil;
  final int skor;
  final bool kilitli;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ShareConfig.kategoriSatirYuksekligi,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: ShareConfig.kategoriEtiketGenisligi,
            child: Text(
              kategori.etiket(dil),
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
                    // Kilitli satırda dolgu çizilmez; oran bile skoru
                    // ele verir.
                    if (!kilitli)
                      FractionallySizedBox(
                        widthFactor: skor / EngineConfig.skorMaks,
                        child: Container(color: AppColors.gold),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: ShareConfig.kategoriSkorGenisligi,
            child: kilitli
                ? const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.lock_rounded,
                      color: AppColors.gold,
                      size: ShareConfig.kilitIkonBoyutu,
                    ),
                  )
                : Text(
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
