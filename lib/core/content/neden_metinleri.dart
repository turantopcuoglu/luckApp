import '../luck_engine/luck_engine.dart';
import 'dongu_metinleri.dart';
import 'tr_icerik_paketi.dart';
import 'turkce_ek.dart';
import 'yillik_rapor_metinleri.dart';
import 'yorum_yonu.dart';

/// "Neden bugün?" çiplerinin ve açıklamalarının metinleri.
///
/// Çipler günün okumasının hangi işaretlerden doğduğunu anlatır: kişisel
/// gün, günün sayısı, Ay'ın burcu ve evresi. Açıklamalar yalnızca ANLAMI
/// söyler; hesaplama yöntemi, toplama işlemleri, puan etkileri ve
/// "herkes için aynı" gibi ifadeler kullanıcıya gösterilmez.
abstract final class NedenMetinleri {
  /// Okumanın başındaki tek satırlık "çünkü": okumanın kişinin HANGİ
  /// verisine dayandığını adıyla söyler (doğum günü, burcu, elementi) ve
  /// bugünün Ay'ını o elemente bağlar.
  ///
  /// Kişi kendi verisini metinde gördüğünde okumayı "bana yazılmış" diye
  /// okur. Satır yalnızca dayanağı söyler: yöntem, puan etkisi ya da
  /// "iyi/kötü" yargısı yoktur (yargı okumanın işidir; böylece satır günün
  /// tonuyla hiçbir zaman çelişmez). Gökyüzündeki Ay'ın burç adı burada
  /// anılmaz, çünkü okumanın açılış paragrafı ve "Neden bugün?" çipi onu
  /// zaten söyler.
  ///
  /// [dogumAyi] ve [yukselen] biliniyorsa (doğum saati ve yeri girilmişse)
  /// satır doğum haritasının üç noktasını da sayar: "burcun Balık (su), Ay
  /// burcun Yengeç, yükselenin Aslan". Doğum Ay'ı "Ay burcun", gökyüzündeki
  /// Ay "Ay bugün…" diye anılır ki ikisi karışmasın.
  static String cunku({
    required DateTime dogumTarihi,
    required Burc gunesBurcu,
    required Burc ayBurcu,
    Burc? dogumAyi,
    Burc? yukselen,
  }) {
    final String element = TurkceEk.kucukHarf(
      trIcerik.elementAdi(gunesBurcu.element),
    );
    final String ayElementi = TurkceEk.kucukHarf(
      trIcerik.elementAdi(ayBurcu.element),
    );
    final String ay =
        _cunkuAy[elementIliskisi(ayBurcu.element, gunesBurcu.element)]!
            .replaceAll(_ayElementiYeri, ayElementi);
    final String giris =
        'Sana özel, çünkü ${dogumTarihi.day} '
        '${YillikRaporMetinleri.ayAdlari[dogumTarihi.month - 1]} doğumlusun: '
        'burcun ${trIcerik.burcAdi(gunesBurcu)}';
    if (dogumAyi == null && yukselen == null) {
      return '$giris, elementin $element. $ay';
    }
    final String harita = <String>[
      '$giris ($element)',
      if (dogumAyi != null) 'Ay burcun ${trIcerik.burcAdi(dogumAyi)}',
      if (yukselen != null) 'yükselenin ${trIcerik.burcAdi(yukselen)}',
    ].join(', ');
    return '$harita. $ay';
  }

  /// [_cunkuAy] şablonlarında Ay'ın elementinin yer tutucusu.
  static const String _ayElementiYeri = '{ayElementi}';

  /// "Çünkü" satırının Ay cümlesi: Ay'ın bugünkü elementi ile kişinin
  /// elementinin ilişkisi (yalnızca konum; yargı içermez).
  static const Map<ElementIliskisi, String> _cunkuAy =
      <ElementIliskisi, String>{
        ElementIliskisi.ayni: 'Ay da bugün bir {ayElementi} burcunda.',
        ElementIliskisi.tamamlayici:
            'Ay bugün bir {ayElementi} burcunda, elementini besleyen yerde.',
        ElementIliskisi.notr:
            'Ay bugün bir {ayElementi} burcunda, elementine yabancı bir yerde.',
        ElementIliskisi.zit:
            'Ay bugün bir {ayElementi} burcunda, elementinin tam karşısında.',
      };

