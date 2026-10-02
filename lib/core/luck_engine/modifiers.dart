import 'dart:math';

import 'ay_evresi.dart';
import 'engine_config.dart';
import 'luck_modifier.dart';
import 'numeroloji.dart';

/// Ay evresi modifiyerinin raporlanan adı.
const String ayEvresiAdi = 'Ay evresi';

/// Gün numerolojisi modifiyerinin raporlanan adı.
const String numerolojiAdi = 'Gün numerolojisi';

/// Seri dengesi (düşük geçmiş telafisi) modifiyerinin raporlanan adı.
const String seriDengesiAdi = 'Seri dengesi';

/// [gun] için ay evresi modifiyerini hesaplar.
///
/// Evre oranı [ayEvresiOrani] ile bulunur (0 = yeniay, 0.5 = dolunay).
/// Etki kosinüsle -8..+8 puana çevrilir: yeniay -8, dolunay +8, aradaki
/// evreler yumuşak geçiş.
LuckModifier ayEvresiModifiyeri(DateTime gun) {
  final double evre = ayEvresiOrani(gun);
  final int etki = (-cos(2 * pi * evre) * EngineConfig.modifiyerMaksEtki)
      .round();
  return LuckModifier(ad: ayEvresiAdi, etki: etki);
}

/// [gun] takvim gününün evrensel numeroloji sayısı (1-9).
///
/// Yıl, ay ve gün rakamlarının toplamı tek haneye indirgenir; herkes
/// için aynıdır (kişisel gün sayısından farklıdır).
int gunNumerolojiSayisi(DateTime gun) => Numeroloji.indirge(
  Numeroloji.rakamToplami(gun.year) +
      Numeroloji.rakamToplami(gun.month) +
      Numeroloji.rakamToplami(gun.day),
  ustaKoru: false,
);

/// [gun] için gün numerolojisi modifiyerini hesaplar.
///
/// [gunNumerolojiSayisi] (1-9) doğrusal olarak -8..+8 aralığına
/// eşlenir: 1 → -8, 5 → 0, 9 → +8.
LuckModifier numerolojiModifiyeri(DateTime gun) {
  final int tekHane = gunNumerolojiSayisi(gun);
  // 1..9 → -8..+8 doğrusal eşleme (2x - 10).
  final int etki = tekHane * 2 - (EngineConfig.modifiyerMaksEtki + 2);
  return LuckModifier(ad: numerolojiAdi, etki: etki);
}
