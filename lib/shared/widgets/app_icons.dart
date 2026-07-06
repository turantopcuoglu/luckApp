import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/luck_engine/luck_category.dart';
import '../../core/theme/app_colors.dart';

/// Kategori SVG ikonlarını flutter_svg ile render eden yardımcı sınıf.
///
/// SVG'ler `assets/svg/` altında elle yazılmıştır (Session 4);
/// currentColor kullandıkları için [renk] ile tema rengine boyanır.
abstract final class AppIcons {
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

/// Tek parça SVG illüstrasyonları render eden yardımcı sınıf.
abstract final class AppIllustrations {
  /// Kristal küre illüstrasyonunun varsayılan boyutu.
  static const double kristalKureBoyutu = 120;

  /// Yıldız deseni karosunun kenar uzunluğu (SVG viewBox'ı ile aynı).
  static const double yildizKaroBoyutu = 200;

  /// Ana ekran köşeleri için soluk yıldız/parçacık deseni karosu.
  ///
  /// Desenin opaklığı SVG içinde sabittir (0.06); renk teması koyu
  /// olduğu için boyama gerektirmez.
  static Widget yildizDeseni({double boyut = yildizKaroBoyutu}) {
    return SvgPicture.asset(
      'assets/svg/arka_plan_yildizlar.svg',
      width: boyut,
      height: boyut,
    );
  }

  /// Boş durum illüstrasyonu: minimal line-art kristal küre.
  static Widget kristalKure({
    double boyut = kristalKureBoyutu,
    Color renk = AppColors.purple,
  }) {
    return SvgPicture.asset(
      'assets/svg/bos_durum_kristal_kure.svg',
      width: boyut,
      height: boyut,
      colorFilter: ColorFilter.mode(renk, BlendMode.srcIn),
    );
  }

  /// Uygulama ikonu taslağı (512x512 yonca); onboarding karşılama
  /// ekranında da kullanılacak. Renkleri SVG içinde sabittir.
  static Widget uygulamaIkonu({required double boyut}) {
    return SvgPicture.asset(
      'assets/svg/app_icon_yonca.svg',
      width: boyut,
      height: boyut,
    );
  }
}
