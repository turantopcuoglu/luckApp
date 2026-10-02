/// Türkiye'nin 81 ilinin merkez koordinatları — saf Dart (CLAUDE.md
/// kural 3).
///
/// Yükselen hesabı için il düzeyi yeterlidir: bir il içindeki boylam
/// farkı Yükselen'i en fazla birkaç derece kaydırır ve sınıra yakın
/// sonuçlar zaten `DogumHaritasi.yukselenSinirda` ile işaretlenir.
/// Koordinatlar il merkezinin yaklaşık konumudur (±0.1°; Yükselen'i
/// en fazla ~0.1° kaydırır).
library;

/// Bir il: plaka kodu, ad ve merkez koordinatları.
class Il {
  /// Tüm alanlarıyla il oluşturur.
  const Il(this.plaka, this.ad, this.enlem, this.boylam);

  /// Plaka kodu (1-81).
  final int plaka;

  /// İl adı.
  final String ad;

  /// Enlem (kuzey pozitif, derece).
  final double enlem;

  /// Boylam (doğu pozitif, derece).
  final double boylam;
}

/// Türkiye illeri ve arama.
abstract final class TurkiyeIlleri {
  /// Plaka sırasıyla 81 il.
  static const List<Il> hepsi = <Il>[
    Il(1, 'Adana', 37.00, 35.32),
    Il(2, 'Adıyaman', 37.76, 38.28),
    Il(3, 'Afyonkarahisar', 38.76, 30.54),
    Il(4, 'Ağrı', 39.72, 43.05),
    Il(5, 'Amasya', 40.65, 35.83),
    Il(6, 'Ankara', 39.93, 32.86),
    Il(7, 'Antalya', 36.89, 30.71),
    Il(8, 'Artvin', 41.18, 41.82),
    Il(9, 'Aydın', 37.85, 27.85),
    Il(10, 'Balıkesir', 39.65, 27.88),
    Il(11, 'Bilecik', 40.14, 29.98),
    Il(12, 'Bingöl', 38.88, 40.50),
    Il(13, 'Bitlis', 38.40, 42.11),
    Il(14, 'Bolu', 40.74, 31.61),
    Il(15, 'Burdur', 37.72, 30.29),
    Il(16, 'Bursa', 40.19, 29.06),
    Il(17, 'Çanakkale', 40.15, 26.41),
    Il(18, 'Çankırı', 40.60, 33.62),
    Il(19, 'Çorum', 40.55, 34.95),
    Il(20, 'Denizli', 37.78, 29.09),
    Il(21, 'Diyarbakır', 37.91, 40.24),
    Il(22, 'Edirne', 41.68, 26.56),
    Il(23, 'Elazığ', 38.67, 39.22),
    Il(24, 'Erzincan', 39.75, 39.49),
    Il(25, 'Erzurum', 39.90, 41.27),
    Il(26, 'Eskişehir', 39.78, 30.52),
    Il(27, 'Gaziantep', 37.07, 37.38),
    Il(28, 'Giresun', 40.91, 38.39),
    Il(29, 'Gümüşhane', 40.46, 39.48),
    Il(30, 'Hakkari', 37.58, 43.74),
    Il(31, 'Hatay', 36.20, 36.16),
    Il(32, 'Isparta', 37.76, 30.55),
    Il(33, 'Mersin', 36.81, 34.64),
    Il(34, 'İstanbul', 41.01, 28.98),
    Il(35, 'İzmir', 38.42, 27.14),
    Il(36, 'Kars', 40.60, 43.10),
    Il(37, 'Kastamonu', 41.38, 33.78),
    Il(38, 'Kayseri', 38.72, 35.49),
    Il(39, 'Kırklareli', 41.73, 27.22),
    Il(40, 'Kırşehir', 39.15, 34.17),
    Il(41, 'Kocaeli', 40.77, 29.92),
    Il(42, 'Konya', 37.87, 32.48),
    Il(43, 'Kütahya', 39.42, 29.98),
    Il(44, 'Malatya', 38.35, 38.31),
    Il(45, 'Manisa', 38.61, 27.43),
    Il(46, 'Kahramanmaraş', 37.58, 36.94),
    Il(47, 'Mardin', 37.31, 40.74),
    Il(48, 'Muğla', 37.22, 28.36),
    Il(49, 'Muş', 38.75, 41.51),
    Il(50, 'Nevşehir', 38.62, 34.71),
    Il(51, 'Niğde', 37.97, 34.68),
    Il(52, 'Ordu', 40.98, 37.88),
    Il(53, 'Rize', 41.02, 40.52),
    Il(54, 'Sakarya', 40.78, 30.40),
    Il(55, 'Samsun', 41.29, 36.33),
    Il(56, 'Siirt', 37.93, 41.94),
    Il(57, 'Sinop', 42.03, 35.15),
    Il(58, 'Sivas', 39.75, 37.02),
    Il(59, 'Tekirdağ', 40.98, 27.51),
    Il(60, 'Tokat', 40.31, 36.55),
    Il(61, 'Trabzon', 41.00, 39.72),
    Il(62, 'Tunceli', 39.11, 39.55),
    Il(63, 'Şanlıurfa', 37.17, 38.79),
    Il(64, 'Uşak', 38.68, 29.41),
    Il(65, 'Van', 38.49, 43.38),
    Il(66, 'Yozgat', 39.82, 34.81),
    Il(67, 'Zonguldak', 41.45, 31.79),
    Il(68, 'Aksaray', 38.37, 34.03),
    Il(69, 'Bayburt', 40.26, 40.23),
    Il(70, 'Karaman', 37.18, 33.22),
    Il(71, 'Kırıkkale', 39.85, 33.51),
    Il(72, 'Batman', 37.89, 41.13),
    Il(73, 'Şırnak', 37.52, 42.46),
    Il(74, 'Bartın', 41.63, 32.34),
    Il(75, 'Ardahan', 41.11, 42.70),
    Il(76, 'Iğdır', 39.92, 44.04),
    Il(77, 'Yalova', 40.66, 29.27),
    Il(78, 'Karabük', 41.20, 32.62),
    Il(79, 'Kilis', 36.72, 37.12),
    Il(80, 'Osmaniye', 37.07, 36.25),
    Il(81, 'Düzce', 40.84, 31.16),
  ];

