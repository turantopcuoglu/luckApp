import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/luck_engine/luck_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_icons.dart';
import '../../../shared/widgets/kilit_amblemi.dart';
import '../daily_luck_config.dart';

/// [kategori]'nin rengi (pembe aşk, altın para, yeşil sağlık, mavi
/// sosyal, turuncu risk).
Color kategoriRengi(LuckCategory kategori) => switch (kategori) {
  LuckCategory.ask => AppColors.kategoriAsk,
  LuckCategory.para => AppColors.kategoriPara,
  LuckCategory.saglik => AppColors.kategoriSaglik,
  LuckCategory.sosyal => AppColors.kategoriSosyal,
  LuckCategory.risk => AppColors.kategoriRisk,
};

/// Satırların ortak koyu cam zemini: sahnenin parlak ışıklarının
/// üstünde de yazı okunur. [renk] verilirse soldan hafif bir kategori
/// tonu biner.
BoxDecoration _satirZemini({Color? renk, double kenarOpakligi = 0}) {
  final Color taban = AppColors.background.withValues(
    alpha: DailyLuckConfig.satirZeminOpakligi,
  );
  return BoxDecoration(
    gradient: renk == null
        ? null
        : LinearGradient(
            colors: <Color>[
              Color.alphaBlend(
                renk.withValues(alpha: DailyLuckConfig.satirTonOpakligi),
                taban,
              ),
              taban,
            ],
          ),
    color: renk == null ? taban : null,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(
      color: (renk ?? AppColors.gold).withValues(alpha: kenarOpakligi),
    ),
  );
}

/// Kapalı kategori satırı: koyu cam zeminde yalnızca soluk, kategori
/// renginde glif; metin yok. [kilitli] ise sağda kilit amblemi de durur:
/// kart açılmadan önce de hangi alanların Premium olduğu görünür. Kart
/// açılışından sonra [KategoriSatiri]'na flip'lenir.
class KapaliKategoriSatiri extends StatelessWidget {
  /// [kategori] glifiyle kapalı satır oluşturur.
  const KapaliKategoriSatiri({
    required this.kategori,
    this.kilitli = false,
    super.key,
  });

  /// Satırın temsil ettiği kategori.
  final LuckCategory kategori;

  /// Premium kilidi altında mı?
  final bool kilitli;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _satirZemini(
        kenarOpakligi: DailyLuckConfig.kapaliSatirKenarOpakligi,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AppIcons.kategori(
            kategori,
            boyut: DailyLuckConfig.kapaliSatirIkonBoyutu,
            renk: kategoriRengi(
              kategori,
            ).withValues(alpha: DailyLuckConfig.kapaliIkonOpakligi),
          ),
          if (kilitli)
            const Positioned(
              right: AppSpacing.md,
              child: KilitAmblemi(boyut: DailyLuckConfig.satirKilitBoyutu),
            ),
        ],
      ),
    );
  }
}

/// Açık kategori satırı: renkli glif, kategori adı, günün kısa başlığı,
/// skor çubuğu ve büyük skor.
///
/// [kilitli] ise skor ve çubuk gizlenir, yerine kilit amblemi ve
/// "Kilidi aç" eylemi gelir; günün başlığı ise AÇIK kalır: okur o alanda
/// bugün ne olduğunu sezer ve devamını merak eder. [gununYildizi] günün
/// en yüksek skorlu kategorisini rozetle işaretler (kilitli olsa da).
class KategoriSatiri extends StatelessWidget {
  /// Tüm alanlarıyla satır oluşturur.
  const KategoriSatiri({
    required this.kategori,
    required this.skor,
    this.baslik,
    this.kilitli = false,
    this.gununYildizi = false,
    super.key,
  });

  /// Gösterilen kategori.
  final LuckCategory kategori;

  /// Kategorinin bugünkü skoru (0-100).
  final int skor;

  /// Günün o alandaki kısa başlığı ("Küçük jest, büyük yankı."); henüz
  /// hesaplanmadıysa null.
  final String? baslik;

  /// Premium kilidi altında mı?
  final bool kilitli;

