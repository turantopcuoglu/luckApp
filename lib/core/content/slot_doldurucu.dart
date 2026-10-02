/// Metin şablonlarındaki `{anahtar}` yer tutucularını doldurur.
///
/// Şablonlar yalnızca [SlotAnahtarlari] içindeki anahtarları kullanabilir;
/// havuz bütünlük testleri bunu doğrular. Çözülemeyen bir yer tutucu
/// kullanıcıya asla "{isim}" olarak görünmemelidir: [slotDoldur] eksik
/// anahtarda [StateError] fırlatır ki hata testte yakalansın.
library;

/// Şablonlarda kullanılabilecek tüm yer tutucu anahtarları.
abstract final class SlotAnahtarlari {
  /// Görünen ad ("Ayşe").
  static const String isim = 'isim';

  /// Adın ilgi hâli ("Ayşe'nin").
  static const String isimIlgi = 'isminin';

  /// Güneş burcunun adı ("Balık").
  static const String burc = 'burc';

  /// Yaşam yolu sayısı ("4").
  static const String yasamYolu = 'yasamYolu';

  /// Kişisel gün sayısı ("4").
  static const String kisiselGun = 'kisiselGun';

  /// Kişisel yıl sayısı ("9").
  static const String kisiselYil = 'kisiselYil';

  /// Takvim yılı ("2026").
  static const String yil = 'yil';

  /// Şanslı saat aralığı ("14:00 - 16:00").
  static const String saat = 'saat';

  /// Günlük uğraş alanı ("işin", "derslerin", …).
  static const String ugrasAlani = 'ugrasAlani';

  /// Uyum ekranındaki diğer kişinin adı.
  static const String digerIsim = 'digerIsim';

  /// Okuyucunun doğası, mastar öbeği ("düzen kurmak ve …").
  static const String doga = 'doga';

  /// Günün okuyucudan istediği, mastar öbeği ("bir şeyi tamamlamak …").
  static const String gunIstegi = 'gunIstegi';

  /// Tüm geçerli anahtarlar (bütünlük testleri için).
  static const Set<String> hepsi = <String>{
    doga,
    gunIstegi,
    isim,
    isimIlgi,
    burc,
    yasamYolu,
    kisiselGun,
    kisiselYil,
    yil,
    saat,
    ugrasAlani,
    digerIsim,
  };
}

final RegExp _slotDeseni = RegExp(r'\{([a-zA-Z]+)\}');

/// [sablon] içindeki yer tutucu anahtarlarını döndürür.
Set<String> slotlariBul(String sablon) =>
    _slotDeseni.allMatches(sablon).map((RegExpMatch m) => m.group(1)!).toSet();

/// [sablon]daki her `{anahtar}`'ı [degerler]den doldurur.
///
/// Eksik anahtarda [StateError] fırlatır.
String slotDoldur(String sablon, Map<String, String> degerler) {
  return sablon.replaceAllMapped(_slotDeseni, (Match m) {
    final String anahtar = m.group(1)!;
    final String? deger = degerler[anahtar];
    if (deger == null) {
      throw StateError('Şablonda doldurulamayan yer tutucu: {$anahtar}');
    }
    return deger;
  });
}

/// Metnin sürümler arası kararlı kimliği (FNV-1a 32 bit, hex).
///
/// `String.hashCode` Dart sürümleri arasında garanti değildir; geri
/// bildirimle saklanan kimliklerin yıllar sonra da aynı metni işaret
/// etmesi için elle hesaplanan kararlı özet kullanılır.
String metinKimligi(String metin) {
  const int ofset = 0x811c9dc5;
  const int asal = 0x01000193;
  const int maske = 0xffffffff;
  int ozet = ofset;
  for (final int birim in metin.codeUnits) {
    ozet ^= birim;
    ozet = (ozet * asal) & maske;
  }
  return ozet.toRadixString(16).padLeft(8, '0');
}
