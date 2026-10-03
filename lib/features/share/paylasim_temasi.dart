import '../../shared/widgets/app_images.dart';

/// Hikâye kartının arka plan teması (mockup `9635f67f` 1. ekran).
///
/// Görseller aynı kompozisyonda (kemer, göl, ortada sakin gökyüzü);
/// skor ve metinler kodla ortadaki sakin alana yazılır.
enum PaylasimTemasi {
  /// Lacivert gece, sağ üstte hilal.
  gece(etiket: 'Gece', gorsel: AppImages.paylasimGece),

  /// Kemerden dökülen altın-beyaz ışık.
  isik(etiket: 'Işık', gorsel: AppImages.paylasimIsik),

  /// Mor-lavanta bulutsu gökyüzü.
  mor(etiket: 'Mor', gorsel: AppImages.paylasimMor);

  const PaylasimTemasi({required this.etiket, required this.gorsel});

  /// Seçicide görünen ad.
  final String etiket;

  /// Arka plan görselinin asset yolu.
  final String gorsel;
}
