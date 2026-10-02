import 'package:flutter/foundation.dart';

/// AdMob birim kimlikleri ve reklam sıklığı politikası.
///
/// ÜRETİM KİMLİKLERİ: AdMob panelinde oluşturduğun reklam birimlerinin
/// kimliklerini derleme sırasında ver:
/// ```
/// flutter build appbundle \
///   --dart-define=ADMOB_ODULLU_ANDROID=ca-app-pub-XXX/YYY \
///   --dart-define=ADMOB_GECIS_ANDROID=ca-app-pub-XXX/YYY \
///   --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-XXX/YYY
/// ```
/// Uygulama kimliği (APP ID) ise `android/gradle.properties` içindeki
/// `ADMOB_APP_ID` değeriyle manifest'e yazılır (bkz. build.gradle.kts).
///
/// Debug derlemede ve üretim kimliği verilmediğinde HER ZAMAN Google'ın
/// herkese açık test kimlikleri kullanılır: kendi reklamına tıklamak
/// AdMob hesabının kapatılmasına yol açabileceği için bu bir güvenlik
/// kuralıdır.
abstract final class AdsConfig {
  // ---- Google'ın resmi test birimleri ----
  static const String _testOdulluAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testGecisAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/9214589741';
  static const String _testOdulluIos = 'ca-app-pub-3940256099942544/1712485313';
  static const String _testGecisIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2435281174';

  // ---- Üretim birimleri (--dart-define) ----
  static const String _uretimOdulluAndroid =
      String.fromEnvironment('ADMOB_ODULLU_ANDROID');
  static const String _uretimGecisAndroid =
      String.fromEnvironment('ADMOB_GECIS_ANDROID');
  static const String _uretimBannerAndroid =
      String.fromEnvironment('ADMOB_BANNER_ANDROID');
  static const String _uretimOdulluIos =
      String.fromEnvironment('ADMOB_ODULLU_IOS');
  static const String _uretimGecisIos =
      String.fromEnvironment('ADMOB_GECIS_IOS');
  static const String _uretimBannerIos =
      String.fromEnvironment('ADMOB_BANNER_IOS');

  static String _sec({
    required String uretimAndroid,
    required String uretimIos,
    required String testAndroid,
    required String testIos,
  }) {
    final bool ios = defaultTargetPlatform == TargetPlatform.iOS;
    final String uretim = ios ? uretimIos : uretimAndroid;
    if (kReleaseMode && uretim.isNotEmpty) {
      return uretim;
    }
    return ios ? testIos : testAndroid;
  }

  /// Ödüllü reklam birimi.
  static String get odulluBirim => _sec(
        uretimAndroid: _uretimOdulluAndroid,
        uretimIos: _uretimOdulluIos,
        testAndroid: _testOdulluAndroid,
        testIos: _testOdulluIos,
      );

  /// Geçiş (interstitial) reklam birimi.
  static String get gecisBirim => _sec(
        uretimAndroid: _uretimGecisAndroid,
        uretimIos: _uretimGecisIos,
        testAndroid: _testGecisAndroid,
        testIos: _testGecisIos,
      );

  /// Uyarlanabilir banner birimi.
  static String get bannerBirim => _sec(
        uretimAndroid: _uretimBannerAndroid,
        uretimIos: _uretimBannerIos,
        testAndroid: _testBannerAndroid,
        testIos: _testBannerIos,
      );

  // ---- Sıklık politikası ----

  /// İki geçiş reklamı arasında geçmesi gereken en az süre.
  static const Duration gecisReklamiAraligi = Duration(hours: 20);

  /// Geçiş reklamı ilk kurulumdan bu kadar gün sonra başlar (yeni
  /// kullanıcının ilk izlenimi reklamsız olsun).
  static const int gecisIcinEnAzGun = 3;

  /// Ödüllü reklam yüklenmemişse beklenecek azami süre.
  static const Duration yuklemeZamanAsimi = Duration(seconds: 8);

  /// Reklam içerik derecelendirmesi sınırı (PG: genel izleyici + ebeveyn
  /// rehberliği; fal/şans uygulamasında yetişkin reklam gösterilmez).
  static const String icerikDerecesi = 'PG';
}
