import 'package:flutter/material.dart';

/// Ortak geçişler ve ilerideki kart koreografisinin tek süre/eğri kaynağı.
abstract final class AppMotion {
  /// Basma/tilt yanıtı.
  static const Duration press = Duration(milliseconds: 150);

  /// Mühür nabzı.
  static const Duration seal = Duration(milliseconds: 250);

  /// Standart kontrol geçişi.
  static const Duration standard = Duration(milliseconds: 250);

  /// Işık dikişi.
  static const Duration lightSeam = Duration(milliseconds: 400);

  /// Kart katmanları açılışı.
  static const Duration unfold = Duration(milliseconds: 650);

  /// Birbirleriyle örtüşen parçacık ve sonuç girişleri.
  static const Duration resultEntry = Duration(milliseconds: 700);

  /// Dört ardışık aşamanın hedef süresi; disk bekleme buna eklenebilir.
  static const Duration reveal = Duration(milliseconds: 2000);

  /// Hareket azaltmada yalnız kısa çapraz fade.
  static const Duration reduced = Duration(milliseconds: 180);

  /// Kontrollü giriş eğrisi.
  static const Curve enter = Curves.easeOutCubic;

  /// Kontrollü çıkış eğrisi.
  static const Curve exit = Curves.easeInCubic;

  /// Sistem veya kullanıcı isterse hareket azaltılır. Açık false sistemin
  /// erişilebilirlik tercihini iptal etmez; kalıcı tercih Profil fazında bağlanır.
  static bool reduceMotion(BuildContext context, {bool? userPreference}) =>
      MediaQuery.disableAnimationsOf(context) || userPreference == true;

  /// Hareket azaltmada kısa fade süresini, aksi halde normal süreyi döndürür.
  static Duration duration(
    BuildContext context,
    Duration normal, {
    bool? userPreference,
  }) =>
      reduceMotion(context, userPreference: userPreference) ? reduced : normal;
}
