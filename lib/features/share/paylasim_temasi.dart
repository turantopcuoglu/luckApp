import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_images.dart';

/// Hikâye kartının arka plan teması (mockup `9635f67f` 1. ekran).
///
/// Görseller aynı kompozisyonda (kemer, göl, ortada sakin gökyüzü);
/// skor ve metinler kodla ortadaki sakin alana yazılır.
enum PaylasimTemasi {
  /// Lacivert gece, sağ üstte hilal.
  gece(gorsel: AppImages.paylasimGece),

  /// Kemerden dökülen altın-beyaz ışık.
  isik(gorsel: AppImages.paylasimIsik),

  /// Mor-lavanta bulutsu gökyüzü.
  mor(gorsel: AppImages.paylasimMor);

  const PaylasimTemasi({required this.gorsel});

  /// Arka plan görselinin asset yolu.
  final String gorsel;

  /// Seçicide görünen ad ([metinler] dilinde).
  String etiket(AppLocalizations metinler) => switch (this) {
    PaylasimTemasi.gece => metinler.paylasimTemaGece,
    PaylasimTemasi.isik => metinler.paylasimTemaIsik,
    PaylasimTemasi.mor => metinler.paylasimTemaMor,
  };
}
