/// Dünya geneli doğum saat dilimi: doğum yerinin IANA kimliği ve yerel
/// doğum saatinden UTC farkı (K8-2). Saf Dart (CLAUDE.md kural 3).
///
/// Astroloji pratiği: doğum saati, doğum yerinin O TARİHTEKİ saat dilimi
/// ve yaz saati kuralıyla UT'ye çevrilir. Yükselen ~4 dakikada 1°
/// kaydığı için bir saatlik hata burcu genellikle değiştirir.
///
/// Kurallar:
/// - `Europe/Istanbul`: fark `TurkiyeSaatDilimi`nden gelir. Türkiye'de
///   doğanların sonucu bu modülden önceki hâliyle birebir aynıdır.
/// - Diğer bölgeler: IANA tz veritabanı (`timezone` paketi, `latest`
///   verisi; bildirimlerle aynı veri, uygulamaya ek boyut getirmez).
/// - Yaz saati geçişinde ATLANAN saat (ör. 02:30, saat 02:00'de 03:00'e
///   alındıysa) geçişten önceki farkla yorumlanır; İKİ KEZ YAŞANAN saat
///   ilk yaşanışıyla (yaz saati) yorumlanır. İkisinde de sonuç "kesin
///   değil" olur ve [DogumSaatDilimiSonucu.durum] bunu söyler.
/// - Türkiye dışında 1970 öncesi doğumlar "kesin değil"dir: IANA bu
///   dönemde bölgeye adını veren şehrin dışında tahmindir.
library;

import 'package:timezone/data/latest.dart' as tz_veri;
import 'package:timezone/timezone.dart' as tz;

import 'engine_config.dart';
import 'turkiye_saat_dilimi.dart';

/// Yerel doğum saatinin o gün saat dilimi geçişine göre durumu.
enum YerelSaatDurumu {
  /// Saat o gün bir kez yaşandı.
  normal,

  /// Saat yaz saatine geçişte atlandı (duvar saatinde hiç yaşanmadı).
  atlanan,

  /// Saat yaz saatinden dönüşte iki kez yaşandı.
  tekrarlanan,
}

/// Bir yerel doğum saati için UTC farkı ve güvenilirliği.
class DogumSaatDilimiSonucu {
  /// Tüm alanlarıyla sonuç oluşturur.
  const DogumSaatDilimiSonucu({
    required this.farkDakika,
    required this.kesin,
    required this.durum,
  });

  /// Yerel saat − UTC (dakika). +05:30 ve +05:45 gibi farklar da tam
  /// ifade edilir.
  final int farkDakika;

  /// Fark güvenilir mi? Atlanan ya da iki kez yaşanan saatte, Türkiye
  /// dışında 1970 öncesinde ve Türkiye'nin 1978 öncesinde false.
  final bool kesin;

  /// Saatin geçiş gecesine göre durumu.
  final YerelSaatDurumu durum;

  /// Fark saat olarak (ör. 5.5); `DogumHaritasi.hesapla`nın girdisi.
  double get farkSaat => farkDakika / Duration.minutesPerHour;
}

/// Doğum yerinin saat dilimi kurallarıyla UTC farkı.
abstract final class DogumSaatDilimi {
  /// IANA verisini, henüz yüklenmemişse bir kez yükler.
  ///
  /// `timezone` paketi tek bir genel veritabanı tutar ve yeniden yükleme
  /// paketin "yerel konum" ayarını UTC'ye sıfırlar. Bu yüzden veri yalnız
  /// boşsa yüklenir; bildirim servisinin ayarına dokunulmaz.
  static void _veriyiHazirla() {
    if (!tz.timeZoneDatabase.isInitialized) {
      tz_veri.initializeTimeZones();
    }
  }

  /// [ianaKimligi] veritabanında var mı? (ör. GeoNames kaydını doğrulamak
  /// için).
  static bool tanimliMi(String ianaKimligi) {
    _veriyiHazirla();
    return tz.timeZoneDatabase.locations.containsKey(ianaKimligi);
  }

