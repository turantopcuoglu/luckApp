/// Özel isimlere Türkçe büyük/küçük ünlü uyumuna göre ek getirir.
///
/// Kişisel metinde en ucuz güven kaldıracı ismi doğru çekimlemektir;
/// "Ayşe'nın" gibi bir hata metni anında "bot yazmış" gösterir. Bu yüzden
/// ekler kesme işaretiyle ve kaynaştırma harfleriyle (n, y) üretilir.
abstract final class TurkceEk {
  static const String _kalinlar = 'aıou';
  static const String _incelerDuz = 'ei';
  static const String _kalinYuvarlak = 'ou';
  static const String _inceYuvarlak = 'öü';
  static const String _tumUnluler = 'aıoueiöüâîû';

  /// Son ünlüyü (küçük harf) bulur; şapkalılar karşılıklarına indirgenir.
  static String? _sonUnlu(String kelime) {
    final String kucuk = _kucuk(kelime);
    for (int i = kucuk.length - 1; i >= 0; i--) {
      final String k = kucuk[i];
      if (_tumUnluler.contains(k)) {
        return switch (k) {
          'â' => 'a',
          'î' => 'i',
          'û' => 'u',
          _ => k,
        };
      }
    }
    return null;
  }

  static String _kucuk(String s) =>
      s.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();

  static bool _unluyleBitiyor(String kelime) {
    final String kucuk = _kucuk(kelime.trim());
    return kucuk.isNotEmpty && _tumUnluler.contains(kucuk[kucuk.length - 1]);
  }

  /// Dört yönlü ünlü (ı, i, u, ü) — ilgi ve belirtme hâli için.
  static String _dortlu(String kelime) {
    final String? son = _sonUnlu(kelime);
    if (son == null) {
      // Ünlüsüz kısaltmalarda (ör. "Brk") ince okunuş varsayılır.
      return 'i';
    }
    if (_kalinYuvarlak.contains(son)) {
      return 'u';
    }
    if (_inceYuvarlak.contains(son)) {
      return 'ü';
    }
    if (_kalinlar.contains(son)) {
      return 'ı';
    }
    return _incelerDuz.contains(son) ? 'i' : 'i';
  }

  /// İki yönlü ünlü (a, e) — yönelme hâli için.
  static String _ikili(String kelime) {
    final String? son = _sonUnlu(kelime);
    return son != null && _kalinlar.contains(son) ? 'a' : 'e';
  }

  /// İlgi hâli: "Ayşe" → "Ayşe'nin", "Turan" → "Turan'ın".
  static String ilgi(String isim) {
    final String ad = isim.trim();
    final String kaynastirma = _unluyleBitiyor(ad) ? 'n' : '';
    return "$ad'$kaynastirma${_dortlu(ad)}n";
  }

  /// Yönelme hâli: "Ayşe" → "Ayşe'ye", "Turan" → "Turan'a".
  static String yonelme(String isim) {
    final String ad = isim.trim();
    final String kaynastirma = _unluyleBitiyor(ad) ? 'y' : '';
    return "$ad'$kaynastirma${_ikili(ad)}";
  }

  /// Belirtme hâli: "Ayşe" → "Ayşe'yi", "Turan" → "Turan'ı".
  static String belirtme(String isim) {
    final String ad = isim.trim();
    final String kaynastirma = _unluyleBitiyor(ad) ? 'y' : '';
    return "$ad'$kaynastirma${_dortlu(ad)}";
  }

  /// Bir sayının okunuşuna göre ilgi hâli: 4 → "4'ün", 6 → "6'nın".
  ///
  /// Numeroloji metinlerinde yalnızca 1-9, 11, 22, 33 geçer; sayının
  /// okunuşunun son hecesi eki belirler (dört → ün, altı → nın).
  static String sayiIlgi(int sayi) {
    final String okunus = _okunus(sayi);
    final String kaynastirma = _unluyleBitiyor(okunus) ? 'n' : '';
    return "$sayi'$kaynastirma${_dortlu(okunus)}n";
  }

  static String _okunus(int sayi) {
    const List<String> birler = <String>[
      'sıfır',
      'bir',
      'iki',
      'üç',
      'dört',
      'beş',
      'altı',
      'yedi',
      'sekiz',
      'dokuz',
    ];
    const List<String> onlar = <String>[
      '',
      'on',
      'yirmi',
      'otuz',
      'kırk',
      'elli',
      'altmış',
      'yetmiş',
      'seksen',
      'doksan',
    ];
    final int n = sayi.abs() % 100;
    if (n < 10) {
      return birler[n];
    }
    final int birlik = n % 10;
    return birlik == 0 ? onlar[n ~/ 10] : birler[birlik];
  }
}
