import 'engine_config.dart';

/// Ham uniform bir değeri (0 ≤ [ham] < 1) 0-100 skoruna dönüştürür.
///
/// Dağılım şekillendirme (plan Session 1, madde 4):
/// - Değerlerin ~%97'si 40-85 bandına sıkıştırılır (sıradan günler).
/// - %1.5 ihtimalle 0-15 arası "çok şanssız" uç değer üretilir.
/// - %1.5 ihtimalle 92-100 arası "çok şanslı" uç değer üretilir.
///
/// Fonksiyon saf ve deterministiktir; rastgelelik çağırana aittir,
/// bu sayede dağılım tek başına test edilebilir.
int sekillendir(double ham) {
  assert(ham >= 0 && ham < 1, 'ham uniform [0,1) aralığında olmalı');

  if (ham < EngineConfig.ucOlasilik) {
    // Alt uç: [0, ucOlasilik) aralığını [0, ucAltSinir) bandına ger.
    final double oran = ham / EngineConfig.ucOlasilik;
    return (oran * EngineConfig.ucAltSinir).floor();
  }

  if (ham >= 1 - EngineConfig.ucOlasilik) {
    // Üst uç: son ucOlasilik'lik dilimi (ucUstSinir, 100] bandına ger.
    final double oran =
        (ham - (1 - EngineConfig.ucOlasilik)) / EngineConfig.ucOlasilik;
    final double genislik = EngineConfig.skorMaks - EngineConfig.ucUstSinir;
    return (EngineConfig.ucUstSinir + oran * genislik).ceil();
  }

  // Orta bölge: kalan olasılık kütlesini [bandAlt, bandUst] içine
  // doğrusal olarak sıkıştır.
  final double ortaOran = (ham - EngineConfig.ucOlasilik) /
      (1 - 2 * EngineConfig.ucOlasilik);
  final double bandGenisligi = EngineConfig.bandUst - EngineConfig.bandAlt;
  return (EngineConfig.bandAlt + ortaOran * bandGenisligi).round();
}
