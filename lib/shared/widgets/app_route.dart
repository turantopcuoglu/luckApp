import 'package:flutter/material.dart';

/// Geçiş süresi: Material fade-through standardına yakın.
const Duration _gecisSuresi = Duration(milliseconds: 300);

/// Gelen sayfanın görünmeye başladığı eşik (önce eski sayfa çekilir).
const double _gelenBaslangicEsigi = 0.35;

/// Gelen sayfanın başlangıç ölçeği (hafif büyüyerek oturur).
const double _gelenBaslangicOlcegi = 0.92;

/// Uygulama genelindeki paylaşılan "fade-through" sayfa geçişi
/// (plan Session 5, madde 4). Tüm push'lar bu fabrikadan geçmelidir:
///
/// ```dart
/// Navigator.of(context).push(fadeThroughRoute(DetaySayfasi()));
/// ```
PageRoute<T> fadeThroughRoute<T>(Widget sayfa) {
  return PageRouteBuilder<T>(
    transitionDuration: _gecisSuresi,
    reverseTransitionDuration: _gecisSuresi,
    pageBuilder: (
      BuildContext context,
      Animation<double> animasyon,
      Animation<double> ikincil,
    ) =>
        sayfa,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animasyon,
      Animation<double> ikincil,
      Widget child,
    ) {
      // Fade-through: gelen sayfa sürenin ilk %35'inde görünmez
      // (bu sırada giden sayfa solar), sonra fade + hafif scale ile
      // oturur. Giden sayfa ikincil animasyonla erkenden solar.
      final Animation<double> gelenOpaklik = CurvedAnimation(
        parent: animasyon,
        curve: const Interval(_gelenBaslangicEsigi, 1, curve: Curves.easeOut),
      );
      final Animation<double> gelenOlcek = Tween<double>(
        begin: _gelenBaslangicOlcegi,
        end: 1,
      ).animate(
        CurvedAnimation(parent: animasyon, curve: Curves.easeOutCubic),
      );
      final Animation<double> gidenOpaklik = Tween<double>(
        begin: 1,
        end: 0,
      ).animate(
        CurvedAnimation(
          parent: ikincil,
          curve: const Interval(0, _gelenBaslangicEsigi, curve: Curves.easeIn),
        ),
      );

      return FadeTransition(
        opacity: gidenOpaklik,
        child: FadeTransition(
          opacity: gelenOpaklik,
          child: ScaleTransition(scale: gelenOlcek, child: child),
        ),
      );
    },
  );
}