  /// [plaka] kodlu il; geçersizse null.
  static Il? plakadan(int plaka) =>
      plaka >= 1 && plaka <= hepsi.length ? hepsi[plaka - 1] : null;

  /// [sorgu]yla başlayan ya da onu içeren iller (Türkçe harf ve büyük-
  /// küçük harf duyarsız). Başlayanlar önce, sonra içerenler; her grup
  /// plaka sırasında. Boş sorgu tüm illeri döndürür.
  static List<Il> ara(String sorgu) {
    final String s = sadelestir(sorgu.trim());
    if (s.isEmpty) {
      return hepsi;
    }
    final List<Il> baslayan = <Il>[];
    final List<Il> iceren = <Il>[];
    for (final Il il in hepsi) {
      final String ad = sadelestir(il.ad);
      if (ad.startsWith(s)) {
        baslayan.add(il);
      } else if (ad.contains(s)) {
        iceren.add(il);
      }
    }
    return <Il>[...baslayan, ...iceren];
  }

  /// Metni aramaya uygun hâle getirir: Türkçe kurallarla küçük harf ve
  /// şapkasız/noktasız Latin karşılıkları ("İzmir" → "izmir",
  /// "Çanakkale" → "canakkale", "IĞDIR" → "igdir").
  static String sadelestir(String metin) {
    const Map<String, String> esler = <String, String>{
      'ç': 'c',
      'Ç': 'c',
      'ğ': 'g',
      'Ğ': 'g',
      'ı': 'i',
      'I': 'i',
      'İ': 'i',
      'ö': 'o',
      'Ö': 'o',
      'ş': 's',
      'Ş': 's',
      'ü': 'u',
      'Ü': 'u',
      'â': 'a',
      'î': 'i',
      'û': 'u',
    };
    final StringBuffer b = StringBuffer();
    for (final int kod in metin.runes) {
      final String k = String.fromCharCode(kod);
      b.write(esler[k] ?? k.toLowerCase());
    }
    return b.toString();
  }
}
