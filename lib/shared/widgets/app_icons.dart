import 'package:flutter/widgets.dart';

import '../../core/luck_engine/luck_category.dart';
import '../../core/theme/app_colors.dart';

/// Kategori gliflerini çizen yardımcı sınıf.
///
/// Glifler `assets/images/kategori_*.webp` altında tek renk beyaz,
/// şeffaf zeminli raster görsellerdir (GPT seti, P1-B5); kod her birini
/// [renk] ile `srcIn` karışımıyla boyar.
abstract final class AppIcons {
  /// İkonların varsayılan kenar uzunluğu.
  static const double varsayilanBoyut = 24;

  /// Kategori → asset yolu eşlemesi.
  static const Map<LuckCategory, String> kategoriDosyalari =
      <LuckCategory, String>{
    LuckCategory.ask: 'assets/images/kategori_ask.webp',
    LuckCategory.para: 'assets/images/kategori_para.webp',
    LuckCategory.saglik: 'assets/images/kategori_saglik.webp',
    LuckCategory.risk: 'assets/images/kategori_risk.webp',
    LuckCategory.sosyal: 'assets/images/kategori_sosyal.webp',
  };

  /// [kategori] glifini [renk] ile [boyut] boyutunda çizer.
  static Widget kategori(
    LuckCategory kategori, {
    double boyut = varsayilanBoyut,
    Color renk = AppColors.gold,
  }) {
    return Image.asset(
      kategoriDosyalari[kategori]!,
      width: boyut,
      height: boyut,
      color: renk,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );
  }
}

