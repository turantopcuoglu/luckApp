import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/content/experience_dimension.dart';
import '../../core/luck_engine/luck_category.dart';
import '../../core/theme/app_colors.dart';

export 'app_illustrations.dart';

/// Kategori SVG ikonlarını flutter_svg ile render eden yardımcı sınıf.
///
/// SVG'ler `assets/svg/` altında elle yazılmıştır (Session 4);
/// currentColor kullandıkları için [renk] ile tema rengine boyanır.
abstract final class AppIcons {
  /// Yeni alanların tek ve tam ikon eşlemesi.
  static const Map<ExperienceDimension, String> dimensionAssets =
      <ExperienceDimension, String>{
        ExperienceDimension.akis: 'assets/svg/dimension_akis.svg',
        ExperienceDimension.bag: 'assets/svg/dimension_bag.svg',
        ExperienceDimension.uretim: 'assets/svg/dimension_uretim.svg',
        ExperienceDimension.cesaret: 'assets/svg/dimension_cesaret.svg',
        ExperienceDimension.denge: 'assets/svg/dimension_denge.svg',
      };

  /// Varsayılan olarak tema ikon rengini kullanır; etiket yoksa dekoratiftir.
  static Widget dimension(
    ExperienceDimension dimension, {
    double size = varsayilanBoyut,
    Color? color,
    String? semanticLabel,
  }) => Builder(
    builder: (BuildContext context) => SvgPicture.asset(
      dimensionAssets[dimension]!,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        color ?? IconTheme.of(context).color ?? AppColors.textOnCream,
        BlendMode.srcIn,
      ),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    ),
  );

  /// İkonların varsayılan kenar uzunluğu (SVG viewBox'ı ile aynı).
  static const double varsayilanBoyut = 24;

  /// Kategori → asset yolu eşlemesi.
  static const Map<LuckCategory, String> _kategoriDosyalari =
      <LuckCategory, String>{
        LuckCategory.ask: 'assets/svg/kategori_kalp.svg',
        LuckCategory.para: 'assets/svg/kategori_para.svg',
        LuckCategory.saglik: 'assets/svg/kategori_yaprak.svg',
        LuckCategory.risk: 'assets/svg/kategori_zar.svg',
        LuckCategory.sosyal: 'assets/svg/kategori_sosyal.svg',
      };

  /// [kategori] ikonunu [renk] ile [boyut] boyutunda çizer.
  /// @deprecated Yeni ekranlar dimension kullanmalı; zar ikonu taşınmaz.
  static Widget kategori(
    LuckCategory kategori, {
    double boyut = varsayilanBoyut,
    Color renk = AppColors.gold,
  }) {
    return SvgPicture.asset(
      _kategoriDosyalari[kategori]!,
      width: boyut,
      height: boyut,
      colorFilter: ColorFilter.mode(renk, BlendMode.srcIn),
    );
  }
}