  /// Kişisel gün çipi.
  static String kisiselGunEtiketi(int kisiselGun) => 'Kişisel gün $kisiselGun';

  /// Kişisel gün açıklaması: günün teması ve kişinin doğasıyla buluşması.
  static String kisiselGunAciklamasi(GunDongusu dongu, BulusmaTuru bulusma) =>
      'Doğum tarihine özel bugünün sayısı ${dongu.kisiselGun}. Bu sayı '
      'günün temasını belirler: '
      '${YorumYonu.gunTemalari[dongu.kisiselGun]!.istek}. '
      '${_bulusmaAciklamasi[bulusma]!}';

  static const Map<BulusmaTuru, String> _bulusmaAciklamasi =
      <BulusmaTuru, String>{
        BulusmaTuru.uyumlu:
            'Bu tema senin doğanla aynı yönde aktığı için okuman güçlü '
            'yanını kullanmanı öneriyor.',
        BulusmaTuru.dengeli:
            'Bu tema senin doğanı tamamlıyor; okuman iki yanı dengelemeni '
            'öneriyor.',
        BulusmaTuru.zorlayici:
            'Bu tema senin doğana ters düşüyor; okuman günün sürtünmesini '
            'nasıl yöneteceğini anlatıyor.',
      };

  /// Kişisel günün kişinin temel sayısıyla aynı olduğu günün çipi.
  static const String cakismaEtiketi = 'Sayınla aynı gün';

  /// Çakışma açıklaması.
  static const String cakismaAciklamasi =
      'Bugünün sayısı senin temel sayınla aynı. Numerolojide bu günler '
      'kişinin doğal eğilimlerinin en rahat aktığı günler olarak yorumlanır.';

  /// Ay burcu çipi ("Ay Kova burcunda").
  static String ayBurcuEtiketi(Burc ayBurcu) =>
      'Ay ${trIcerik.burcAdi(ayBurcu)} burcunda';

  /// Ay burcu açıklaması: Ay'ın elementi ile kişinin Güneş elementinin
  /// ilişkisi.
  static String ayBurcuAciklamasi(Burc ayBurcu, Burc gunesBurcu) =>
      'Ay bugün ${trIcerik.burcAdi(ayBurcu)} burcunda; '
      '${_ayIliskisi[elementIliskisi(ayBurcu.element, gunesBurcu.element)]!} '
      'Ay iki üç günde bir burç değiştirir ve okumanın havası buradan gelir.';

  static const Map<ElementIliskisi, String> _ayIliskisi =
      <ElementIliskisi, String>{
        ElementIliskisi.ayni:
            'senin burcunla aynı elementte. Duyguların tanıdık ve güçlü, '
            'kendine güvenin artar.',
        ElementIliskisi.tamamlayici:
            'senin burcunun elementini destekleyen bir yerde. Gün sana arkadan '
            'esen bir rüzgâr gibi eşlik eder.',
        ElementIliskisi.notr:
            'senin burcuna yabancı bir elementte. Gün sana alışık olmadığın '
            'bir ritim önerir.',
        ElementIliskisi.zit:
            'senin burcunun elementine ters bir yerde. Hafif sürtünmeler '
            'olabilir; bu gerilim aynı zamanda kıvılcım taşır.',
      };

  /// Ay evresi çipi (evrenin adı).
  static String ayEvresiEtiketi(AyEvresi evre) => trIcerik.ayEvresiAdi(evre);

  /// Ay evresi açıklaması.
  static String ayEvresiAciklamasi(AyEvresi evre) =>
      '${DonguMetinleri.ayEvresi[evre]!.first} Ayın evresi günün enerjisine '
      'ritim verir: yeni aya yaklaşırken enerji içe döner, dolunaya '
      'yaklaştıkça dışa açılır.';

  /// Günün sayısı çipi.
  static String gunSayisiEtiketi(int sayi) => 'Günün sayısı $sayi';

  /// Günün sayısı açıklaması: sayının taşıdığı enerji.
  static String gunSayisiAciklamasi(int sayi) =>
      'Bugünün tarihi $sayi sayısının enerjisini taşıyor: '
      '${YorumYonu.gunTemalari[sayi]!.istek}. Bu enerji günün genel '
      'havasına karışır.';
}
