/// Türkiye'nin saat dilimi geçmişi: yerel doğum saatinden UTC farkı —
/// saf Dart (CLAUDE.md kural 3).
///
/// Yükselen 4 dakikada ~1° ilerlediği için 1 saatlik yanlış fark burcu
/// neredeyse kesin değiştirir. Kurallar IANA tz veritabanının
/// Europe/Istanbul kaydıyla (tzdata `europe` dosyası) birebir aynıdır:
/// - 1940–1977: UTC+2, düzensiz yaz saatleri (1942–1945 savaş yılları
///   boyunca kesintisiz; 1962–1963'te 15 ay).
/// - 1978 Haziran – 1984 Ekim: UTC+3 standart; yalnızca 1983 yazında
///   (31 Temmuz – 2 Ekim) UTC+4.
/// - 1985–2006: UTC+2, yaz saati UTC+3 (Mart'ın son pazarı, 1994'te
///   20 Mart; bitiş 1986–1995 Eylül'ün, 1996–2006 Ekim'in son pazarı).
/// - 2007–2016: AB kuralı (01:00 UTC); istisnalar: 2011'de başlangıç
///   28 Mart, 2014'te 31 Mart, 2015'te bitiş 8 Kasım. 2016 yazından
///   itibaren UTC+3 kalıcı.
///
/// 1978 öncesi kayıtlar kaynağın kendi notlarına göre daha az
/// güvenilirdir: bu dönem için [SaatDilimiSonucu.kesin] false olur ve
/// arayüz Yükselen'i "yaklaşık" gösterir.
library;

/// Bir yerel saat için UTC farkı ve güvenilirliği.
class SaatDilimiSonucu {
  /// [farkSaat] ve [kesin] ile sonuç oluşturur.
  const SaatDilimiSonucu({required this.farkSaat, required this.kesin});

  /// Yerel saat − UTC (saat).
  final int farkSaat;

  /// Fark güvenilir mi? 1978 öncesi ve yaz saati geçiş saatlerinde
  /// (atlanan/tekrarlanan saat) false.
  final bool kesin;
}

/// Türkiye saat dilimi kuralları.
abstract final class TurkiyeSaatDilimi {
  /// Standart saat (EET) farkı.
  static const int standartFark = 2;

  /// Yaz saati ve 2016 sonrası kalıcı fark.
  static const int yazFarki = 3;

  /// Kayıtların güvenilir kabul edildiği ilk yıl.
  static const int kesinBaslangicYili = 1978;

  /// Yıl bazlı genel kuralların (Mart/Eylül-Ekim son pazar) başladığı yıl.
  static const int kuralliDonemYili = 1986;

  /// AB kuralına geçiş yılı.
  static const int abKuraliYili = 2007;

  /// Kalıcı UTC+3'e geçilen yıl (o yıl yaz saatiyle başlayıp hiç geri
  /// alınmadı).
  static const int kaliciYil = 2016;

  /// [yerel] (Türkiye'de duvar saati) için UTC farkı.
  static SaatDilimiSonucu utcFarki(DateTime yerel) {
    final int yil = yerel.year;
    if (yil > kaliciYil) {
      return const SaatDilimiSonucu(farkSaat: yazFarki, kesin: true);
    }
    // Duvar saati, saat diliminden bağımsız bir "naif" an olarak tutulur.
    final DateTime duvar = DateTime.utc(
      yerel.year,
      yerel.month,
      yerel.day,
      yerel.hour,
      yerel.minute,
    );
    if (yil < kuralliDonemYili) {
      return _eskiDonem(duvar);
    }

    final (DateTime, DateTime?) aralik = _yazSaatiAraligi(yil);
    final DateTime baslangic = aralik.$1;
    final DateTime? bitis = aralik.$2;
    // Duvar saatini standart farkla UTC'ye çevirip aralıkla karşılaştır.
    final DateTime utcStandart = duvar.subtract(
      const Duration(hours: standartFark),
    );
    final DateTime utcYaz = utcStandart.subtract(const Duration(hours: 1));

    final bool yazda =
        !utcStandart.isBefore(baslangic) &&
        (bitis == null || utcYaz.isBefore(bitis));

    // Geçiş gecesindeki atlanan ya da tekrarlanan saat belirsizdir.
    const Duration birSaat = Duration(hours: 1);
    final bool baslangicaYakin =
        utcStandart.difference(baslangic).abs() < birSaat;
    final bool bitiseYakin =
        bitis != null && utcYaz.difference(bitis).abs() < birSaat;

    return SaatDilimiSonucu(
      farkSaat: yazda ? yazFarki : standartFark,
      kesin: !baslangicaYakin && !bitiseYakin,
    );
  }

