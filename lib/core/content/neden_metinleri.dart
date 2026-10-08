import '../luck_engine/luck_engine.dart';
import 'dongu_metinleri.dart';
import 'tr_icerik_paketi.dart';
import 'yorum_yonu.dart';

/// "Neden bugün?" çiplerinin ve açıklamalarının metinleri.
///
/// Amaç şeffaflık: kullanıcı skorun ve yorumun hangi hesaplardan
/// geldiğini görür. Açıklamalar gerçek hesap değerlerini kullanır;
/// hiçbir sayı süs için uydurulmaz.
abstract final class NedenMetinleri {
  /// Puan etkisini işaretli biçimde yazar: +3, −2, ±0.
  static String etkiMetni(int etki) {
    if (etki > 0) {
      return '+$etki';
    }
    if (etki < 0) {
      return '−${etki.abs()}';
    }
    return '±0';
  }

  /// Kişisel gün çipi.
  static String kisiselGunEtiketi(int kisiselGun) => 'Kişisel gün $kisiselGun';

  /// Kişisel gün açıklaması: günün teması ve kişinin doğasıyla buluşması.
  static String kisiselGunAciklamasi(GunDongusu dongu, BulusmaTuru bulusma) =>
      'Doğum günün ve ayın bu yılın rakamlarıyla toplanınca kişisel yılın '
      '${dongu.kisiselYil} çıkıyor; buna bu ayı eklemek kişisel ayını '
      '(${dongu.kisiselAy}), bugünün tarihini eklemek kişisel gününü '
      '(${dongu.kisiselGun}) veriyor. Bu sayı günün temasını belirler: '
      '${YorumYonu.gunTemalari[dongu.kisiselGun]!.istek}. '
      '${_bulusmaAciklamasi[bulusma]!} Bu hesap senin doğum tarihine özeldir.';

  static const Map<BulusmaTuru, String> _bulusmaAciklamasi =
      <BulusmaTuru, String>{
    BulusmaTuru.uyumlu: 'Bu tema yaşam yolu sayının doğasıyla uyumlu olduğu '
        'için yorum, güçlü yanını kullanmanı öneriyor.',
    BulusmaTuru.dengeli: 'Bu tema yaşam yolu sayının doğasını tamamlayan bir '
        'tema olduğu için yorum, iki yanı dengelemeni öneriyor.',
    BulusmaTuru.zorlayici: 'Bu tema yaşam yolu sayının doğasına ters düştüğü '
        'için yorum, günün sürtünmesini nasıl yöneteceğini anlatıyor.',
  };

  /// Çakışma çipi.
  static const String cakismaEtiketi = 'Kişisel gün = yaşam yolu';

  /// Çakışma açıklaması.
  static const String cakismaAciklamasi =
      'Bugünün kişisel gün sayısı yaşam yolu sayınla aynı. Numerolojide bu '
      'günler kişinin doğal eğilimlerinin en rahat aktığı günler olarak '
      'yorumlanır.';

  /// Ay evresi çipi.
  static String ayEvresiEtiketi(AyEvresi evre, int etki) =>
      '${trIcerik.ayEvresiAdi(evre)} ${etkiMetni(etki)}';

  /// Ay evresi açıklaması.
  static String ayEvresiAciklamasi(AyEvresi evre, int etki) =>
      '${DonguMetinleri.ayEvresi[evre]!.first} Kader, ayın evresini basit '
      'bir astronomik hesapla bulur: yeni aya yaklaştıkça enerji içe döner '
      've skor biraz düşer, dolunaya yaklaştıkça yükselir. Bugün bu etki '
      '${etkiMetni(etki)} puan. Herkes için aynıdır.';

  /// Gün sayısı çipi.
  static String gunSayisiEtiketi(int sayi, int etki) =>
      'Gün sayısı $sayi ${etkiMetni(etki)}';

  /// Gün sayısı açıklaması.
  static String gunSayisiAciklamasi(DateTime gun, int sayi, int etki) {
    final String rakamlar = '${gun.year}${gun.month}${gun.day}'
        .split('')
        .join('+');
    return 'Bugünün tarihindeki rakamlar ($rakamlar) toplanıp tek haneye '
        'indirgenince evrensel gün sayısı $sayi çıkıyor. Kader formülünde '
        'bu sayı 1 ile 9 arasında −8 ile +8 puan arası bir etkiye çevrilir; '
        'bugün skoruna ${etkiMetni(etki)} puan olarak yansıdı. Herkes için '
        'aynıdır.';
  }

  /// Seri dengesi çipi.
  static String seriEtiketi(int etki) => 'Denge ${etkiMetni(etki)}';

  /// Seri dengesi açıklaması.
  static String seriAciklamasi(int etki) =>
      'Son günlerde skorların ortalamanın altında kaldı. Kader, arka arkaya '
      'zor günlerin ardından dengeleyici bir etki uygular; bugün skoruna '
      '${etkiMetni(etki)} puan eklendi.';
}
