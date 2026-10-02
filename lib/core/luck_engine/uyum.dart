import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'burc.dart';
import 'engine_config.dart';
import 'kader_profili.dart';

/// İki yaşam yolu sayısının geleneksel uyum ilişkisi.
///
/// Numeroloji geleneği taban sayıları üç "doğal uyum" grubuna ayırır:
/// {1, 5, 7} bağımsızlık ve zihin, {2, 4, 8} yapı ve güven,
/// {3, 6, 9} duygu ve yaratıcılık.
enum YasamYoluIliskisi {
  /// Aynı taban sayı: birbirini aynada görmek.
  ayna,

  /// Aynı doğal uyum grubu.
  ayniGrup,

  /// Birbirini tamamlayan gruplar ({1,5,7} ile {3,6,9}).
  destekleyici,

  /// Farklı ritimdeki gruplar: öğretici, emek isteyen uyum.
  zorlayici,
}

/// İki burç elementinin ilişkisi.
enum ElementIliskisi {
  /// Aynı element.
  ayni,

  /// Tamamlayıcı (ateş-hava, toprak-su).
  tamamlayici,

  /// Nötr (ateş-toprak, hava-su).
  notr,

  /// Zıt (ateş-su, toprak-hava).
  zit,
}

/// Uyum skorunun özet derecesi.
enum UyumDerecesi {
  /// Güçlü uyum.
  guclu(etiket: 'Güçlü uyum'),

  /// Dengeli uyum.
  dengeli(etiket: 'Dengeli uyum'),

  /// Birbirini geliştiren, emek isteyen uyum.
  gelistiren(etiket: 'Geliştiren uyum');

  const UyumDerecesi({required this.etiket});

  /// Kullanıcıya gösterilecek Türkçe ad.
  final String etiket;
}

/// İki profil arasındaki uyum sonucu.
class UyumSonucu {
  /// Tüm alanlarıyla sonuç oluşturur.
  const UyumSonucu({
    required this.skor,
    required this.derece,
    required this.yasamYoluIliskisi,
    required this.elementIliskisi,
    required this.ruhUyumlu,
  });

  /// 35-98 arası uyum skoru.
  final int skor;

  /// Skorun özet derecesi.
  final UyumDerecesi derece;

  /// Yaşam yolu sayılarının ilişkisi.
  final YasamYoluIliskisi yasamYoluIliskisi;

  /// Burç elementlerinin ilişkisi.
  final ElementIliskisi elementIliskisi;

  /// Ruh sayıları aynı gruptaysa true; iki tarafın tam adı yoksa null.
  final bool? ruhUyumlu;
}

/// Taban sayının doğal uyum grubu (0: {1,5,7}, 1: {2,4,8}, 2: {3,6,9}).
int uyumGrubu(int tabanSayi) {
  switch (tabanSayi) {
    case 1:
    case 5:
    case 7:
      return 0;
    case 2:
    case 4:
    case 8:
      return 1;
    default:
      return 2;
  }
}

