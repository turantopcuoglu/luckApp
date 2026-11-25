import 'package:flutter/material.dart';

import '../../../core/content/gunluk_okuma.dart';
import '../../../core/luck_engine/luck_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../l10n/app_localizations.dart';
import '../daily_luck_config.dart';
import 'category_card.dart';

/// Günün kişiye özel okumasını gösteren kart.
///
/// En üstte okumanın dayanağını söyleyen tek satır durur ("Sana özel,
/// çünkü 14 Mart doğumlusun: burcun Balık…"): okur kendi verisini görür ve
/// devamını kendisine yazılmış olarak okur. Ardından okuma tek bir metin
/// bloğu değil, başlıklı bölümlerdir: "Günün enerjisi", "Öne çıkan · Aşk"
/// ve "Dikkat · Risk" gibi; en altta dönem cümlesi. Başlıklar okurun metni
/// taramasını ve "bu benim günüm" bağını kurmasını kolaylaştırır. Kategori bölümlerinin sonunda o alanın
/// tam okumasına giden bağlantı vardır ([onKategori]); alan kilitliyse
/// bağlantı kilit seçeneklerini açar (çağıran karar verir).
class CommentCard extends StatelessWidget {
  /// [okuma] içeriğiyle kart oluşturur.
  const CommentCard({required this.okuma, this.onKategori, super.key});

  /// Günün bölümlü okuması.
  final GunlukOkuma okuma;

  /// Kategori bölümündeki "okumanın tamamı" bağlantısı; null ise
  /// bağlantı gösterilmez.
  final ValueChanged<LuckCategory>? onKategori;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _CunkuSatiri(metin: okuma.cunku),
            const SizedBox(height: AppSpacing.md),
            for (int i = 0; i < okuma.bolumler.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              _Bolum(
                bolum: okuma.bolumler[i],
                baslik: _bolumBasligi(l, okuma.bolumler[i]),
                onKategori: onKategori,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              okuma.kapanis,
              style: yazi.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                height: DailyLuckConfig.okumaSatirYuksekligi,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [bolum] türüne göre bölüm başlığı.
  static String _bolumBasligi(AppLocalizations l, OkumaBolumu bolum) =>
      switch (bolum.tur) {
        OkumaBolumTuru.enerji => l.gunlukBolumEnerji,
        OkumaBolumTuru.parlayan => l.gunlukBolumParlayan(
          bolum.kategori!.etiket,
        ),
        OkumaBolumTuru.dikkat => l.gunlukBolumDikkat(bolum.kategori!.etiket),
      };
}

/// Okumanın dayanağı: hafif altın zeminli kutuda yıldız ikonu ve tek
/// satırlık "çünkü" cümlesi. Yorumdan küçük ve soluk yazılır ki onun önüne
/// geçmesin.
class _CunkuSatiri extends StatelessWidget {
  const _CunkuSatiri({required this.metin});

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(
          alpha: DailyLuckConfig.cunkuZeminOpakligi,
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: AppColors.gold.withValues(
            alpha: DailyLuckConfig.cunkuKenarOpakligi,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // İkon ilk satırın hizasında dursun diye üstten küçük boşluk.
          const Padding(
            padding: EdgeInsets.only(top: DailyLuckConfig.satirIcBosluk),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: DailyLuckConfig.cunkuIkonBoyutu,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              metin,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.goldAcik,
                height: DailyLuckConfig.okumaSatirYuksekligi,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Okumanın tek bölümü: renkli başlık, metin ve (kategori bölümünde)
/// tam okumaya bağlantı.
class _Bolum extends StatelessWidget {
  const _Bolum({
    required this.bolum,
    required this.baslik,
    required this.onKategori,
  });

  final OkumaBolumu bolum;
  final String baslik;
  final ValueChanged<LuckCategory>? onKategori;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final LuckCategory? kategori = bolum.kategori;
    // Enerji bölümü altın, kategori bölümleri kendi renginde.
    final Color renk = kategori == null
        ? AppColors.gold
        : kategoriRengi(kategori);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          baslik,
          style: yazi.labelLarge?.copyWith(
            color: renk,
            fontWeight: FontWeight.w700,
            letterSpacing: DailyLuckConfig.etiketHarfAraligi,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          bolum.metin,
          style: yazi.bodyMedium?.copyWith(
            height: DailyLuckConfig.okumaSatirYuksekligi,
          ),
        ),
        if (kategori != null && onKategori != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onKategori!(kategori),
              style: TextButton.styleFrom(foregroundColor: renk),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(l.gunlukDevaminiOku(kategori.etiket)),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: DailyLuckConfig.bolumIkonBoyutu,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
