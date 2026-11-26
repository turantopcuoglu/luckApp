import 'package:intl/intl.dart';

/// Mağaza fiyatından türetilen tutarları (ör. yıllık planın aylık
/// karşılığı) para biçimiyle yazar.
///
/// Sayının biçimi (ondalık ve binlik ayırıcı, sembolün yeri) uygulama
/// dilinden, ondalık hane sayısı mağazanın para birimi kodundan gelir.
/// Sembol mağazanın kendi fiyat metninden alınır; böylece yanında duran
/// mağaza fiyatıyla aynı görünür (`intl` Türk lirasını "TL" yazar, mağaza
/// "₺").
abstract final class FiyatBicimi {
  /// Para birimi kodu bilinmediğinde kullanılan ondalık hane sayısı.
  static const int varsayilanOndalikHanesi = 2;

  /// Fiyat metninde sembol olmayan karakterler: rakamlar, ayırıcılar ve
  /// her tür boşluk (dar ve bölünmez boşluklar dahil).
  static final RegExp _sembolDisi = RegExp(r'[\d.,\s   ]');

  /// [tutar]ı [dilKodu] biçiminde yazar.
  ///
  /// [ornekMetin] mağazanın aynı para birimindeki bir fiyat metnidir
  /// ("₺449,99", "$1,299.99"); yalnız sembolü okunur, sayısı okunmaz.
  /// [paraBirimiKodu] ISO 4217 kodudur ("TRY", "USD", "JPY"); null ise
  /// [varsayilanOndalikHanesi] hane kullanılır.
  static String bicimle({
    required double tutar,
    required String ornekMetin,
    required String? paraBirimiKodu,
    required String dilKodu,
  }) {
    final String sembol = ornekMetin.replaceAll(_sembolDisi, '');
    final NumberFormat bicim = NumberFormat.currency(
      locale: dilKodu,
      name: paraBirimiKodu,
      symbol: sembol.isNotEmpty ? sembol : (paraBirimiKodu ?? ''),
      // Kod varsa hane sayısı koddan gelir (JPY 0, TRY 2).
      decimalDigits: paraBirimiKodu == null ? varsayilanOndalikHanesi : null,
    );
    return bicim.format(tutar);
  }
}
