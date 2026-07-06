import 'dart:math';

import 'engine_config.dart';
import 'luck_modifier.dart';

/// Ay evresi modifiyerinin raporlanan adı.
const String ayEvresiAdi = 'Ay evresi';

/// Gün numerolojisi modifiyerinin raporlanan adı.
const String numerolojiAdi = 'Gün numerolojisi';

/// Seri dengesi (düşük geçmiş telafisi) modifiyerinin raporlanan adı.
const String seriDengesiAdi = 'Seri dengesi';

/// Bilinen bir yeniay anı (6 Ocak 2000 18:14 UTC) — evre hesabının
/// referans noktası. Paket kullanmadan basit astronomik hesap için yeterli.
final DateTime _yeniayReferansi = DateTime.utc(2000, 1, 6, 18, 14);

/// [gun] için ay evresi modifiyerini hesaplar.
///
/// Evre, referans yeniaydan geçen sürenin sinodik aya bölümünün kesir
/// kısmıdır (0 = yeniay, 0.5 = dolunay). Etki kosinüsle -8..+8 puana
/// çevrilir: yeniay -8, dolunay +8, aradaki evreler yumuşak geçiş.
LuckModifier ayEvresiModifiyeri(DateTime gun) {
  // Dakika hassasiyeti evre için fazlasıyla yeterli.
  final double gecenGun =
      gun.toUtc().difference(_yeniayReferansi).inMinutes /
          Duration.minutesPerHour /
          Duration.hoursPerDay;
  final double devir = gecenGun / EngineConfig.sinodikAyGun;
  // floor ile kesir alma, referans öncesi (negatif) tarihlerde de
  // 0..1 aralığında evre döndürür.
  final double evre = devir - devir.floorToDouble();

  final int etki = (-cos(2 * pi * evre) * EngineConfig.modifiyerMaksEtki)
      .round();
  return LuckModifier(ad: ayEvresiAdi, etki: etki);
}

/// [gun] için gün numerolojisi modifiyerini hesaplar.
///
/// yyyyMMdd rakamlarının toplamı tek haneye indirgenir (1-9) ve
/// doğrusal olarak -8..+8 aralığına eşlenir: 1 → -8, 5 → 0, 9 → +8.
LuckModifier numerolojiModifiyeri(DateTime gun) {
  final int toplam =
      _rakamToplami(gun.year) + _rakamToplami(gun.month) + _rakamToplami(gun.day);
  final int tekHane = _tekHaneyeIndir(toplam);

  // 1..9 → -8..+8 doğrusal eşleme (2x - 10).
  final int etki = tekHane * 2 - (EngineConfig.modifiyerMaksEtki + 2);
  return LuckModifier(ad: numerolojiAdi, etki: etki);
}

/// [sayi]nın ondalık rakamlarının toplamını döndürür.
int _rakamToplami(int sayi) {
  int kalan = sayi;
  int toplam = 0;
  while (kalan > 0) {
    toplam += kalan % 10;
    kalan ~/= 10;
  }
  return toplam;
}

/// [sayi]yı rakam toplamını yineleyerek tek haneye (1-9) indirger.
int _tekHaneyeIndir(int sayi) {
  int kalan = sayi;
  while (kalan > 9) {
    kalan = _rakamToplami(kalan);
  }
  return kalan;
}
