/// Türkçe içerik paketi: kullanıcıya görünen adların Türkçe tabloları.
///
/// Bu tablolar motor enum'larındaki `etiket` alanlarının içerik
/// katmanındaki karşılığıdır (INGILIZCE_SURUM_PLANI.md §6.3). Geçiş
/// boyunca ikisi aynı kalır (`tr_icerik_paketi_test.dart` denetler);
/// tüm kullanım pakete taşınınca enum `etiket`'leri silinir.
///
/// Değerler değiştirilmez: adlar metinlere ve slotlara girdiği için
/// değişirse Türkçe çıktı ve geri bildirim kimlikleri değişir (D4, D7).
library;

import '../luck_engine/luck_engine.dart';
import 'icerik_paketi.dart';
import 'turkce_ek.dart';

/// Türkçe paketin tek örneği; birleştiricilerin varsayılan paketi ve
/// Türkçe metin dosyalarının ad kaynağı.
const TrIcerikPaketi trIcerik = TrIcerikPaketi();

/// [IcerikPaketi]'nin Türkçe uygulaması.
///
/// `switch` ifadeleri kapsayıcıdır: enum'a yeni değer eklenirse derleme
/// burada hata verir, eksik ad kalmaz.
final class TrIcerikPaketi implements IcerikPaketi {
  /// Türkçe paketi oluşturur; tek örnek için [trIcerik] kullan.
  const TrIcerikPaketi();

  @override
  IcerikDili get dil => IcerikDili.tr;

  @override
  String burcAdi(Burc burc) => switch (burc) {
    Burc.kova => 'Kova',
    Burc.balik => 'Balık',
    Burc.koc => 'Koç',
    Burc.boga => 'Boğa',
    Burc.ikizler => 'İkizler',
    Burc.yengec => 'Yengeç',
    Burc.aslan => 'Aslan',
    Burc.basak => 'Başak',
    Burc.terazi => 'Terazi',
    Burc.akrep => 'Akrep',
    Burc.yay => 'Yay',
    Burc.oglak => 'Oğlak',
  };

  @override
  String elementAdi(BurcElementi element) => switch (element) {
    BurcElementi.ates => 'Ateş',
    BurcElementi.toprak => 'Toprak',
    BurcElementi.hava => 'Hava',
    BurcElementi.su => 'Su',
  };

  @override
  String kategoriAdi(LuckCategory kategori) => switch (kategori) {
    LuckCategory.ask => 'Aşk',
    LuckCategory.para => 'Para',
    LuckCategory.saglik => 'Sağlık',
    LuckCategory.risk => 'Risk',
    LuckCategory.sosyal => 'Sosyal',
  };

  @override
  String ayEvresiAdi(AyEvresi evre) => switch (evre) {
    AyEvresi.yeniAy => 'Yeni ay',
    AyEvresi.buyuyenHilal => 'Büyüyen hilal',
    AyEvresi.ilkDordun => 'İlk dördün',
    AyEvresi.buyuyenSiskin => 'Şişkin ay',
    AyEvresi.dolunay => 'Dolunay',
    AyEvresi.kuculenSiskin => 'Küçülen şişkin ay',
    AyEvresi.sonDordun => 'Son dördün',
    AyEvresi.kuculenHilal => 'Küçülen hilal',
  };

  @override
  String uyumDerecesiAdi(UyumDerecesi derece) => switch (derece) {
    UyumDerecesi.guclu => 'Güçlü uyum',
    UyumDerecesi.dengeli => 'Dengeli uyum',
    UyumDerecesi.gelistiren => 'Geliştiren uyum',
  };

  @override
  String iyelik(String isim) => TurkceEk.ilgi(isim);
}
