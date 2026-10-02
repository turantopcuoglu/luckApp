import 'engine_config.dart';

/// Burçların dört elementi.
///
/// Flutter'ın `Element` sınıfıyla çakışmasın diye adı [BurcElementi]dir.
enum BurcElementi {
  /// Ateş: Koç, Aslan, Yay.
  ates(etiket: 'Ateş'),

  /// Toprak: Boğa, Başak, Oğlak.
  toprak(etiket: 'Toprak'),

  /// Hava: İkizler, Terazi, Kova.
  hava(etiket: 'Hava'),

  /// Su: Yengeç, Akrep, Balık.
  su(etiket: 'Su');

  const BurcElementi({required this.etiket});

  /// Kullanıcıya gösterilecek Türkçe ad.
  final String etiket;
}

/// On iki güneş burcu (tropikal zodyak, yaygın Türkçe tarih aralıkları).
///
/// [baslangicAy]/[baslangicGun] burcun başladığı takvim günüdür; burç
/// bir sonrakinin başlangıcına kadar sürer. Sınır günlerinde gerçek
/// burç doğum saatine göre değişebildiği için [sinirGunuMu] ayrıca
/// raporlanır (yanlış burç yorumu güveni en hızlı yıkan hatadır).
enum Burc {
  /// 20 Ocak – 18 Şubat.
  kova(
    etiket: 'Kova',
    element: BurcElementi.hava,
    baslangicAy: 1,
    baslangicGun: 20,
  ),

  /// 19 Şubat – 20 Mart.
  balik(
    etiket: 'Balık',
    element: BurcElementi.su,
    baslangicAy: 2,
    baslangicGun: 19,
  ),

  /// 21 Mart – 19 Nisan.
  koc(
    etiket: 'Koç',
    element: BurcElementi.ates,
    baslangicAy: 3,
    baslangicGun: 21,
  ),

  /// 20 Nisan – 20 Mayıs.
  boga(
    etiket: 'Boğa',
    element: BurcElementi.toprak,
    baslangicAy: 4,
    baslangicGun: 20,
  ),

  /// 21 Mayıs – 20 Haziran.
  ikizler(
    etiket: 'İkizler',
    element: BurcElementi.hava,
    baslangicAy: 5,
    baslangicGun: 21,
  ),

  /// 21 Haziran – 22 Temmuz.
  yengec(
    etiket: 'Yengeç',
    element: BurcElementi.su,
    baslangicAy: 6,
    baslangicGun: 21,
  ),

  /// 23 Temmuz – 22 Ağustos.
  aslan(
    etiket: 'Aslan',
    element: BurcElementi.ates,
    baslangicAy: 7,
    baslangicGun: 23,
  ),

  /// 23 Ağustos – 22 Eylül.
  basak(
    etiket: 'Başak',
    element: BurcElementi.toprak,
    baslangicAy: 8,
    baslangicGun: 23,
  ),

  /// 23 Eylül – 22 Ekim.
  terazi(
    etiket: 'Terazi',
    element: BurcElementi.hava,
    baslangicAy: 9,
    baslangicGun: 23,
  ),

  /// 23 Ekim – 21 Kasım.
  akrep(
    etiket: 'Akrep',
    element: BurcElementi.su,
    baslangicAy: 10,
    baslangicGun: 23,
  ),

  /// 22 Kasım – 21 Aralık.
  yay(
    etiket: 'Yay',
    element: BurcElementi.ates,
    baslangicAy: 11,
    baslangicGun: 22,
  ),

  /// 22 Aralık – 19 Ocak.
  oglak(
    etiket: 'Oğlak',
    element: BurcElementi.toprak,
    baslangicAy: 12,
    baslangicGun: 22,
  );

  const Burc({
    required this.etiket,
    required this.element,
    required this.baslangicAy,
    required this.baslangicGun,
  });

  /// Kullanıcıya gösterilecek Türkçe ad.
  final String etiket;

  /// Burcun elementi.
  final BurcElementi element;

  /// Burcun başladığı ay (1-12).
  final int baslangicAy;

  /// Burcun başladığı gün.
  final int baslangicGun;

  /// [dogumTarihi] için güneş burcunu döndürür.
  ///
  /// Enum değerleri takvim sırasındadır (Ocak'ta başlayan Kova'dan
  /// Aralık'ta başlayan Oğlak'a); başlangıcı doğum gününden sonra
  /// gelmeyen son burç seçilir, hiçbiri yoksa (1-19 Ocak) Oğlak'tır.
  static Burc dogumTarihinden(DateTime dogumTarihi) {
    Burc secilen = Burc.oglak;
    for (final Burc burc in Burc.values) {
      final bool basladi =
          dogumTarihi.month > burc.baslangicAy ||
          (dogumTarihi.month == burc.baslangicAy &&
              dogumTarihi.day >= burc.baslangicGun);
      if (basladi) {
        secilen = burc;
      }
    }
    return secilen;
  }

  /// [dogumTarihi] bir burç sınırına [EngineConfig.burcSinirToleransiGun]
  /// gün veya daha yakın mı?
  static bool sinirGunuMu(DateTime dogumTarihi) {
    // Karşılaştırma artık yıl etkisinden bağımsız olsun diye sabit
    // artık bir yıl (2000) üzerinde yapılır.
    final DateTime gun = DateTime.utc(2000, dogumTarihi.month, dogumTarihi.day);
    for (final Burc burc in Burc.values) {
      final DateTime sinir = DateTime.utc(
        2000,
        burc.baslangicAy,
        burc.baslangicGun,
      );
      final int fark = gun.difference(sinir).inDays;
      // Başlangıç günü ve bir önceki gün (önceki burcun son günü)
      // tolerans içinde sayılır.
      if (fark >= -EngineConfig.burcSinirToleransiGun &&
          fark < EngineConfig.burcSinirToleransiGun) {
        return true;
      }
    }
    return false;
  }
}
