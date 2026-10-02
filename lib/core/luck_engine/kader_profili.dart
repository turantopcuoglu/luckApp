import 'ay_evresi.dart';
import 'burc.dart';
import 'numeroloji.dart';

/// Kullanıcının zamanla değişmeyen "kimlik" katmanı.
///
/// Doğum tarihi ve (varsa) doğumdaki tam addan türetilir. Günlük skor
/// her gün değişirken bu profil sabit kalır; yorumların tutarlı ve
/// "bana özel" okunmasının dayanağıdır.
class KaderProfili {
  /// Tüm alanlarıyla profil oluşturur (genelde [hesapla] kullanılır).
  const KaderProfili({
    required this.yasamYolu,
    required this.isimSayisi,
    required this.ruhSayisi,
    required this.kisilikSayisi,
    required this.dogumGunuSayisi,
    required this.burc,
    required this.burcSinirGunu,
    required this.dogumTarihi,
  });

  /// [dogumTarihi] ve [tamAd]'dan profili hesaplar.
  ///
  /// [tamAd] boşsa veya harf içermiyorsa isim tabanlı sayılar null olur.
  factory KaderProfili.hesapla({required DateTime dogumTarihi, String? tamAd}) {
    final String ad = tamAd ?? '';
    return KaderProfili(
      yasamYolu: Numeroloji.yasamYolu(dogumTarihi),
      isimSayisi: Numeroloji.isimSayisi(ad),
      ruhSayisi: Numeroloji.ruhSayisi(ad),
      kisilikSayisi: Numeroloji.kisilikSayisi(ad),
      dogumGunuSayisi: Numeroloji.dogumGunuSayisi(dogumTarihi),
      burc: Burc.dogumTarihinden(dogumTarihi),
      burcSinirGunu: Burc.sinirGunuMu(dogumTarihi),
      dogumTarihi: DateTime(
        dogumTarihi.year,
        dogumTarihi.month,
        dogumTarihi.day,
      ),
    );
  }

  /// Yaşam Yolu sayısı ve hesap adımları.
  final SayiHesabi yasamYolu;

  /// İsim (Kader/İfade) sayısı; tam ad yoksa null.
  final SayiHesabi? isimSayisi;

  /// Ruh sayısı (sesli harfler); tam ad yoksa null.
  final SayiHesabi? ruhSayisi;

  /// Kişilik sayısı (sessiz harfler); tam ad yoksa null.
  final SayiHesabi? kisilikSayisi;

  /// Doğum günü sayısı.
  final int dogumGunuSayisi;

  /// Güneş burcu.
  final Burc burc;

  /// Doğum günü burç sınırına çok yakın mı? (burç saate göre değişebilir)
  final bool burcSinirGunu;

  /// Profilin hesaplandığı doğum tarihi (saatten arındırılmış).
  final DateTime dogumTarihi;
}

/// Bir güne ait, kullanıcıya özgü zaman döngüleri.
class GunDongusu {
  /// Tüm alanlarıyla döngü oluşturur (genelde [hesapla] kullanılır).
  const GunDongusu({
    required this.kisiselYil,
    required this.kisiselAy,
    required this.kisiselGun,
    required this.ayEvresi,
  });

  /// [dogumTarihi] sahibi için [gun] döngülerini hesaplar.
  factory GunDongusu.hesapla({
    required DateTime dogumTarihi,
    required DateTime gun,
  }) {
    final DateTime tarih = DateTime(gun.year, gun.month, gun.day);
    return GunDongusu(
      kisiselYil: Numeroloji.kisiselYil(dogumTarihi, tarih.year),
      kisiselAy: Numeroloji.kisiselAy(dogumTarihi, tarih),
      kisiselGun: Numeroloji.kisiselGun(dogumTarihi, tarih),
      ayEvresi: AyEvresi.bul(tarih),
    );
  }

  /// Kişisel yıl (1-9).
  final int kisiselYil;

  /// Kişisel ay (1-9).
  final int kisiselAy;

  /// Kişisel gün (1-9).
  final int kisiselGun;

  /// Günün ay evresi.
  final AyEvresi ayEvresi;
}
