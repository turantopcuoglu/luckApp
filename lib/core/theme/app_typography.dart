import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paketlenmiş yazı tipleri ve açık/koyu temanın ortak metin hiyerarşisi.
abstract final class AppTypography {
  /// Uygulama başlangıcında bir kez çağrılır; yerel font lisanslarını
  /// Material lisans ekranına ekler. İçerik yalnız ekran açılınca okunur.
  static void registerLicenses() {
    LicenseRegistry.addLicense(() async* {
      for (final String name in <String>['Inter', 'PlayfairDisplay']) {
        yield LicenseEntryWithLineBreaks(<String>[
          name,
        ], await rootBundle.loadString('assets/fonts/$name-OFL.txt'));
      }
    });
  }

  /// Ağ isteği yapmayan Inter ailesi.
  static const String bodyFamily = 'Inter';

  /// Başlıklar için paketlenmiş Playfair Display ailesi.
  static const String headingFamily = 'PlayfairDisplay';

  /// Gövde fontunun değişken ağırlıklı yerel dosyası.
  static const String bodyAsset = 'assets/fonts/Inter-Variable.ttf';

  /// Başlık fontunun değişken ağırlıklı yerel dosyası.
  static const String headingAsset =
      'assets/fonts/PlayfairDisplay-Variable.ttf';

  /// Rakam değişirken yatay sıçramayı önleyen büyük skor stili.
  static const TextStyle score = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 88,
    height: 1.05,
    fontWeight: FontWeight.w600,
    letterSpacing: -3,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// Tema rengini koruyan, okunaklı ve ölçeklenebilir stiller.
  static TextTheme textTheme(Brightness brightness) {
    final TextTheme base =
        (brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light())
            .textTheme
            .apply(fontFamily: bodyFamily);
    return base.copyWith(
      displayLarge: score,
      displayMedium: const TextStyle(
        fontFamily: headingFamily,
        fontSize: 44,
        height: 1.15,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: const TextStyle(
        fontFamily: headingFamily,
        fontSize: 36,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: const TextStyle(
        fontFamily: headingFamily,
        fontSize: 32,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: const TextStyle(
        fontFamily: headingFamily,
        fontSize: 28,
        height: 1.25,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: const TextStyle(
        fontFamily: headingFamily,
        fontSize: 24,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: const TextStyle(
        fontFamily: bodyFamily,
        fontSize: 22,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: const TextStyle(
        fontFamily: bodyFamily,
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: const TextStyle(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: const TextStyle(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.5,
      ),
      labelLarge: const TextStyle(
        fontFamily: bodyFamily,
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
