import 'daily_luck_config.dart';

/// Ana ekranın Türkçe metinleri ve yorum şablonları.
///
/// Metinler koddan ayrı tutulur (plan Session 3, madde 2); ileride
/// çoklu dil gerekirse tek dokunma noktası burasıdır.
abstract final class TrStrings {
  /// Haftanın günleri (DateTime.weekday: 1 = Pazartesi).
  static const List<String> gunAdlari = <String>[
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  /// Ay adları (DateTime.month: 1 = Ocak).
  static const List<String> ayAdlari = <String>[
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  /// Onboarding tamamlanana kadar kullanılan misafir ismi.
  static const String misafirIsmi = 'Misafir';

  /// Skor halkasının altındaki etiket.
  static const String genelSkorEtiketi = 'GENEL SKOR';

  /// Skor yüklenirken gösterilen metin.
  static const String yukleniyor = 'Kaderin hesaplanıyor...';

  /// Beklenmeyen hata metni.
  static const String hataMetni =
      'Bir şeyler ters gitti. Uygulamayı yeniden başlatmayı dene.';

  /// [gun] için "6 Temmuz 2026, Pazartesi" biçiminde tarih metni üretir.
  static String tarihMetni(DateTime gun) =>
      '${gun.day} ${ayAdlari[gun.month - 1]} ${gun.year}, '
      '${gunAdlari[gun.weekday - 1]}';

  /// [isim] için selamlama metni üretir.
  static String selamlama(String isim) => 'Merhaba, $isim';

  /// [genelSkor] aralığına göre yorumun açılış cümlesini seçer.
  static String skorAcilisCumlesi(int genelSkor) {
    if (genelSkor < DailyLuckConfig.cokDusukEsik) {
      return 'Bugün evren biraz ters esiyor; büyük kararları yarına bırak.';
    }
    if (genelSkor < DailyLuckConfig.dusukEsik) {
      return 'Bugün temkinli bir gün; adımlarını küçük tut.';
    }
    if (genelSkor < DailyLuckConfig.ortaEsik) {
      return 'Dengeli bir gün seni bekliyor; akışına bırak.';
    }
    if (genelSkor <= DailyLuckConfig.yuksekEsik) {
      return 'Rüzgâr arkandan esiyor; fırsatlara açık ol.';
    }
    return 'Yıldızlar bugün senin için sıralanmış; cesur ol!';
  }

  /// Bir modifiyer için açıklama cümlesi üretir.
  ///
  /// Örn. "Ay evresi skorunu +3 puan etkiledi." Etki sıfırsa dengede
  /// olduğu söylenir.
  static String modifiyerCumlesi(String ad, int etki) {
    if (etki == 0) {
      return '$ad bugün dengede, skoru etkilemedi.';
    }
    final String isaretli = etki > 0 ? '+$etki' : '$etki';
    return '$ad skorunu $isaretli puan etkiledi.';
  }
}