/// [a] ve [b] profillerinin uyumunu hesaplar.
///
/// Simetriktir (a,b) == (b,a) ve deterministiktir. Skor, geleneksel
/// kurallardan (yaşam yolu grubu, element, ruh sayısı) gelen puanlara
/// çifte özgü küçük bir sapma eklenerek bulunur; sapma yalnızca aynı
/// sayılara sahip farklı çiftlerin birebir aynı skoru almaması içindir.
UyumSonucu uyumHesapla(KaderProfili a, KaderProfili b) {
  final YasamYoluIliskisi yyIliski = _yasamYoluIliskisi(
    a.yasamYolu.taban,
    b.yasamYolu.taban,
  );
  final ElementIliskisi elIliski = _elementIliskisi(
    a.burc.element,
    b.burc.element,
  );

  bool? ruhUyumlu;
  if (a.ruhSayisi != null && b.ruhSayisi != null) {
    ruhUyumlu = uyumGrubu(a.ruhSayisi!.taban) == uyumGrubu(b.ruhSayisi!.taban);
  }

  int skor = EngineConfig.uyumTaban;
  skor += switch (yyIliski) {
    YasamYoluIliskisi.ayna => EngineConfig.uyumAynaPuani,
    YasamYoluIliskisi.ayniGrup => EngineConfig.uyumAyniGrupPuani,
    YasamYoluIliskisi.destekleyici => EngineConfig.uyumDestekleyiciPuani,
    YasamYoluIliskisi.zorlayici => 0,
  };
  skor += switch (elIliski) {
    ElementIliskisi.ayni => EngineConfig.uyumAyniElementPuani,
    ElementIliskisi.tamamlayici => EngineConfig.uyumTamamlayiciElementPuani,
    ElementIliskisi.notr => 0,
    ElementIliskisi.zit => EngineConfig.uyumZitElementPuani,
  };
  if (ruhUyumlu ?? false) {
    skor += EngineConfig.uyumRuhPuani;
  }
  skor += _ciftSapmasi(a, b);
  skor = skor.clamp(EngineConfig.uyumMin, EngineConfig.uyumMaks);

  final UyumDerecesi derece = skor >= EngineConfig.uyumGucluEsik
      ? UyumDerecesi.guclu
      : skor >= EngineConfig.uyumDengeliEsik
      ? UyumDerecesi.dengeli
      : UyumDerecesi.gelistiren;

  return UyumSonucu(
    skor: skor,
    derece: derece,
    yasamYoluIliskisi: yyIliski,
    elementIliskisi: elIliski,
    ruhUyumlu: ruhUyumlu,
  );
}

/// İki taban sayının (1-9) geleneksel uyum ilişkisi.
///
/// Yaşam yolu uyumunun yanı sıra isim sayısı ile yaşam yolu gibi farklı
/// sayı türlerini karşılaştırmak için de kullanılır (ör. bebek ismi).
YasamYoluIliskisi sayiIliskisi(int tabanA, int tabanB) =>
    _yasamYoluIliskisi(tabanA, tabanB);

YasamYoluIliskisi _yasamYoluIliskisi(int a, int b) {
  if (a == b) {
    return YasamYoluIliskisi.ayna;
  }
  final int ga = uyumGrubu(a);
  final int gb = uyumGrubu(b);
  if (ga == gb) {
    return YasamYoluIliskisi.ayniGrup;
  }
  // {1,5,7} (grup 0) ile {3,6,9} (grup 2) geleneksel olarak birbirini
  // besler; {2,4,8} diğerleriyle daha fazla emek ister.
  final bool destekleyici = (ga == 0 && gb == 2) || (ga == 2 && gb == 0);
  return destekleyici
      ? YasamYoluIliskisi.destekleyici
      : YasamYoluIliskisi.zorlayici;
}

ElementIliskisi _elementIliskisi(BurcElementi a, BurcElementi b) {
  if (a == b) {
    return ElementIliskisi.ayni;
  }
  final Set<BurcElementi> cift = <BurcElementi>{a, b};
  bool esit(BurcElementi x, BurcElementi y) =>
      cift.containsAll(<BurcElementi>{x, y});
  if (esit(BurcElementi.ates, BurcElementi.hava) ||
      esit(BurcElementi.toprak, BurcElementi.su)) {
    return ElementIliskisi.tamamlayici;
  }
  if (esit(BurcElementi.ates, BurcElementi.su) ||
      esit(BurcElementi.toprak, BurcElementi.hava)) {
    return ElementIliskisi.zit;
  }
  return ElementIliskisi.notr;
}

/// Çifte özgü -3..+3 sapma: iki doğum tarihi sıralanıp özetlenir ki
/// sonuç taraf sırasından bağımsız (simetrik) olsun.
int _ciftSapmasi(KaderProfili a, KaderProfili b) {
  final List<String> anahtarlar = <String>[
    a.dogumTarihi.toIso8601String(),
    b.dogumTarihi.toIso8601String(),
  ]..sort();
  final List<int> ozet = sha256
      .convert(utf8.encode(anahtarlar.join('|')))
      .bytes;
  final int aralik = EngineConfig.uyumSapmaSiniri * 2 + 1;
  return ozet.first % aralik - EngineConfig.uyumSapmaSiniri;
}
