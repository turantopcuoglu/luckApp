import '../luck_engine/luck_engine.dart';

/// Enerji tarzı: kişi enerjisini yalnız kalınca mı, insanlarla mı toplar.
///
/// 26 Kasım 2026'dan beri (K7) kullanıcıya sorulmaz; Güneş burcunun
/// elementinden türetilir (bkz. [Okuyucu.elementEnerjisi]).
enum EnerjiTarzi {
  /// Enerjisini yalnız kalınca toplar.
  iceDonuk,

  /// Enerjisini insanlarla toplar.
  disaDonuk,
}

/// Karar verirken öne çıkan taraf; Güneş burcunun elementinden türetilir
/// (bkz. [Okuyucu.elementKarari]).
enum KararTarzi {
  /// Önce kalbini dinler.
  kalp,

  /// Önce aklını ve hesabı dinler.
  akil,
}

/// Çekirdek portre: okumaların çelişki kapısında kullandığı TEK kişilik
/// tarifi (bkz. [Okuyucu.portre]).
class Portre {
  /// Enerji ve karar tarzıyla portre.
  const Portre({required this.enerji, required this.karar});

  /// Enerji tarzı.
  final EnerjiTarzi enerji;

  /// Karar tarzı.
  final KararTarzi karar;

  @override
  bool operator ==(Object other) =>
      other is Portre && other.enerji == enerji && other.karar == karar;

  @override
  int get hashCode => Object.hash(enerji, karar);
}

/// İçerik birleştiricisinin tek girdisi: yorumu okuyacak kişi.
class Okuyucu {
  /// Tüm alanlarıyla okuyucu oluşturur.
  const Okuyucu({
    required this.isim,
    required this.seed,
    required this.profil,
    this.dogumAyi,
    this.yukselen,
  });

  /// Selamlamada ve metinde kullanılan görünen ad.
  final String isim;

  /// Motor tohumu (skor ve içerik seçimi için).
  final UserSeed seed;

  /// Sabit kimlik katmanı (numeroloji + burç).
  final KaderProfili profil;

  /// Doğum anındaki Ay burcu; kesin değilse (doğum saati bilinmiyor ve Ay
  /// o gün burç değiştirmiş, ya da burç sınırına çok yakın) null.
  ///
  /// Yanlış burç söylemek güveni en hızlı yıkan hatadır; emin
  /// olunmadığında okuma Ay burcundan hiç söz etmez.
  final Burc? dogumAyi;

  /// Yükselen burç; doğum saati ya da yeri bilinmiyorsa, ya da yükselen
  /// burç sınırına çok yakınsa null.
  final Burc? yukselen;

  /// Enerji tarzının türetildiği element eşlemesi: ateş ve hava dışa,
  /// toprak ve su içe dönük okunur (burçların en yaygın bilinen tarifi;
  /// kişi kendi burcunu bu tarifle tanır).
  static const Map<BurcElementi, EnerjiTarzi> elementEnerjisi =
      <BurcElementi, EnerjiTarzi>{
        BurcElementi.ates: EnerjiTarzi.disaDonuk,
        BurcElementi.hava: EnerjiTarzi.disaDonuk,
        BurcElementi.toprak: EnerjiTarzi.iceDonuk,
        BurcElementi.su: EnerjiTarzi.iceDonuk,
      };

  /// Karar tarzının türetildiği element eşlemesi: ateş ve su kalbiyle,
  /// toprak ve hava aklıyla karar verir.
  static const Map<BurcElementi, KararTarzi> elementKarari =
      <BurcElementi, KararTarzi>{
        BurcElementi.ates: KararTarzi.kalp,
        BurcElementi.su: KararTarzi.kalp,
        BurcElementi.toprak: KararTarzi.akil,
        BurcElementi.hava: KararTarzi.akil,
      };

  /// Çekirdek portre: bütün okumaların çelişki kapısında kullandığı TEK
  /// kişilik tarifi, Güneş burcunun elementinden ([elementEnerjisi],
  /// [elementKarari]).
  ///
  /// Böylece burç ve yaşam yolu metinleri aynı kişiyi anlatır: Balık
  /// burcu bir okura bir gün "kalabalıkta kolay yorulursun" (burç), ertesi
  /// gün "ortamın merkezindesin" (yaşam yolu 3) denmez. Portre yalnızca
  /// cümle DIŞLAMAK ve profil cümlesi uyarlamak için kullanılır (bkz.
  /// `KisilikMetinleri.uyumlular`). İlişki durumu bilinmez; o konuda
  /// varsayım yapan cümleler her zaman elenir.
  ///
  /// 11 Kasım 2026'da tanışma soruları kalktı; 26 Kasım kararıyla (K7)
  /// cevaba göre dallanan yollar da silindi.
  Portre get portre => Portre(
    enerji: elementEnerjisi[profil.burc.element]!,
    karar: elementKarari[profil.burc.element]!,
  );
}
