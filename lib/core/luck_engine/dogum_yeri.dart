/// Doğum yeri: ülke, şehir, saat dilimi ve koordinat (K8-4). Saf Dart.
library;

import 'dogum_saat_dilimi.dart';
import 'engine_config.dart';
import 'turkiye_illeri.dart';

/// Kişinin doğduğu yer.
///
/// Türkiye doğumlarında yer 81 il listesinden kurulur ([DogumYeri.il]);
/// koordinat ve saat dilimi koddaki listeden gelir, böylece bugünkü
/// Türkiye haritaları değişmez. Diğer ülkelerde şehir seçildiği anda
/// koordinat ve IANA kimliği kayda yazılır: şehir verisi sonradan
/// güncellense de harita değişmez.
class DogumYeri {
  /// Tüm alanlarıyla doğum yeri oluşturur.
  const DogumYeri({
    required this.ulkeKodu,
    required this.ad,
    required this.saatDilimi,
    required this.enlem,
    required this.boylam,
    this.sehirKimligi,
    this.ilPlaka,
  });

  /// Türkiye'deki bir il.
  factory DogumYeri.il(Il il) => DogumYeri(
        ulkeKodu: EngineConfig.turkiyeUlkeKodu,
        ad: il.ad,
        saatDilimi: EngineConfig.turkiyeSaatDilimiKimligi,
        enlem: il.enlem,
        boylam: il.boylam,
        ilPlaka: il.plaka,
      );

  /// ISO 3166-1 iki harfli ülke kodu (ör. `TR`, `DE`).
  final String ulkeKodu;

  /// Seçildiği andaki şehir adı (görüntü için).
  final String ad;

  /// IANA saat dilimi kimliği (ör. `Europe/Berlin`).
  final String saatDilimi;

  /// Enlem (kuzey pozitif, derece).
  final double enlem;

  /// Boylam (doğu pozitif, derece).
  final double boylam;

  /// Şehir verisindeki kimlik (GeoNames); Türkiye illerinde null.
  final int? sehirKimligi;

  /// Türkiye'de il plaka kodu (1-81); başka ülkede null.
  final int? ilPlaka;

  /// Doğum Türkiye'de mi?
  bool get turkiyeMi => ulkeKodu == EngineConfig.turkiyeUlkeKodu;

  /// [yerel] duvar saati için bu yerin UTC farkı.
  ///
  /// [yerel]in yalnız alanları okunur (bkz. [DogumSaatDilimi.cozumle]).
  /// Saat dilimi kimliği veritabanında yoksa (ör. eski bir kimlik)
  /// boylamdan yerel ortalama güneş zamanı kullanılır ve sonuç kesin
  /// sayılmaz: okuma boş kalmaz, ama Yükselen için not düşülür.
  DogumSaatDilimiSonucu saatDilimiSonucu(DateTime yerel) =>
      DogumSaatDilimi.cozumle(ianaKimligi: saatDilimi, yerel: yerel) ??
      DogumSaatDilimiSonucu(
        farkDakika: (boylam * EngineConfig.boylamDerecesiBasinaDakika).round(),
        kesin: false,
        durum: YerelSaatDurumu.normal,
      );
}