  /// [ianaKimligi] bölgesinde [yerel] duvar saati için UTC farkı.
  ///
  /// [yerel]in yalnız yıl, ay, gün, saat ve dakikası okunur; makinenin
  /// saat dilimi sonucu etkilemez. Kimlik veritabanında yoksa null.
  ///
  /// Duvar saati `DateTime.utc(...)` ile verilmelidir: yerel `DateTime`
  /// kurucusu, makinenin kendi diliminde atlanan saati (ör. cihaz
  /// İstanbul'dayken 28 Mart 2010 03:30) sessizce bir saat ileri kaydırır
  /// ve atlanan saat hiç buraya ulaşmaz.
  static DogumSaatDilimiSonucu? cozumle({
    required String ianaKimligi,
    required DateTime yerel,
  }) {
    if (ianaKimligi == EngineConfig.turkiyeSaatDilimiKimligi) {
      return _turkiye(yerel);
    }
    if (!tanimliMi(ianaKimligi)) {
      return null;
    }
    final tz.Location konum = tz.getLocation(ianaKimligi);
    final (int, YerelSaatDurumu) fark = _ianaFarki(konum, yerel);
    return DogumSaatDilimiSonucu(
      farkDakika: fark.$1,
      kesin:
          fark.$2 == YerelSaatDurumu.normal &&
          yerel.year >= EngineConfig.ianaGuvenilirBaslangicYili,
      durum: fark.$2,
    );
  }

  /// Türkiye: fark ve güvenilirlik `TurkiyeSaatDilimi`nden; geçiş
  /// gecesi durumu IANA `Europe/Istanbul` kaydından (iki kaynak aynı
  /// kuralları taşır, bkz. testler).
  static DogumSaatDilimiSonucu _turkiye(DateTime yerel) {
    final SaatDilimiSonucu tr = TurkiyeSaatDilimi.utcFarki(yerel);
    _veriyiHazirla();
    final YerelSaatDurumu durum = _ianaFarki(
      tz.getLocation(EngineConfig.turkiyeSaatDilimiKimligi),
      yerel,
    ).$2;
    return DogumSaatDilimiSonucu(
      farkDakika: tr.farkSaat * Duration.minutesPerHour,
      kesin: tr.kesin && durum == YerelSaatDurumu.normal,
      durum: durum,
    );
  }

  /// [konum]da [yerel] duvar saatinin farkı (dakika) ve durumu.
  static (int, YerelSaatDurumu) _ianaFarki(tz.Location konum, DateTime yerel) {
    // Duvar saati, saat diliminden bağımsız "naif" bir an olarak tutulur.
    final int duvar = DateTime.utc(
      yerel.year,
      yerel.month,
      yerel.day,
      yerel.hour,
      yerel.minute,
    ).millisecondsSinceEpoch;
    const int pencere =
        EngineConfig.saatDilimiGecisPenceresiSaat *
        Duration.millisecondsPerHour;
    // Pencerenin iki ucundaki farklar: geçiş yoksa ikisi aynıdır.
    final int once = konum.timeZone(duvar - pencere).offset;
    final int sonra = konum.timeZone(duvar + pencere).offset;
    // Bir fark, o farkla bulunan UTC anında gerçekten geçerliyse tutarlıdır.
    bool tutarli(int fark) => konum.timeZone(duvar - fark).offset == fark;
    final List<int> adaylar = <int>{once, sonra}.where(tutarli).toList()
      ..sort();

    final int farkMs;
    final YerelSaatDurumu durum;
    if (adaylar.length == 1) {
      farkMs = adaylar.single;
      durum = YerelSaatDurumu.normal;
    } else if (adaylar.length > 1) {
      // İki kez yaşanan saat: ilk yaşanış, yani büyük fark (yaz saati).
      farkMs = adaylar.last;
      durum = YerelSaatDurumu.tekrarlanan;
    } else {
      // Atlanan saat: geçişten önceki fark.
      farkMs = once;
      durum = YerelSaatDurumu.atlanan;
    }
    return (farkMs ~/ Duration.millisecondsPerMinute, durum);
  }
}