  /// Günün en yüksek skorlu kategorisi mi?
  final bool gununYildizi;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final Color renk = kategoriRengi(kategori);
    return DecoratedBox(
      decoration: _satirZemini(
        renk: renk,
        kenarOpakligi: gununYildizi
            ? DailyLuckConfig.yildizSatirKenarOpakligi
            : DailyLuckConfig.satirKenarOpakligi,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            // Glif, kategori renginde hafif tonlu bir yuvarlağın içinde.
            Container(
              width: DailyLuckConfig.satirIkonZeminCapi,
              height: DailyLuckConfig.satirIkonZeminCapi,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: renk.withValues(
                  alpha: DailyLuckConfig.satirIkonZeminOpakligi,
                ),
              ),
              alignment: Alignment.center,
              child: AppIcons.kategori(
                kategori,
                boyut: DailyLuckConfig.satirIkonBoyutu,
                renk: renk,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          kategori.etiket,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: yazi.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (gununYildizi) ...<Widget>[
                        const SizedBox(width: AppSpacing.sm),
                        _YildizRozeti(metin: l.gunlukGununYildizi),
                      ],
                    ],
                  ),
                  if (baslik case final String b) ...<Widget>[
                    const SizedBox(height: DailyLuckConfig.satirIcBosluk),
                    Text(
                      b,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: yazi.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  _SkorCubugu(skor: skor, renk: renk, gizli: kilitli),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (kilitli)
              _KilitEylemi(
                metin: l.gunlukKilidiAc,
                semantik: l.gunlukKilitliPuanSemantik(kategori.etiket),
              )
            else
              SizedBox(
                width: DailyLuckConfig.satirSkorGenisligi,
                child: Text(
                  '$skor',
                  textAlign: TextAlign.end,
                  style: yazi.headlineSmall?.copyWith(
                    color: Color.lerp(
                      renk,
                      AppColors.textPrimary,
                      DailyLuckConfig.karoSkorAcikligi,
                    ),
                    fontWeight: FontWeight.w700,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// İnce skor çubuğu; [gizli] ise bulanık, rengi soluk bir çubuk (skor
/// sezdirilmez).
class _SkorCubugu extends StatelessWidget {
  const _SkorCubugu({
    required this.skor,
    required this.renk,
    required this.gizli,
  });

  final int skor;
  final Color renk;
  final bool gizli;

  @override
  Widget build(BuildContext context) {
    final Widget cubuk = ClipRRect(
      borderRadius: BorderRadius.circular(DailyLuckConfig.satirCubukYuksekligi),
      child: LinearProgressIndicator(
        // Kilitliyken gerçek skor çubuğa yansımaz; sabit bir doluluk.
        value: gizli
            ? DailyLuckConfig.gizliCubukDolulugu
            : skor / EngineConfig.skorMaks,
        minHeight: DailyLuckConfig.satirCubukYuksekligi,
        backgroundColor: AppColors.textPrimary.withValues(
          alpha: DailyLuckConfig.cubukZeminOpakligi,
        ),
        color: gizli
            ? renk.withValues(alpha: DailyLuckConfig.gizliCubukOpakligi)
            : renk,
      ),
    );
    if (!gizli) {
      return cubuk;
    }
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: DailyLuckConfig.gizliCubukBulanikligi,
        sigmaY: DailyLuckConfig.gizliCubukBulanikligi,
      ),
      child: cubuk,
    );
  }
}

/// Günün en yüksek skorlu kategorisinin altın rozeti.
class _YildizRozeti extends StatelessWidget {
  const _YildizRozeti({required this.metin});

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: DailyLuckConfig.satirIcBosluk,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(
          alpha: DailyLuckConfig.rozetZeminOpakligi,
        ),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.gold),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.auto_awesome_rounded,
            size: DailyLuckConfig.rozetIkonBoyutu,
            color: AppColors.gold,
          ),
          const SizedBox(width: DailyLuckConfig.satirIcBosluk),
          Text(
            metin,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.goldAcik,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kilitli satırın sağ ucu: kilit amblemi ve altın "Kilidi aç".
class _KilitEylemi extends StatelessWidget {
  const _KilitEylemi({required this.metin, required this.semantik});

  final String metin;
  final String semantik;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        KilitAmblemi(
          boyut: DailyLuckConfig.satirKilitBoyutu,
          etiket: semantik,
        ),
        const SizedBox(height: DailyLuckConfig.satirIcBosluk),
        Text(
          metin,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