  /// [yil] (1986–2016) için yaz saatinin başlangıç ve bitiş anı (UTC);
  /// 2016'da bitiş yok (kalıcı UTC+3).
  static (DateTime, DateTime?) _yazSaatiAraligi(int yil) {
    if (yil >= abKuraliYili) {
      // AB kuralı: geçişler 01:00 UTC'de.
      DateTime baslangic = DateTime.utc(yil, 3, _sonPazar(yil, 3), 1);
      DateTime? bitis = DateTime.utc(yil, 10, _sonPazar(yil, 10), 1);
      switch (yil) {
        case 2011:
          baslangic = DateTime.utc(2011, 3, 28, 1);
        case 2014:
          baslangic = DateTime.utc(2014, 3, 31, 1);
        case 2015:
          bitis = DateTime.utc(2015, 11, 8, 1);
        case kaliciYil:
          bitis = null;
      }
      return (baslangic, bitis);
    }
    // 1986–2006 Türkiye kuralı: geçişler yerel standart saatle 01:00
    // (= 23:00 UTC, bir önceki gün).
    const Duration fark = Duration(hours: standartFark);
    final int baslangicGunu = yil == 1994 ? 20 : _sonPazar(yil, 3);
    final int bitisAyi = yil <= 1995 ? 9 : 10;
    return (
      DateTime.utc(yil, 3, baslangicGunu, 1).subtract(fark),
      DateTime.utc(yil, bitisAyi, _sonPazar(yil, bitisAyi), 1).subtract(fark),
    );
  }

  /// [yil] [ay]ının son pazar gününün ayın kaçı olduğu.
  static int _sonPazar(int yil, int ay) {
    final DateTime sonGun = DateTime.utc(yil, ay + 1, 0);
    return sonGun.day - (sonGun.weekday % DateTime.daysPerWeek);
  }

  /// [yil] [ay] [gun] ya da ondan sonraki ilk pazar, [saat]te (tzdata
  /// "Sun>=N" kuralı; gerekirse sonraki aya taşar).
  static DateTime _gunVeyaSonrakiPazar(
    int yil,
    int ay,
    int gun, [
    int saat = 0,
  ]) {
    final DateTime d = DateTime.utc(yil, ay, gun, saat);
    final int ekGun = (DateTime.sunday - d.weekday) % DateTime.daysPerWeek;
    return d.add(Duration(days: ekGun));
  }

  /// 1986 öncesi dönemler: duvar saatine göre [baslangic, bitis) aralığı
  /// ve o aralıktaki fark. Aralık dışı UTC+2'dir. Liste özelden genele
  /// sıralıdır (ilk eşleşen kazanır).
  static final List<(DateTime, DateTime, int)> _eskiDonemler =
      <(DateTime, DateTime, int)>[
        // 1983 yazı: UTC+3 standart üstüne yaz saati.
        (DateTime.utc(1983, 7, 31, 2), DateTime.utc(1983, 10, 2, 2), 4),
        // 1978 Nisan yaz saati, 29 Haziran'da standart UTC+3'e dönüştü.
        (_gunVeyaSonrakiPazar(1978, 4, 1, 2), DateTime.utc(1984, 11, 1, 2), 3),
        (DateTime.utc(1985, 4, 20, 1), DateTime.utc(1985, 9, 28, 1), 3),
        (
          _gunVeyaSonrakiPazar(1977, 4, 1, 2),
          _gunVeyaSonrakiPazar(1977, 10, 15, 2),
          3,
        ),
        for (final (int, int, int) b in <(int, int, int)>[
          (1974, 3, 31),
          (1975, 3, 22),
          (1976, 3, 21),
        ])
          (
            DateTime.utc(b.$1, b.$2, b.$3, 2),
            _gunVeyaSonrakiPazar(b.$1, 10, 31, 2),
            3,
          ),
        (DateTime.utc(1973, 6, 3, 1), _gunVeyaSonrakiPazar(1973, 10, 31, 2), 3),
        (DateTime.utc(1964, 5, 15), DateTime.utc(1964, 10), 3),
        (DateTime.utc(1962, 7, 15), DateTime.utc(1963, 10, 30), 3),
        (DateTime.utc(1951, 4, 22), _gunVeyaSonrakiPazar(1951, 10, 2), 3),
        (DateTime.utc(1950, 4, 16), _gunVeyaSonrakiPazar(1950, 10, 2), 3),
        (DateTime.utc(1949, 4, 10), _gunVeyaSonrakiPazar(1949, 10, 2), 3),
        for (final int y in <int>[1947, 1948])
          (_gunVeyaSonrakiPazar(y, 4, 16), _gunVeyaSonrakiPazar(y, 10, 2), 3),
        (DateTime.utc(1946, 6), DateTime.utc(1946, 10), 3),
        // Savaş yılları: 1942 Nisan – 1945 Ekim kesintisiz yaz saati.
        (DateTime.utc(1942, 4), DateTime.utc(1945, 10, 8), 3),
        (DateTime.utc(1940, 12), DateTime.utc(1941, 9, 21), 3),
        (DateTime.utc(1940, 7), DateTime.utc(1940, 10, 6), 3),
      ];

  static SaatDilimiSonucu _eskiDonem(DateTime duvar) {
    int fark = standartFark;
    bool gecisYakin = false;
    const Duration birSaat = Duration(hours: 1);
    for (final (DateTime, DateTime, int) d in _eskiDonemler) {
      if (duvar.difference(d.$1).abs() < birSaat ||
          duvar.difference(d.$2).abs() < birSaat) {
        gecisYakin = true;
      }
      if (!duvar.isBefore(d.$1) && duvar.isBefore(d.$2)) {
        fark = d.$3;
        break;
      }
    }
    return SaatDilimiSonucu(
      farkSaat: fark,
      kesin: duvar.year >= kesinBaslangicYili && !gecisYakin,
    );
  }
}
